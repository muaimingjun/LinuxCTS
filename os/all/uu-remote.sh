#!/bin/bash

# ====================================================
# UU 远程 Linux（非官方）一键安装 + 获取远程协助码
# 仓库: https://github.com/VallierDev/uu-remote-linux
# 仅支持 Ubuntu 的 .deb 预编译包（amd64 / arm64）
#
# 流程: apt update -> 查最新 Release -> 下载 deb -> 安装
#       -> 后台启动访客协助 -> 输出「设备 ID(远程码) / 验证码」
# ====================================================

set -o pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}$*${NC}"; }
ok()   { echo -e "${GREEN}$*${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }
die()  { echo -e "${RED}$*${NC}" >&2; exit 1; }

REPO="VallierDev/uu-remote-linux"
APP="uuremote-server"
LOG="$HOME/.cache/uuremote-assist.log"
PIDFILE="$HOME/.cache/uuremote-assist.pid"

# ---------- 环境检查 ----------
if [ "$(id -u)" -eq 0 ]; then
    die "请不要用 root 运行：apt 部分会自动 sudo，但远程码必须在桌面用户下获取。"
fi

[ -r /etc/os-release ] || die "无法读取 /etc/os-release"
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
    die "目前仅支持 Ubuntu，当前系统: ${ID:-unknown}"
fi

case "$(uname -m)" in
    x86_64|amd64)  ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) die "不支持的架构: $(uname -m)" ;;
esac

for c in curl sha256sum script sed grep pkill; do
    command -v "$c" >/dev/null 2>&1 || die "缺少命令: $c"
done

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    warn "当前没有图形会话（DISPLAY / WAYLAND_DISPLAY 为空），远程协助可能无法采集桌面画面。"
fi

# ---------- 更新软件源 ----------
info "==> 更新软件源 (apt update)"
sudo apt update || die "apt update 失败"

# ---------- 查询最新版本 ----------
info "==> 查询最新版本"
LATEST=$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest") \
    || die "无法访问 GitHub Releases，请检查网络"
case "$LATEST" in
    */tag/v*) VER="${LATEST##*/tag/v}" ;;
    *) die "无法解析最新版本号: $LATEST" ;;
esac
ok "最新版本: v${VER}"

DEB="uu-remote-linux_${VER}_${ARCH}.deb"
URL="https://github.com/${REPO}/releases/download/v${VER}/${DEB}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

info "==> 下载 ${DEB}"
curl -fL --retry 3 --connect-timeout 15 -o "$TMP/$DEB" "$URL" || die "下载失败: $URL"

# 校验 sha256（Release 附带 .sha256）
EXPECTED=$(curl -fsSL "${URL}.sha256" 2>/dev/null | grep -oE '[0-9a-f]{64}' | head -1)
if [ -n "$EXPECTED" ]; then
    ACTUAL=$(sha256sum "$TMP/$DEB" | cut -d' ' -f1)
    [ "$EXPECTED" = "$ACTUAL" ] || die "sha256 校验失败"
    ok "sha256 校验通过"
else
    warn "未获取到 sha256，跳过校验"
fi

# ---------- 安装 ----------
info "==> 安装 UU 远程（deb 会自动带上 ffmpeg 依赖）"
sudo apt install -y "$TMP/$DEB" || die "安装失败"

# ---------- 启动访客协助并抓取远程码 ----------
mkdir -p "$(dirname "$LOG")"

# 停掉本脚本上一次启动的实例
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null || true
    rm -f "$PIDFILE"
fi
pkill -u "$(id -u)" -f "${APP} assist" 2>/dev/null || true
sleep 1

# script 需要一个 pty：assist 会把远程码写到 /dev/tty，文件权限设为 600
install -m 600 /dev/null "$LOG"

info "==> 启动远程协助（访客模式）"
export UU_ASSIST_UI=tty
export UU_ASSIST_ALLOW=1
export UU_CONFIG="$HOME/.config/uuremote/assist/config.json"
setsid script -q -f -c "${APP} assist" "$LOG" </dev/null >/dev/null 2>&1 &
echo $! > "$PIDFILE"

ID=""
CODE=""
for _ in $(seq 1 45); do
    ID=$(grep -a '设备 ID:' "$LOG" 2>/dev/null | tail -1 | sed 's/.*设备 ID:[[:space:]]*//' | tr -d '\r')
    CODE=$(grep -a '临时验证码:' "$LOG" 2>/dev/null | tail -1 | sed 's/.*临时验证码:[[:space:]]*//' | tr -d '\r')
    [ -n "$ID" ] && [ -n "$CODE" ] && break
    sleep 1
done

if [ -z "$ID" ] || [ -z "$CODE" ]; then
    warn "未能获取远程码，最近的日志："
    tail -n 30 "$LOG" 2>/dev/null
    die "如果日志提示需要桌面环境，请在 Ubuntu 桌面会话的终端里运行本脚本。"
fi

echo
ok "================ UU 远程已就绪 ================"
ok " 远程码 (设备 ID): ${ID}"
ok " 验证码:           ${CODE}"
ok "=============================================="
echo
warn "验证码只保存在本机 ${LOG}（权限 600），不会写入系统日志。"
warn "验证码会按设置刷新；刷新后可查看日志最新一段。"
warn "停止协助: pkill -u $(id -u) -f '${APP} assist'"
warn "卸载:     sudo apt remove -y uu-remote-linux"
