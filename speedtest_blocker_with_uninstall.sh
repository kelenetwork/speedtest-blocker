
#!/bin/bash

BLOCK_LIST_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/category-speedtest"
DNSMASQ_CONF="/etc/dnsmasq.d/block_speedtest.conf"
SERVICE_NAME="dnsmasq"

download_block_list() {
    echo "正在获取测速域名列表..."
    curl -sSL "$BLOCK_LIST_URL" | grep -v '^#' | sed 's/^full:\(.*\)/address=\/\1\/0.0.0.0/' > "$DNSMASQ_CONF"
}

enable_block() {
    if [ ! -f "$DNSMASQ_CONF" ]; then
        download_block_list
    fi
    systemctl restart "$SERVICE_NAME"
    dialog --msgbox "测速网站拦截已启用。\n配置文件位置: $DNSMASQ_CONF" 10 50
}

disable_block() {
    if [ -f "$DNSMASQ_CONF" ]; then
        rm -f "$DNSMASQ_CONF"
        systemctl restart "$SERVICE_NAME"
        dialog --msgbox "测速网站拦截已关闭。\n配置文件已删除。" 10 50
    else
        dialog --msgbox "拦截规则未启用。" 8 40
    fi
}

uninstall_blocker() {
    dialog --yesno "确定要卸载测速拦截工具？\n将删除脚本文件和快捷命令。" 10 50
    if [ $? -eq 0 ]; then
        rm -f /usr/local/bin/speedtest_blocker.sh
        rm -f /etc/profile.d/blockmenu.sh
        dialog --msgbox "已完成卸载操作。\n如需彻底清除，请手动运行：\n  sudo dpkg -r speedtest-blocker" 10 60
    fi
}

show_menu() {
    while true; do
        CHOICE=$(dialog --clear --backtitle "测速网站拦截器" \
            --title "主菜单" \
            --menu "请选择操作：" 16 50 6 \
            1 "启用测速拦截" \
            2 "关闭测速拦截" \
            3 "更新测速列表" \
            4 "卸载测速拦截工具" \
            5 "退出" \
            2>&1 >/dev/tty)

        clear
        case $CHOICE in
            1) enable_block ;;
            2) disable_block ;;
            3) download_block_list; systemctl restart "$SERVICE_NAME"; dialog --msgbox "测速域名列表已更新。" 8 40 ;;
            4) uninstall_blocker ;;
            5) break ;;
        esac
    done
}

show_menu
