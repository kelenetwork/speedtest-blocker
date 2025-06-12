# Speedtest Blocker v2.6

## 📌 简介

Speedtest Blocker 是一款用于 **屏蔽测速网站** 的一键式脚本工具，特别适用于代理/VPS 节点部署者，用于防止用户在节点上频繁进行带宽测速（如 Speedtest、Fast.com 等），影响服务质量。

此脚本版本为 **v2.6**，具备以下功能：

- ✅ 自动拦截测速网站（基于 [v2fly/domain-list-community](https://github.com/v2fly/domain-list-community) 的 `category-speedtest`）
- ✅ 同时支持 IPv4 与 IPv6 拦截
- ✅ 支持自定义添加域名或 IP 进行屏蔽
- ✅ 一键启用 / 停用拦截规则
- ✅ 面板式操作界面
- ✅ 停用后自动恢复 DNS 设置，确保节点正常使用
- ✅ 卸载功能（清理所有规则与脚本本体）

---

## ⚙️ 依赖环境

适用于 Debian / Ubuntu 系统（支持 IPv6）。

必须安装以下工具：

```bash
apt update
apt install -y ipset iptables dnsutils curl
```

---

## 📥 安装方法

### 方式一：手动下载脚本

```bash
wget -O /usr/local/bin/blockv2.6.sh https://github.com/kelenetwork/speedtest-blocker/releases/download/v2.6/blockv2.6.sh

chmod +x /usr/local/bin/blockv2.6.sh
```

然后执行：

```bash
blockv2.6.sh
```

### 方式二：创建快捷命令

```bash
ln -s /usr/local/bin/blockv2.6.sh /usr/bin/blockv2
```

此后可直接使用命令 `blockv2` 进入脚本菜单。

---

## 📚 使用说明

执行脚本后将显示如下菜单：

```
==== Speedtest 拦截器 v2.6 ====
[当前状态] ✅/⛔ 拦截状态显示
拦截IP数量: xxx

1. 启用测速拦截
2. 停用测速拦截
3. 自定义屏蔽域名/IP
4. 卸载（清除脚本与拦截规则）
5. 退出
==============================
```

### 功能说明：

- **启用测速拦截**：自动抓取测速域名 → 解析 IP → 使用 ipset + iptables 拦截
- **停用测速拦截**：恢复 iptables 状态，自动恢复 `/etc/resolv.conf`
- **自定义屏蔽域名/IP**：
  - 可添加单个或多个自定义域名/IP（逐行输入）
  - 自动应用至现有拦截列表中
- **卸载脚本**：
  - 清除 ipset/iptables 拦截规则
  - 删除脚本自身，恢复服务器状态

---

## 🧪 示例

启动测速拦截：

```bash
blockv2
# 选择 1
```

添加自定义屏蔽域名：

```bash
blockv2
# 选择 3
# 依提示输入：
speedtest.cn
fast.com
```

停用拦截并恢复 DNS：

```bash
blockv2
# 选择 2
```

---

## 🧼 卸载方法

```bash
blockv2
# 选择 4 卸载所有规则和脚本
```

---

## 💡 注意事项

- 启用拦截后不可访问 Speedtest.net、Fast.com 等测速网站
- 若启用后节点无法访问，请确保 `/etc/resolv.conf` 中 DNS 设置被正确恢复
- 脚本自动备份并恢复原始 DNS 设置

---

## 🔒 脚本安全性说明

- 无需修改 XrayR 或 Xray 配置
- 不监听入站，仅拦截本地转发流量
- 所有操作均基于标准工具（ipset、iptables、dig、curl）

---

## 🧑‍💻 作者

由 [kele（别动）项目](https://github.com/kelenetwork) 发布维护。

后续版本规划（v2.7 及以后）建议功能：

✅ 自动定时刷新测速 IP（每天）

✅ 面板里显示“最后更新时间”

✅ 支持添加屏蔽 IP 段（CIDR）
