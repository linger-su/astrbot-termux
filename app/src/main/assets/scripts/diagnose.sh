#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - 故障诊断脚本
# 检测常见问题并给出修复建议
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ISSUES=0

check() {
    local name=$1
    local cmd=$2
    local fix=$3

    if eval "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
        echo -e "    ${YELLOW}修复: $fix${NC}"
        ISSUES=$((ISSUES + 1))
    fi
}

echo ""
echo "======================================"
echo "  AstrBot APP - 故障诊断"
echo "======================================"
echo ""

# 网络连接
echo -e "${CYAN}网络检查:${NC}"
check "Termux 镜像可达" \
    "curl -s --connect-timeout 3 -o /dev/null https://mirrors.tuna.tsinghua.edu.cn" \
    "检查WiFi/移动数据连接"

check "GitHub API 可达" \
    "curl -s --connect-timeout 3 -o /dev/null https://api.github.com" \
    "可能需要代理或使用国内镜像"

# 存储空间
echo ""
echo -e "${CYAN}存储检查:${NC}"
free_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')
if [ "$free_mb" -gt 500 ]; then
    echo -e "  ${GREEN}✓${NC} 可用空间: ${free_mb}MB"
else
    echo -e "  ${RED}✗${NC} 可用空间不足: ${free_mb}MB"
    echo -e "    ${YELLOW}修复: 清理至少500MB存储空间${NC}"
    ISSUES=$((ISSUES + 1))
fi

# proot-distro
echo ""
echo -e "${CYAN}容器检查:${NC}"
check "proot-distro 已安装" \
    "command -v proot-distro" \
    "pkg install -y proot-distro"

check "NapCat 容器存在" \
    "proot-distro list 2>/dev/null | grep -q napcat" \
    "重新运行初始化: rm ~/.astrbot_initialized && bash ~/init.sh"

# AstrBot
echo ""
echo -e "${CYAN}AstrBot 检查:${NC}"
check "AstrBot 目录存在" \
    "[ -d $HOME/AstrBot ]" \
    "重新运行初始化: rm ~/.astrbot_initialized && bash ~/init.sh"

check "AstrBot 虚拟环境存在" \
    "[ -f $HOME/AstrBot/venv/bin/activate ]" \
    "重新运行初始化: rm ~/.astrbot_initialized && bash ~/init.sh"

check "AstrBot 可启动" \
    "cd $HOME/AstrBot && source venv/bin/activate && python -c 'import astrbot' 2>/dev/null; cd ~" \
    "cd ~/AstrBot && source venv/bin/activate && pip install -r requirements.txt"

# screen
echo ""
echo -e "${CYAN}服务检查:${NC}"
check "screen 已安装" \
    "command -v screen" \
    "pkg install -y screen"

if screen -ls 2>/dev/null | grep -q "napcat"; then
    echo -e "  ${GREEN}✓${NC} NapCat 正在运行"
else
    echo -e "  ${YELLOW}!${NC} NapCat 未运行"
    echo -e "    ${YELLOW}启动: bash ~/start-services.sh${NC}"
fi

if screen -ls 2>/dev/null | grep -q "astrbot"; then
    echo -e "  ${GREEN}✓${NC} AstrBot 正在运行"
else
    echo -e "  ${YELLOW}!${NC} AstrBot 未运行"
    echo -e "    ${YELLOW}启动: bash ~/start-services.sh${NC}"
fi

# 总结
echo ""
echo "======================================"
if [ $ISSUES -eq 0 ]; then
    echo -e "  ${GREEN}未发现问题${NC}"
else
    echo -e "  ${YELLOW}发现 ${ISSUES} 个问题，请按上述建议修复${NC}"
fi
echo "======================================"
