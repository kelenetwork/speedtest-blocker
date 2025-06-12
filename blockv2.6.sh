#!/bin/bash
# Speedtest Blocker v2.6 - by kele
# 功能：拦截/恢复测速网站（含IPv4/IPv6）+ 自定义添加 + 完整停用逻辑修复

set -e

LIST_NAME="speedtest_block"
TMPFILE="/tmp/speedtest_domains.txt"
IPLIST="/tmp/speedtest_ips.txt"
BACKUP_RESOLV="/etc/resolv.conf.backup_blocker"
BLOCK_SCRIPT_PATH="$0"

function ensure_dependencies() {
    for cmd in ipset iptables ip6tables dig curl; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ 缺少依赖: $cmd，请先安装它 (apt install $cmd)"
            exit 1
        fi
    done
    if ! command -v dnsmasq &> /dev/null; then
        echo "❌ 缺少 dnsmasq，请先安装它 (apt install dnsmasq)"
        exit 1
    fi
}

function fetch_domains() {
    echo "[+] 获取测速域名列表..."
    curl -sSL https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-speedtest > "$TMPFILE"
}

function domains_to_ips() {
    echo "[+] 域名解析为 IP..."
    > "$IPLIST"
    while read -r line; do
        [[ "$line" =~ ^[#\s]*$ ]] && continue
        domain=$(echo "$line" | sed 's/^full://;s/^domain://;s/^regexp://;s/^keyword://')
        dig +short "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> "$IPLIST" || true
        dig +short AAAA "$domain" | grep -Eo '([a-fA-F0-9:]+:+)+[a-fA-F0-9]+' >> "$IPLIST" || true
    done < "$TMPFILE"
    sort -u "$IPLIST" -o "$IPLIST"
}

function create_ipset() {
    echo "[+] 创建 ipset 规则集：$LIST_NAME"
    ipset destroy $LIST_NAME 2>/dev/null || true
    ipset create $LIST_NAME hash:ip family inet6 -exist
    for ip in $(cat "$IPLIST"); do
        ipset add $LIST_NAME "$ip" 2>/dev/null || true
    done
}

function setup_dnsmasq() {
    echo "[+] 写入 dnsmasq 污染配置..."
    DNSMASQ_CONF="/etc/dnsmasq.d/speedtest_block.conf"
    echo "# Speedtest Blocker DNS 配置" > "$DNSMASQ_CONF"
    while read -r line; do
        [[ "$line" =~ ^[#\s]*$ ]] && continue
        domain=$(echo "$line" | sed 's/^full://;s/^domain://;s/^regexp://;s/^keyword://')
        echo "address=/$domain/127.0.0.1" >> "$DNSMASQ_CONF"
    done < "$TMPFILE"
    systemctl restart dnsmasq
}

function restore_dns() {
    if [[ -f "$BACKUP_RESOLV" ]]; then
        echo "[+] 恢复 DNS 设置..."
        cp "$BACKUP_RESOLV" /etc/resolv.conf
        rm -f "$BACKUP_RESOLV"
    fi
    rm -f /etc/dnsmasq.d/speedtest_block.conf
    systemctl restart dnsmasq
}

function enable_block() {
    ensure_dependencies

    echo "[+] 备份 /etc/resolv.conf"
    [[ ! -f "$BACKUP_RESOLV" ]] && cp /etc/resolv.conf "$BACKUP_RESOLV"
    echo "nameserver 127.0.0.1" > /etc/resolv.conf

    fetch_domains
    domains_to_ips
    create_ipset
    setup_dnsmasq

    iptables -t filter -C OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || \
        iptables -t filter -A OUTPUT -m set --match-set $LIST_NAME dst -j REJECT
    iptables -t filter -C FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || \
        iptables -t filter -A FORWARD -m set --match-set $LIST_NAME dst -j REJECT

    ip6tables -t filter -C OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || \
        ip6tables -t filter -A OUTPUT -m set --match-set $LIST_NAME dst -j REJECT
    ip6tables -t filter -C FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || \
        ip6tables -t filter -A FORWARD -m set --match-set $LIST_NAME dst -j REJECT

    echo "[✅] 已启用测速域名拦截"
}

function disable_block() {
    echo "[!] 正在关闭测速拦截..."
    iptables -t filter -D OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    iptables -t filter -D FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true

    ip6tables -t filter -D OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    ip6tables -t filter -D FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true

    ipset destroy $LIST_NAME 2>/dev/null || true
    restore_dns
    echo "[✅] 拦截规则已全部关闭，系统恢复正常"
}

function view_status() {
    if ipset list $LIST_NAME &>/dev/null; then
        echo "[当前状态] ✅ 拦截已启用"
    else
        echo "[当前状态] ⛔ 拦截未启用"
    fi
}

function add_manual_entry() {
    read -rp "请输入要手动封锁的域名或IP: " entry
    if [[ "$entry" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$entry" =~ : ]]; then
        echo "$entry" >> "$IPLIST"
        ipset add $LIST_NAME "$entry" 2>/dev/null || true
        echo "[+] 已添加 IP $entry 到拦截列表"
    else
        echo "address=/$entry/127.0.0.1" >> /etc/dnsmasq.d/speedtest_block.conf
        systemctl restart dnsmasq
        echo "[+] 已添加域名 $entry 到 dnsmasq 污染"
    fi
}

function uninstall_all() {
    disable_block
    rm -f "$BLOCK_SCRIPT_PATH"
    echo "[✅] 已卸载全部组件（含脚本自身）"
    exit 0
}

function menu() {
    while true; do
        echo ""
        echo "==== Speedtest 拦截器 v2.6 修复版 ===="
        view_status
        echo ""
        echo "1. 启用测速拦截"
        echo "2. 停用拦截（完整恢复）"
        echo "3. 手动添加域名/IP"
        echo "4. 卸载（含脚本）"
        echo "5. 退出"
        echo "====================================="
        read -rp "请输入选项 (1-5): " opt
        case $opt in
            1) enable_block ;;
            2) disable_block ;;
            3) add_manual_entry ;;
            4) uninstall_all ;;
            5) exit 0 ;;
            *) echo "无效输入" ;;
        esac
    done
}

menu
