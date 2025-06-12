
# Speedtest Blocker v1.2.1

🚫 严格限制访问测速网站的终端工具，基于 `dnsmasq + iptables`，适用于 **Debian / Ubuntu**

> ✅ 推荐使用最新版：**[Speedtest Blocker v1.2.1 ⬇️](https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.2.1/speedtest_blocker_v1.2.1.sh)**

---

## 🆕 更新内容（v1.2.1）

- ✅ 修复 `[[: not found` 报错（使用 bash 解释器）
- ✅ 状态判断更准确（检测 dnsmasq 是否运行 + 规则是否存在 + iptables 是否生效）
- ✅ 状态菜单中显示当前拦截条数、dnsmasq 状态
- ✅ 完整兼容 Debian / Ubuntu 所有主流版本

---

## 📦 安装使用教程（按步骤执行）

### 1️⃣ 下载脚本

```bash
wget -O speedtest_blocker.sh https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.2.1/speedtest_blocker_v1.2.1.sh
```

### 2️⃣ 赋予执行权限

```bash
chmod +x speedtest_blocker.sh
```

### 3️⃣ 运行脚本（需 sudo 权限）

```bash
sudo ./speedtest_blocker.sh
```

---

## 📋 使用环境要求

适用于：

- Debian 10 / 11 / 12
- Ubuntu 18.04 / 20.04 / 22.04

请先安装依赖：

```bash
sudo apt update
sudo apt install -y dnsmasq curl iptables
```

---

## 🧹 卸载方法

本脚本为解压即用，不安装系统服务，若要卸载请直接删除脚本并禁用拦截功能：

```bash
sudo ./speedtest_blocker.sh   # 菜单选择 2 关闭拦截
rm speedtest_blocker.sh       # 删除脚本
```

---

## 🛡️ 脚本功能说明

- ✅ 从 geosite category-speedtest 获取测速站域名
- ✅ 转换为 dnsmasq 拦截格式：`address=/domain/0.0.0.0`
- ✅ 自动开启 iptables DNS 劫持
- ✅ 全文字菜单界面
