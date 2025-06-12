
# speedtest-blocker

终端测速网站拦截工具，基于 `dnsmasq + geosite category-speedtest`，支持一键启用、关闭、更新规则，以及卸载功能。

---

## ✅ 功能特色

- 📶 拦截所有常见测速站点（如 speedtest.net、fast.com）
- 🔧 使用 v2fly geosite:category-speedtest 最新规则
- 📋 提供终端文字菜单界面，支持：
  - 启用测速拦截
  - 禁用测速拦截
  - 更新测速域名列表
  - 卸载脚本与 alias

---

## 📦 安装方式

### 方法一：`.deb` 安装包（适用于 Debian / Ubuntu）

```bash
wget -O /tmp/speedtest-blocker.deb "https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.1/speedtest-blocker_1.1_all.deb" && \
dpkg -i /tmp/speedtest-blocker.deb && \
rm /tmp/speedtest-blocker.deb
```

> 安装后终端输入 `block` 即可启动面板

---

### 方法二：`.tar.gz` 解压即用（适用于所有 Linux 系统）

```bash
wget https://github.com/kelenetwork/speedtest-blocker/releases/download/v1.1/speedtest-blocker.tar.gz
tar -xzf speedtest-blocker.tar.gz
cd speedtest-blocker
sudo ./speedtest_blocker.sh
```

---

## 🧰 依赖要求

请确保已安装以下依赖：

```bash
apt install -y dnsmasq curl dialog
```

---

## 🧹 卸载方法

- 使用菜单中的第 4 项即可卸载脚本和快捷命令
- `.deb` 安装用户也可以执行：

```bash
sudo dpkg -r speedtest-blocker
```

---

## 📄 授权协议

MIT License
