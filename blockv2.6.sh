#!/bin/bash
# Speedtest Blocker v2.6 - 终极拦截器
# 支持 IPv4 / IPv6 拦截，支持临时关闭恢复
# 自定义拦截列表、自恢复 resolv.conf，by kele

set -e

LIST_NAME="speedtest_block"
TMPFILE="/tmp/speedtest_domains.txt"
IPLIST="/tmp/speedtest_ips.txt"
CUSTOM_LIST="/etc/speedtest_blocker/custom_block.list"
BACKUP_RESOLV="/etc/resolv.conf.bak"
CURRENT_SCRIPT="/usr/local/bin/blockv2"

function ensure_dependencies() {
    for cmd in ipset ip6tables iptables dig curl; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ 缺少依赖: $cmd，请先执行 apt install $cmd"
            exit 1
        fi
    done
}

function fetch_domains() {
    echo "[+] 获取测速域名列表..."
    curl -sSL https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-speedtest > "$TMPFILE"
}

function domains_to_ips() {
    echo "[+] 域名解析为 IP (包括 IPv4/IPv6)..."
    > "$IPLIST"
    while read -r line; do
        [[ "$line" =~ ^[#\s]*$ ]] && continue
        domain=$(echo "$line" | sed 's/^full://;s/^domain://;s/^regexp://;s/^keyword://')
        dig +short A "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$IPLIST" || true
        dig +short AAAA "$domain" | grep -Eo '([0-9a-fA-F:]+:+)+[0-9a-fA-F]+' >> "$IPLIST" || true
    done < "$TMPFILE"

    # 添加自定义域名
    if [ -f "$CUSTOM_LIST" ]; then
        while read -r entry; do
            dig +short A "$entry" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$IPLIST" || true
            dig +short AAAA "$entry" | grep -Eo '([0-9a-fA-F:]+:+)+[0-9a-fA-F]+' >> "$IPLIST" || true
        done < "$CUSTOM_LIST"
    fi

    sort -u "$IPLIST" -o "$IPLIST"
}

function create_ipset() {
    echo "[+] 创建 ipset：$LIST_NAME"
    ipset destroy $LIST_NAME 2>/dev/null || true
    ipset create $LIST_NAME hash:ip family inet6 -exist
    ipset create $LIST_NAME hash:ip family inet -exist
    for ip in $(cat "$IPLIST"); do
        ipset add $LIST_NAME "$ip" -exist
    done
}

function enable_block() {
    ensure_dependencies
    fetch_domains
    domains_to_ips
    create_ipset

    iptables -t filter -C OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||         iptables -t filter -A OUTPUT -m set --match-set $LIST_NAME dst -j REJECT

    iptables -t filter -C FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||         iptables -t filter -A FORWARD -m set --match-set $LIST_NAME dst -j REJECT

    ip6tables -t filter -C OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||         ip6tables -t filter -A OUTPUT -m set --match-set $LIST_NAME dst -j REJECT

    ip6tables -t filter -C FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||         ip6tables -t filter -A FORWARD -m set --match-set $LIST_NAME dst -j REJECT

    cp /etc/resolv.conf "$BACKUP_RESOLV" 2>/dev/null || true
    echo "nameserver 127.0.0.1" > /etc/resolv.conf

    echo "[✅] 拦截已启用（含 IPv4/IPv6 + DNS）"
}

function disable_block() {
    echo "[!] 正在关闭拦截..."
    iptables -t filter -D OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    iptables -t filter -D FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    ip6tables -t filter -D OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    ip6tables -t filter -D FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    ipset destroy $LIST_NAME 2>/dev/null || true

    if [ -f "$BACKUP_RESOLV" ]; then
        cp "$BACKUP_RESOLV" /etc/resolv.conf
        echo "[🔁] 已恢复 resolv.conf"
    fi

    echo "[✅] 拦截已停用"
}

function view_status() {
    if ipset list $LIST_NAME &>/dev/null; then
        echo "[当前状态] ✅ 拦截已启用"
    else
        echo "[当前状态] ⛔ 拦截未启用"
    fi
}

function uninstall_all() {
    echo "[!] 正在卸载..."
    disable_block
    rm -f "$CURRENT_SCRIPT"
    echo "[✅] 已卸载（脚本与规则均已移除）"
    exit 0
}

function add_custom() {
    mkdir -p /etc/speedtest_blocker
    echo "请输入你要添加的域名或IP，每行一个，输入空行结束："
    while true; do
        read -rp "➤ " domain
        [[ -z "$domain" ]] && break
        echo "$domain" >> "$CUSTOM_LIST"
    done
    sort -u "$CUSTOM_LIST" -o "$CUSTOM_LIST"
    echo "[+] 已保存到 $CUSTOM_LIST"
}

function menu() {
    while true; do
        echo ""
        echo "==== Speedtest Blocker v2.6 ===="
        view_status
        echo ""
        echo "1. 启用拦截"
        echo "2. 停用拦截"
        echo "3. 更新 IP 列表"
        echo "4. 添加自定义域名/IP"
        echo "5. 卸载脚本和规则"
        echo "6. 退出"
        echo "================================"
        read -rp "请输入选项 (1-6): " opt
        case $opt in
            1) enable_block ;;
            2) disable_block ;;
            3) fetch_domains && domains_to_ips && create_ipset && echo "[√] IP 已更新" ;;
            4) add_custom ;;
            5) uninstall_all ;;
            6) exit 0 ;;
            *) echo "无效输入" ;;
        esac
    done
}

menu
