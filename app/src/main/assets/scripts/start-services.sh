#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - 服务启动脚本
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 防止休眠
termux-wake-lock 2>/dev/null || true

log() {
    echo -e "$1"
}

# 检查 screen 会话是否存在
screen_exists() {
    screen -ls 2>/dev/null | grep -q "$1"
}

# 启动 NapCat
start_napcat() {
    if screen_exists "napcat"; then
        log "${YELLOW}NapCat 已在运行${NC}"
    else
        screen -dmS napcat bash -c \
            'proot-distro sh napcat -- bash -c "xvfb-run -a /root/Napcat/opt/QQ/qq --no-sandbox"'
        sleep 2
        if screen_exists "napcat"; then
            log "${GREEN}NapCat 已启动${NC}"
        else
            log "${YELLOW}NapCat 启动可能需要首次扫码配置${NC}"
        fi
    fi
}

# 启动 AstrBot
start_astrbot() {
    if screen_exists "astrbot"; then
        log "${YELLOW}AstrBot 已在运行${NC}"
    else
        if [ -d "$HOME/AstrBot" ] && [ -f "$HOME/AstrBot/venv/bin/activate" ]; then
            screen -dmS astrbot bash -c \
                'cd ~/AstrBot && source venv/bin/activate && python main.py'
            sleep 2
            if screen_exists "astrbot"; then
                log "${GREEN}AstrBot 已启动${NC}"
            else
                log "${YELLOW}AstrBot 启动失败，请检查日志: screen -r astrbot${NC}"
            fi
        else
            log "${YELLOW}AstrBot 未安装或安装不完整${NC}"
        fi
    fi
}

# 启动内存监控
start_guard() {
    if screen_exists "guard"; then
        return
    fi
    if [ -f "$HOME/memory-guard.sh" ]; then
        screen -dmS guard bash -c 'bash ~/memory-guard.sh'
    fi
}

# 主流程
log "======================================"
log "  AstrBot APP - 启动服务"
log "======================================"

start_napcat
sleep 3
start_astrbot
start_guard

log ""
log "======================================"
log "  服务已启动"
log ""
log "  NapCat WebUI: http://localhost:6099"
log "  AstrBot WebUI: http://localhost:6185"
log ""
log "  查看日志:"
log "    screen -r napcat   (NapCat)"
log "    screen -r astrbot  (AstrBot)"
log ""
log "  退出日志: Ctrl+A 然后按 D"
log "======================================"
