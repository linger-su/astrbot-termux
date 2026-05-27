#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - 初始化脚本
# 首次启动自动执行，安装 AstrBot + NapCat
# ============================================
set -euo pipefail

# --- 常量 ---
HOME_DIR="$HOME"
MARKER_FILE="$HOME_DIR/.astrbot_initialized"
STEP_DIR="$HOME_DIR/.astrbot_steps"
LOG_FILE="$HOME_DIR/.astrbot_init.log"
SOURCES_CONF="$HOME_DIR/sources.conf"

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- 函数 ---
log() {
    local msg="[$(date '+%H:%M:%S')] $1"
    echo -e "$msg" | tee -a "$LOG_FILE"
}

# 向主界面输出进度
progress() {
    local step=$1
    local total=$2
    local desc=$3
    local pct=$((step * 100 / total))
    echo "PROGRESS:${pct}" >&2
    log "${CYAN}[${step}/${total}]${NC} ${desc}"
}

# 标记步骤完成
mark_step() {
    mkdir -p "$STEP_DIR"
    touch "$STEP_DIR/$1"
}

# 检查步骤是否已完成
is_step_done() {
    [ -f "$STEP_DIR/$1" ]
}

# 检测网络环境（国内/海外）
detect_network() {
    if curl -s --connect-timeout 3 -o /dev/null "https://mirrors.tuna.tsinghua.edu.cn" 2>/dev/null; then
        echo "china"
    else
        echo "official"
    fi
}

# 输出完成信息
show_completion() {
    local napcat_port=6099
    local astrbot_port=6185

    echo ""
    echo "======================================"
    log "${GREEN}安装完成！${NC}"
    echo ""
    log "NapCat WebUI: http://localhost:${napcat_port}"
    log "  (打开后扫码登录QQ)"
    log "AstrBot WebUI: http://localhost:${astrbot_port}"
    echo ""
    echo "  可选依赖可增强功能（按推荐顺序）："
    echo ""
    echo "  all  --  全部安装  --  约 120MB"
    echo "  1. faiss-cpu  --  向量检索/语义搜索/RAG  --  约 50MB"
    echo "  2. pillow  --  图像处理/图片生成  --  约 15MB"
    echo "  3. pydub  --  音频格式转换  --  约 8MB"
    echo "  4. silk-python  --  QQ语音消息编码  --  约 3MB"
    echo "  5. mcp  --  MCP协议支持/工具调用  --  约 10MB"
    echo ""
    echo "  安装命令：bash ~/install-optional.sh [编号/all]"
    echo "======================================"
}

# 故障诊断
diagnose() {
    local step=$1
    local error=$2
    log "${RED}步骤 [${step}] 失败：${error}${NC}"
    echo ""
    echo "DIAGNOSE:${step}:${error}" >&2

    # 网络检测
    if ! curl -s --connect-timeout 5 -o /dev/null "https://mirrors.tuna.tsinghua.edu.cn" 2>/dev/null; then
        if ! curl -s --connect-timeout 5 -o /dev/null "https://packages.termux.dev" 2>/dev/null; then
            log "${YELLOW}诊断：网络连接失败，请检查网络后重试${NC}"
            echo "DIAGNOSE_FIX:网络连接失败:请检查WiFi或移动数据连接，确保网络畅通后重启应用" >&2
            return
        fi
    fi

    # 存储空间检测
    local free_mb=$(df -m "$HOME_DIR" | awk 'NR==2 {print $4}')
    if [ "$free_mb" -lt 500 ]; then
        log "${YELLOW}诊断：存储空间不足（剩余 ${free_mb}MB）${NC}"
        echo "DIAGNOSE_FIX:存储空间不足:请清理至少500MB存储空间后重启应用" >&2
        return
    fi

    # 通用处理
    echo "DIAGNOSE_FIX:安装步骤失败:${step} - ${error}，请重启应用重试（已安装的依赖会自动跳过）" >&2
}

# ============================================
# 主流程
# ============================================

# 加载源配置
if [ -f "$SOURCES_CONF" ]; then
    source "$SOURCES_CONF"
fi

# 检测网络
NETWORK=$(detect_network)
log "网络环境: $NETWORK"

# 如果已完成初始化，直接启动服务
if [ -f "$MARKER_FILE" ]; then
    log "已完成初始化，启动服务..."
    bash ~/start-services.sh
    exit 0
fi

TOTAL_STEPS=7

# --- Step 1: 配置镜像源 ---
if ! is_step_done "1_mirror"; then
    progress 1 $TOTAL_STEPS "配置镜像源"

    if [ "$NETWORK" = "china" ]; then
        sed -i "s@packages.termux.dev@${TERMUX_MIRROR_CN}@" \
            $PREFIX/etc/apt/sources.list 2>/dev/null || true
        log "已配置清华镜像源"
    else
        log "使用官方源"
    fi

    mark_step "1_mirror"
fi

# --- Step 2: 更新系统 ---
if ! is_step_done "2_update"; then
    progress 2 $TOTAL_STEPS "更新系统包"

    pkg update -y 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "2_update" "pkg update 失败"
        exit 1
    }
    pkg upgrade -y 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "2_update" "pkg upgrade 失败"
        exit 1
    }

    mark_step "2_update"
fi

