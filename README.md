# Speedtest Blocker v2 使用说明

## 🔧 安装步骤（适用于 Debian / Ubuntu）

### 1. 安装依赖（如未安装）
```bash
sudo apt install -y ipset iptables dnsutils curl
```

### 2. 下载主程序脚本
```bash
sudo curl -o /usr/local/bin/speedtest_blocker_v2.sh -L https://github.com/kelenetwork/speedtest-blocker/releases/download/v2.0/speedtest_blocker_v2.sh

sudo chmod +x /usr/local/bin/speedtest_blocker_v2.sh
```

### 3. 添加快捷命令 blockv2
```bash
sudo curl -o /usr/local/bin/blockv2 \
  -L https://github.com/kelenetwork/speedtest-blocker/releases/download/v2.0/blockv2.sh
sudo chmod +x /usr/local/bin/blockv2
```

---

## 📦 使用方式

```bash
blockv2
```

你将看到文字菜单，可选择：
- 启用测速拦截
- 关闭拦截
- 更新测速域名 IP
- 卸载全部（含脚本自身）

---

## ❌ 卸载命令

可从菜单中选择「卸载」项，或手动执行：

```bash
sudo rm -f /usr/local/bin/speedtest_blocker_v2.sh /usr/local/bin/blockv2
```
