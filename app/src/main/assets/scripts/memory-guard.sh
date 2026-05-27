#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# AstrBot APP - 内存监控
# 定期检查内存，不足时通知用户
# ============================================

WARN_THRESHOLD_MB=500
CHECK_INTERVAL=60

while true; do
    # 获取可用内存（MB）
    free_mb=$(free -m 2>/dev/null | awk '/^Mem:/ {print $7}')

    if [ -n "$free_mb" ] && [ "$free_mb" -lt "$WARN_THRESHOLD_MB" ]; then
        termux-notification \
            --title "AstrBot APP" \
            --content "可用内存不足 ${free_mb}MB，建议关闭其他应用" \
            --priority high 2>/dev/null || true
    fi

    sleep "$CHECK_INTERVAL"
done
