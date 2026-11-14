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

for c in sha256sum sed grep pkill; do
    command -v "$c" >/dev/null 2>&1 || die "缺少命令: $c"
done

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    warn "当前没有图形会话（DISPLAY / WAYLAND_DISPLAY 为空），远程协助可能无法采集桌面画面。"
fi

# ---------- 更新软件源 ----------
info "==> 更新软件源 (apt update)"
sudo apt update || die "apt update 失败"

# 精简系统可能没有 curl / script，先补上
if ! command -v curl >/dev/null 2>&1; then
    info "==> 安装 curl"
    sudo apt install -y curl || die "安装 curl 失败"
fi
if ! command -v script >/dev/null 2>&1; then
    info "==> 安装 script (util-linux)"
    sudo apt install -y util-linux-extra 2>/dev/null || sudo apt install -y bsdutils || true
fi
command -v curl >/dev/null 2>&1 || die "curl 仍不可用，请手动安装: sudo apt install -y curl"
command -v script >/dev/null 2>&1 || die "script 仍不可用，请手动安装: sudo apt install -y util-linux-extra"

# ---------- 查询最新版本（GitHub 直连 + 国内加速镜像） ----------
GH="https://github.com/${REPO}"
MIRRORS=(
    "https://ghfast.top/"
    "https://gh-proxy.com/"
    "https://gh.llkk.cc/"
    "https://ghproxy.net/"
)

fetch() {
    curl -fsSL --connect-timeout 4 --max-time "${2:-8}" "$1" 2>/dev/null
}

parse_tag() {
    printf '%s' "$1" | grep -oE '/releases/(tag|download)/v[0-9][0-9.]*' | head -1 | sed 's#.*/v##'
}

info "==> 查询最新版本"
VER=""
MIRROR_USED=""
for base in "${MIRRORS[@]}" ""; do
    label="${base:-直连 GitHub}"
    info "    尝试: ${label}"
    # releases.atom 是静态文件，镜像更可能代理；再退到 latest 页面
    VER=$(parse_tag "$(fetch "${base}${GH}/releases.atom")")
    [ -n "$VER" ] && MIRROR_USED="$base" && break
    VER=$(parse_tag "$(fetch "${base}${GH}/releases/latest")")
    [ -n "$VER" ] && MIRROR_USED="$base" && break
done

if [ -z "$VER" ]; then
    info "    尝试: jsDelivr"
    VER=$(fetch "https://data.jsdelivr.com/v1/packages/gh/${REPO}" 15 \
        | grep -oE '"version":"v?[0-9][0-9.]*"' \
        | sed 's/.*:"v\?//;s/"$//' | sort -V | tail -1)
fi
[ -n "$VER" ] || die "无法获取最新版本号：GitHub 与镜像均不可用，请检查网络"
ok "最新版本: v${VER}"

DEB="uu-remote-linux_${VER}_${ARCH}.deb"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ---------- 获取 sha256（优先直连 GitHub，其次镜像） ----------
EXPECTED=""
for base in "" "${MIRRORS[@]}"; do
    EXPECTED=$(fetch "${base}${GH}/releases/download/v${VER}/${DEB}.sha256" 10 | grep -oE '[0-9a-f]{64}' | head -1)
    [ -n "$EXPECTED" ] && break
done

# ---------- 测速选源（各源取前 1MB，选最快的） ----------
deb_url() { printf '%s' "$1${GH}/releases/download/v${VER}/${DEB}"; }

info "==> 测速选择下载源"
BEST_BASE="__none__"
BEST_SPEED=0
for base in "${MIRRORS[@]}" ""; do
    label="${base:-直连 GitHub}"
    speed=$(curl -fsL -r 0-1048575 --connect-timeout 4 --max-time 6 -o /dev/null \
        -w '%{speed_download}' "$(deb_url "$base")" 2>/dev/null || true)
    case "$speed" in ''|*[!0-9.]*) speed=0 ;; esac
    printf '    %-28s %s KB/s\n' "$label" "$(awk -v s="$speed" 'BEGIN{printf "%.0f", s/1024}')"
    if awk -v a="$speed" -v b="$BEST_SPEED" 'BEGIN{exit !(a>b)}'; then
        BEST_SPEED="$speed"
        BEST_BASE="$base"
    fi
done
[ "$BEST_BASE" = "__none__" ] && BEST_BASE=""
if awk -v s="$BEST_SPEED" 'BEGIN{exit !(s < 102400)}'; then
    warn "所有源测速都偏慢（<100 KB/s），可能是网络高峰或镜像限速，下载会比较久。"
fi

# ---------- 下载 deb（先最快源，再逐个回退） ----------
info "==> 下载 ${DEB}"
DEB_OK=0
DEB_BASE=""
SEEN=" "
for base in "$BEST_BASE" "${MIRRORS[@]}" ""; do
    key="${base:-direct}"
    case "$SEEN" in *" $key "*) continue ;; esac
    SEEN="$SEEN$key "
    label="${base:-直连 GitHub}"
    info "    尝试: ${label}"
    if ! curl -fL --connect-timeout 8 --max-time 900 --retry 1 \
        --speed-time 30 --speed-limit 1024 \
        -o "$TMP/$DEB" "$(deb_url "$base")"; then
        continue
    fi
    if [ -n "$EXPECTED" ]; then
        ACTUAL=$(sha256sum "$TMP/$DEB" | cut -d' ' -f1)
        if [ "$ACTUAL" != "$EXPECTED" ]; then
            warn "    sha256 不匹配，换下一个源"
            rm -f "$TMP/$DEB"
            continue
        fi
    fi
    DEB_OK=1
    DEB_BASE="$base"
    break
done
[ "$DEB_OK" = "1" ] || die "下载失败：GitHub 与镜像均不可用，或镜像内容校验不通过"

if [ -n "$EXPECTED" ]; then
    ok "sha256 校验通过"
else
    warn "未获取到 sha256，跳过校验"
fi
if [ -n "$DEB_BASE" ]; then
    ok "下载源: ${DEB_BASE}"
else
    ok "下载源: 直连 GitHub"
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
