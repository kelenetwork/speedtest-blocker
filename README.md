
# Speedtest Blocker v1.2

🚫 严格限制访问测速网站的终端工具，基于 `dnsmasq + iptables`，适用于 **Debian / Ubuntu**。

---

## 🆕 v1.2 更新内容

- ✅ 使用文字交互菜单（非 dialog）
- ✅ 启用后自动配置 dnsmasq 黑洞规则 + iptables DNS 劫持
- ✅ 支持实时状态查看
- ✅ 可随时关闭并清除配置
- ❌ 不再内置卸载功能（建议直接删除脚本文件）

---

## ✅ 使用环境要求

适用于：

- Debian 10/11/12
- Ubuntu 18.04/20.04/22.04
- 任意 VPS、云服务器或本地环境

必须已安装：

```bash
sudo apt update
sudo apt install -y dnsmasq curl iptables
```

---

## 📦 安装使用教程（按步骤执行）

### 📥 第一步：下载脚本

```bash
wget -O speedtest_blocker.sh https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.2/speedtest_blocker_v1.2.sh
```

### 💻 第二步：赋予可执行权限

```bash
chmod +x speedtest_blocker.sh
```

### 🚀 第三步：运行拦截控制脚本

```bash
sudo ./speedtest_blocker.sh
```

---

## 📋 功能菜单说明

- 1️⃣ 启用测速网址拦截  
  → 自动生成 dnsmasq 黑洞规则并开启 DNS 劫持

- 2️⃣ 关闭拦截  
  → 删除规则 + 清除 iptables 劫持

- 3️⃣ 查看当前状态  
  → 显示是否处于启用状态

- 4️⃣ 退出菜单

---

## 🔁 如何更新脚本

```bash
rm speedtest_blocker.sh
wget -O speedtest_blocker.sh https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.2/speedtest_blocker_v1.2.sh
chmod +x speedtest_blocker.sh
```

---

## 🔚 卸载方法

本版本无安装，仅为脚本运行：
- 若要卸载：直接删除脚本文件即可

```bash
rm speedtest_blocker.sh
```

---

## 📜 License

MIT