# --- Step 3: 安装基础依赖 ---
if ! is_step_done "3_base_deps"; then
    progress 3 $TOTAL_STEPS "安装基础依赖"

    pkg install -y proot-distro screen curl wget git 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "3_base_deps" "基础包安装失败"
        exit 1
    }

    mark_step "3_base_deps"
fi

# --- Step 4: 安装 Termux 原生依赖（AstrBot 用）---
if ! is_step_done "4_termux_deps"; then
    progress 4 $TOTAL_STEPS "安装 Termux 原生依赖"

    # Python 和编译工具链
    pkg install -y python python-pip clang rust make pkg-config \
        libffi openssl 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "4_termux_deps" "Python/编译工具安装失败"
        exit 1
    }

    # Node.js（部分 AstrBot 插件需要）
    pkg install -y nodejs-lts 2>&1 | tee -a "$LOG_FILE" || {
        log "${YELLOW}Node.js 安装失败，AstrBot 核心功能不受影响${NC}"
    }

    # ffmpeg（音频处理）
    pkg install -y ffmpeg 2>&1 | tee -a "$LOG_FILE" || {
        log "${YELLOW}ffmpeg 安装失败，音频功能可能受限${NC}"
    }

    mark_step "4_termux_deps"
fi

# --- Step 5: 安装 NapCat（proot 容器内）---
if ! is_step_done "5_napcat"; then
    progress 5 $TOTAL_STEPS "安装 NapCatQQ（约3-5分钟）"

    # 下载 NapCat Termux 安装脚本
    if [ "$NETWORK" = "china" ]; then
        NAPCAT_URL="$NAPCAT_SCRIPT_URL"  # nclatest.znin.net 国内可访问
    else
        NAPCAT_URL="$NAPCAT_SCRIPT_URL"
    fi

    curl -sL "$NAPCAT_URL" -o "$HOME_DIR/napcat.termux.sh" 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "5_napcat" "NapCat 脚本下载失败"
        exit 1
    }

    # 执行安装（非交互模式）
    bash "$HOME_DIR/napcat.termux.sh" 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "5_napcat" "NapCat 安装失败"
        # 清理失败的安装，允许重试
        proot-distro remove napcat 2>/dev/null || true
        mark_step "5_napcat_failed"
        exit 1
    }

    mark_step "5_napcat"
fi

# --- Step 6: 安装 AstrBot（Termux 原生）---
if ! is_step_done "6_astrbot"; then
    progress 6 $TOTAL_STEPS "安装 AstrBot（约5-10分钟）"

    # 配置 pip 镜像
    if [ "$NETWORK" = "china" ]; then
        pip config set global.index-url "$PIP_INDEX_CN" 2>/dev/null || true
        pip config set global.trusted-host "pypi.tuna.tsinghua.edu.cn" 2>/dev/null || true
    fi

    # 克隆 AstrBot
    cd "$HOME_DIR"
    if [ "$NETWORK" = "china" ]; then
        git clone --depth 1 "$ASTRBOT_REPO_CN" AstrBot 2>&1 | tee -a "$LOG_FILE" || {
            diagnose "6_astrbot" "AstrBot 克隆失败"
            exit 1
        }
    else
        git clone --depth 1 "$ASTRBOT_REPO_OFFICIAL" AstrBot 2>&1 | tee -a "$LOG_FILE" || {
            diagnose "6_astrbot" "AstrBot 克隆失败"
            exit 1
        }
    fi

    cd AstrBot

    # 创建虚拟环境
    python -m venv venv 2>&1 | tee -a "$LOG_FILE" || {
        diagnose "6_astrbot" "虚拟环境创建失败"
        exit 1
    }
    source venv/bin/activate

    # 安装 uv（快速包管理器）
    pip install uv 2>&1 | tee -a "$LOG_FILE" || {
        log "${YELLOW}uv 安装失败，使用 pip 直接安装${NC}"
    }

    # 安装依赖
    if command -v uv &>/dev/null; then
        uv pip install -r requirements.txt 2>&1 | tee -a "$LOG_FILE" || {
            log "${YELLOW}部分依赖安装失败，尝试继续...${NC}"
        }
        uv pip install socksio pilk 2>&1 | tee -a "$LOG_FILE" || true
    else
        pip install -r requirements.txt 2>&1 | tee -a "$LOG_FILE" || {
            log "${YELLOW}部分依赖安装失败，尝试继续...${NC}"
        }
        pip install socksio pilk 2>&1 | tee -a "$LOG_FILE" || true
    fi

    deactivate

    mark_step "6_astrbot"
fi

# --- Step 7: 配置启动脚本 ---
if ! is_step_done "7_startup"; then
    progress 7 $TOTAL_STEPS "配置启动脚本"

    # 复制启动脚本
    mkdir -p ~/.termux/boot/
    cp ~/start-services.sh ~/.termux/boot/start-services.sh 2>/dev/null || true
    chmod +x ~/.termux/boot/start-services.sh 2>/dev/null || true
    chmod +x ~/start-services.sh 2>/dev/null || true

    # 复制可选依赖安装脚本
    chmod +x ~/install-optional.sh 2>/dev/null || true

    mark_step "7_startup"
fi

# --- 完成 ---
touch "$MARKER_FILE"
show_completion

# 自动启动服务
bash ~/start-services.sh
