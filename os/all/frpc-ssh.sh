#!/bin/bash

# ====================================================
# 用户自定义配置 (已根据你的 frps 配置填入)
# ====================================================
SERVER_ADDR="frp.wanwuhuanxin.cn"
# 设置远程密码 (SSH 登录 ubuntu 用户时使用)
PASS="123456"
SERVER_PORT=7000
TOKEN="hxSoC6lWW6lTR8O64Xqy0tl6BcSYK5Zx5I3BjaO"
# SSH 免密登录公钥（本机 ~/.ssh/id_ed25519.pub）
# 只放公钥，私钥始终留在本地
SSH_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDN8y9DwubQ1Q+chnRMrejQOkeUw38071/WsRN52TgU+ muaimingjun@gmail.com"
# ====================================================
# 本脚本由 frp.sh + frpc.sh 合并而成：
#   安装 (Live CD 自动设置 SSH 密码) / 卸载 / 退出 一体化管理
# ====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 当前登录用户（SSH 提示用；Live CD 下通常是 ubuntu）
LOGIN_USER="${SUDO_USER:-$(id -un)}"
SET_PASS=0

# 判断当前是否为 Live CD (试用) 环境
is_live_mode() {
    [ -e /run/live/medium ] && return 0           # Ubuntu 22.10+ casper
    [ -e /lib/live/mount/medium ] && return 0     # 旧版 casper
    [ -d /rofs ] && return 0                      # Live 只读根
    local rootfs
    rootfs=$(findmnt -n -o FSTYPE / 2>/dev/null || awk '$2=="/"{print $3; exit}' /proc/mounts)
    [ "$rootfs" = "overlay" ] && return 0         # Live 根文件系统为 overlay
    return 1
}

# 配置 SSH 免密登录公钥
install_ssh_key() {
    local u home
    echo -e "${GREEN}正在配置 SSH 免密登录公钥...${NC}"
    for u in "$LOGIN_USER" ubuntu root; do
        [ -n "$u" ] || continue
        id -u "$u" >/dev/null 2>&1 || continue
        home="$(getent passwd "$u" | cut -d: -f6)"
        [ -n "$home" ] && [ -d "$home" ] || continue
        sudo mkdir -p "$home/.ssh"
        sudo chmod 700 "$home/.ssh"
        sudo touch "$home/.ssh/authorized_keys"
        if ! sudo grep -qxF "$SSH_PUBKEY" "$home/.ssh/authorized_keys"; then
            echo "$SSH_PUBKEY" | sudo tee -a "$home/.ssh/authorized_keys" >/dev/null
        fi
        sudo chmod 600 "$home/.ssh/authorized_keys"
        sudo chown -R "$u":"$(id -gn "$u")" "$home/.ssh"
        echo -e "${GREEN}  已为 $u 配置公钥${NC}"
    done
}

# 安装函数
do_install() {
    echo -e "${GREEN}正在开始安装流程...${NC}"

    # 更新系统并安装依赖
    sudo apt update -y
    sudo apt install -y wget tar ssh curl

    # 配置免密登录公钥（Live CD 与已安装系统均生效）
    install_ssh_key

    # 仅 Live CD（试用）环境需要设置登录密码：Live 用户默认没有可用密码。
    # 已安装的真实机器沿用用户现有密码，此处不做任何修改（也不重启 ssh，避免断开会话）。
    if is_live_mode; then
        echo -e "${YELLOW}检测到 Live CD 环境，正在设置 SSH 登录密码...${NC}"
        for u in ubuntu "$LOGIN_USER"; do
            case "$u" in
                ""|root) continue ;;
            esac
            if id -u "$u" >/dev/null 2>&1; then
                echo "$u:${PASS}" | sudo chpasswd
            fi
        done
        sudo systemctl restart ssh
        SET_PASS=1
    else
        echo -e "${GREEN}检测到已安装的真实系统，跳过密码设置（沿用系统现有登录密码）。${NC}"
    fi

    # 1. 环境准备与停止旧服务
    sudo systemctl stop frpc >/dev/null 2>&1

    # 2. 自动寻找本地管理端口
    check_port() { (echo >/dev/tcp/127.0.0.1/$1) &>/dev/null; return $?; }
    ADMIN_PORT=7400
    while check_port $ADMIN_PORT; do ADMIN_PORT=$((ADMIN_PORT + 1)); done

    # 3. 下载与安装
    # ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    # VERSION=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    # [ -z "$VERSION" ] && VERSION="0.67.0"

    # wget -O frp.tar.gz "https://github.com/fatedier/frp/releases/download/v${VERSION}/frp_${VERSION}_linux_${ARCH}.tar.gz"
    VERSION="0.67.0"
    ARCH="amd64"
    wget -O frp.tar.gz "https://cdn.wanwuhuanxin.cn/app/frp_0.67.0_linux_amd64.tar.gz"
    tar -zxvf frp.tar.gz
    sudo cp -f frp_${VERSION}_linux_${ARCH}/frpc /usr/local/bin/frpc
    sudo chmod +x /usr/local/bin/frpc
    sudo mkdir -p /etc/frp

    # 4. 生成配置 (remotePort = 0 自动获取端口)
    sudo tee /etc/frp/frpc.toml > /dev/null <<EOF
