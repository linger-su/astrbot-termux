#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - APK 更新检查
# 启动时检查一次，有新版则提示
# ============================================

CURRENT_VERSION="0.0.1"
GITHUB_API="https://api.github.com/repos/linger-su/astrbot-termux/releases/latest"

check_update() {
    local response
    response=$(curl -s --connect-timeout 5 "$GITHUB_API" 2>/dev/null)

    if [ -z "$response" ]; then
        return 1
    fi

    local latest_tag
    latest_tag=$(echo "$response" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')

    if [ -z "$latest_tag" ]; then
        return 1
    fi

    if [ "$latest_tag" != "$CURRENT_VERSION" ]; then
        local download_url
        download_url=$(echo "$response" | grep '"browser_download_url"' | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')
        echo "UPDATE:${latest_tag}:${download_url}"
        return 0
    fi

    return 1
}

result=$(check_update)
if [ $? -eq 0 ] && [ -n "$result" ]; then
    echo "$result"
fi
