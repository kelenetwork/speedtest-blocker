
#!/bin/bash

BLOCK_LIST_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-speedtest"
DNSMASQ_CONF="/etc/dnsmasq.d/block_speedtest.conf"
SERVICE_NAME="dnsmasq"
RULE_DESC="iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53"

# 检查 iptables 是否已添加重定向规则
check_iptables_status() {
    iptables -t nat -C PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53 &>/dev/null
    return $?
}

# 检查 dnsmasq 是否运行中
check_dnsmasq_status() {
    systemctl is-active --quiet dnsmasq
    return $?
}

# 判断是否启用中
is_block_enabled() {
    [[ -f "$DNSMASQ_CONF" ]] && grep -q "address=" "$DNSMASQ_CONF" && check_iptables_status && check_dnsmasq_status
    return $?
}

# 生成 dnsmasq 拦截规则
generate_blocklist() {
    echo "[+] 正在生成测速拦截规则..."
    curl -sSL "$BLOCK_LIST_URL" | grep '^full:' | sed 's/^full:\(.*\)/address=\/\1\/0.0.0.0/' > "$DNSMASQ_CONF"
}

# 启用拦截功能
enable_blocking() {
    generate_blocklist
    iptables -t nat -C PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53 2>/dev/null || \
    iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53
    systemctl restart "$SERVICE_NAME"
    echo "[✅] 已启用测速网站拦截。"
}

# 禁用拦截功能
disable_blocking() {
    echo "[~] 正在关闭拦截..."
    rm -f "$DNSMASQ_CONF"
    iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53 2>/dev/null
    systemctl restart "$SERVICE_NAME"
    echo "[⛔] 已关闭测速网站拦截。"
}

# 状态显示函数
show_status() {
    echo
    echo "====== 拦截状态检查 ======"
    if is_block_enabled; then
        echo "[当前状态] ✅ 已启用测速网址拦截"
    else
        echo "[当前状态] ⛔ 未启用测速网址拦截"
    fi
    echo
}

# 主菜单
while true; do
    show_status
    echo "==== Speedtest Blocker v1.2 ===="
    echo "1. 启用测速网址拦截"
    echo "2. 关闭拦截"
    echo "3. 查看拦截状态"
    echo "4. 退出"
    echo "==============================="
    read -p "请输入选项 (1-4): " choice
    case "$choice" in
        1) enable_blocking ;;
        2) disable_blocking ;;
        3) show_status ;;
        4) echo "退出"; break ;;
        *) echo "无效选项，请重新输入。" ;;
    esac
    echo
    sleep 1
done
