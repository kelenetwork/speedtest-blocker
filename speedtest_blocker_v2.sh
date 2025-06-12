#!/bin/bash
# Speedtest Blocker v2 (无需改XrayR配置) - by kele

# 依赖：ipset dig iptables
# 拦截规则：基于 geosite:category-speedtest 域名 → IP → ipset → iptables 拦截

set -e

LIST_NAME="speedtest_block"
TMPFILE="/tmp/speedtest_domains.txt"
IPLIST="/tmp/speedtest_ips.txt"

function ensure_dependencies() {
    for cmd in ipset iptables dig curl; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ 缺少依赖: $cmd，请先安装它 (apt install $cmd)"
            exit 1
        fi
    done
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
    done < "$TMPFILE"
    sort -u "$IPLIST" -o "$IPLIST"
}

function create_ipset() {
    echo "[+] 创建 ipset 规则集：$LIST_NAME"
    ipset destroy $LIST_NAME 2>/dev/null || true
    ipset create $LIST_NAME hash:ip
    for ip in $(cat "$IPLIST"); do
        ipset add $LIST_NAME "$ip"
    done
}

function enable_block() {
    ensure_dependencies
    fetch_domains
    domains_to_ips
    create_ipset

    iptables -t filter -C OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||     iptables -t filter -A OUTPUT -m set --match-set $LIST_NAME dst -j REJECT

    iptables -t filter -C FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null ||     iptables -t filter -A FORWARD -m set --match-set $LIST_NAME dst -j REJECT

    echo "[✅] 测速域名 IP 拦截已启用"
}

function disable_block() {
    echo "[!] 正在关闭测速拦截..."
    iptables -t filter -D OUTPUT -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    iptables -t filter -D FORWARD -m set --match-set $LIST_NAME dst -j REJECT 2>/dev/null || true
    ipset destroy $LIST_NAME 2>/dev/null || true
    echo "[✅] 已关闭测速域名 IP 拦截"
}

function view_status() {
    if ipset list $LIST_NAME &>/dev/null; then
        echo "[当前状态] ✅ 已启用测速拦截"
        echo "拦截IP数量: $(ipset list $LIST_NAME | grep -cEo '([0-9]{1,3}\.){3}[0-9]{1,3}')"
    else
        echo "[当前状态] ⛔ 未启用测速拦截"
    fi
}

function uninstall_all() {
    echo "[!] 正在卸载测速拦截器（规则 + 面板）..."
    disable_block
    rm -f "$0"
    echo "[✅] 已卸载全部组件（脚本自身也已删除）"
    exit 0
}

function menu() {
    while true; do
        echo ""
        echo "==== Speedtest 拦截器 v2 ===="
        view_status
        echo ""
        echo "1. 启用测速拦截"
        echo "2. 关闭测速拦截"
        echo "3. 更新测速域名IP"
        echo "4. 卸载（含脚本和规则）"
        echo "5. 退出"
        echo "=============================="
        read -rp "请输入选项 (1-5): " opt
        case $opt in
            1) enable_block ;;
            2) disable_block ;;
            3) fetch_domains && domains_to_ips && create_ipset && echo "[√] 已更新 IP" ;;
            4) uninstall_all ;;
            5) exit 0 ;;
            *) echo "无效输入" ;;
        esac
    done
}

menu
