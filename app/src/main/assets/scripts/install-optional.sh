#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - 可选依赖安装
# 用法: bash install-optional.sh [1-6/all]
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ASTRBOT_DIR="$HOME/AstrBot"

log() {
    echo -e "$1"
}

install_in_venv() {
    local pkg=$1
    local desc=$2
    log "安装 ${desc}..."
    cd "$ASTRBOT_DIR"
    source venv/bin/activate
    pip install "$pkg" 2>&1 | tail -5
    if [ $? -eq 0 ]; then
        log "${GREEN}${desc} 安装成功${NC}"
    else
        log "${RED}${desc} 安装失败${NC}"
    fi
    deactivate
}

install_all() {
    install_in_venv "faiss-cpu" "faiss-cpu (向量检索)"
    install_in_venv "pillow" "pillow (图像处理)"
    install_in_venv "pydub" "pydub (音频转换)"
    install_in_venv "silk-python" "silk-python (QQ语音)"
    install_in_venv "mcp" "mcp (MCP协议)"
}

show_menu() {
    echo ""
    echo "======================================"
    echo "  AstrBot APP - 可选依赖安装"
    echo "======================================"
    echo ""
    echo "  all  --  全部安装  --  约 120MB"
    echo "  1. faiss-cpu  --  向量检索/语义搜索/RAG  --  约 50MB"
    echo "  2. pillow  --  图像处理/图片生成  --  约 15MB"
    echo "  3. pydub  --  音频格式转换  --  约 8MB"
    echo "  4. silk-python  --  QQ语音消息编码  --  约 3MB"
    echo "  5. mcp  --  MCP协议支持/工具调用  --  约 10MB"
    echo ""
    echo "  用法: bash install-optional.sh [编号/all]"
    echo "  示例: bash install-optional.sh all"
    echo "        bash install-optional.sh 1 3"
    echo "======================================"
}

if [ $# -eq 0 ]; then
    show_menu
    exit 0
fi

for arg in "$@"; do
    case "$arg" in
        all)
            install_all
            ;;
        1)
            install_in_venv "faiss-cpu" "faiss-cpu (向量检索)"
            ;;
        2)
            install_in_venv "pillow" "pillow (图像处理)"
            ;;
        3)
            install_in_venv "pydub" "pydub (音频转换)"
            ;;
        4)
            install_in_venv "silk-python" "silk-python (QQ语音)"
            ;;
        5)
            install_in_venv "mcp" "mcp (MCP协议)"
            ;;
        *)
            log "${YELLOW}未知选项: $arg${NC}"
            show_menu
            ;;
    esac
done

log ""
log "${GREEN}完成！${NC}"