serverAddr = "$SERVER_ADDR"
serverPort = $SERVER_PORT
auth.method = "token"
auth.token = "$TOKEN"

webServer.addr = "127.0.0.1"
webServer.port = $ADMIN_PORT
webServer.user = "admin"
webServer.password = "admin"

[[proxies]]
name = "ssh-$(hostname)"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 0
EOF

    # 5. 设置 Systemd 服务（等待网络完全就绪再启动，防止重启后 DNS 未就绪导致失败）
    sudo tee /etc/systemd/system/frpc.service > /dev/null <<EOF
[Unit]
Description=Frp Client Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable frpc
    sudo systemctl start frpc

    echo -e "${GREEN}服务已启动，正在获取分配端口...${NC}"
    sleep 5

    # 6. 精准抓取逻辑：优先通过 API 获取
    API_URL="http://admin:admin@127.0.0.1:${ADMIN_PORT}/api/status"
    REAL_PORT=$(curl -s "$API_URL" | grep -oE '"remote_addr":"[^"]+"' | grep -oE '[0-9]+' | tail -n 1)

    # 如果 API 没抓到，回退到日志抓取
    if [ -z "$REAL_PORT" ] || [ "$REAL_PORT" == "0" ]; then
        REAL_PORT=$(sudo journalctl -u frpc -n 20 --no-pager | grep "start proxy success" | sed 's/.*://;s/\]//' | tail -n 1)
    fi

    # 7. 清理
    rm -rf frp.tar.gz frp_${VERSION}_linux_${ARCH}

    echo -e "------------------------------------------------"
    if [ -n "$REAL_PORT" ] && [ "$REAL_PORT" != "0" ]; then
        echo -e "${GREEN}安装成功！${NC}"
        echo -e "服务器分配的真实远程端口为: ${RED}${REAL_PORT}${NC}"
        echo -e "SSH 访问: ${GREEN}ssh -p ${REAL_PORT} ${LOGIN_USER}@${SERVER_ADDR}${NC}"
        echo -e "免密登录: ${GREEN}已为 ${LOGIN_USER} / ubuntu / root 配置公钥${NC}"
        echo -e "免密命令: ${GREEN}ssh -i ~/.ssh/id_ed25519 -p ${REAL_PORT} ${LOGIN_USER}@${SERVER_ADDR}${NC}"
        if [ "$SET_PASS" = "1" ]; then
            echo -e "SSH 密码: ${RED}${PASS}${NC} (Live CD 环境已自动设置)"
        else
            echo -e "SSH 密码: ${YELLOW}沿用当前系统用户的登录密码${NC}"
        fi
        echo -e "本地管理面板: 127.0.0.1:${ADMIN_PORT}"
    else
        echo -e "${YELLOW}未能自动获取到端口。${NC}"
        echo -e "请检查服务器 IP ($SERVER_ADDR) 是否正确，或防火墙是否放行了 7000 端口。"
        echo -e "查看实时日志请运行: ${GREEN}sudo journalctl -u frpc -f${NC}"
    fi
    echo -e "------------------------------------------------"
}

# 卸载函数
do_uninstall() {
    echo -e "${RED}正在准备卸载 frpc 客户端...${NC}"

    # 1. 停止并禁用 Systemd 服务
    echo -e "正在停止 frpc 服务..."
    sudo systemctl stop frpc >/dev/null 2>&1
    sudo systemctl disable frpc >/dev/null 2>&1

    # 2. 删除 Systemd 服务文件
    if [ -f /etc/systemd/system/frpc.service ]; then
        sudo rm -f /etc/systemd/system/frpc.service
        sudo systemctl daemon-reload
        echo -e "${GREEN}已移除 Systemd 服务配置。${NC}"
    fi

    # 3. 删除二进制文件
    if [ -f /usr/local/bin/frpc ]; then
        sudo rm -f /usr/local/bin/frpc
        echo -e "${GREEN}已移除 frpc 执行文件。${NC}"
    fi

    # 4. 删除配置文件目录
    if [ -d /etc/frp ]; then
        sudo rm -rf /etc/frp
        echo -e "${GREEN}已移除 /etc/frp 配置文件目录。${NC}"
    fi

    echo -e "------------------------------------------------"
    echo -e "${GREEN}frpc 已成功从系统中卸载！${NC}"
    echo -e "------------------------------------------------"
}

# 菜单逻辑
clear
echo -e "${YELLOW}=== frpc 客户端一键管理脚本 ===${NC}"
echo "1. 安装 frpc (自动获取远程端口)"
echo "2. 卸载 frpc"
echo "3. 退出"
read -p "请选择操作 [1-3]: " choice

case $choice in
    1)
        do_install
        ;;
    2)
        do_uninstall
        ;;
    3)
        exit 0
        ;;
    *)
        echo -e "${RED}输入错误，请运行脚本重新选择。${NC}"
        exit 1
        ;;
esac
