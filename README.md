# AstrBot APP

> 基于 Termux 的 AstrBot + NapCatQQ 一键部署方案，让 QQ 机器人在 Android 上开箱即用。

## 简介

AstrBot APP 将 [AstrBot](https://github.com/AstrBotDevs/AstrBot) 和 [NapCatQQ](https://github.com/NapNeko/NapCatQQ) 封装为 Android 应用，基于 [Termux](https://github.com/termux/termux-app) 构建。首次启动自动安装全部依赖，无需 root、无需电脑，一部 Android 手机即可运行完整的 QQ AI 聊天机器人。

## 能力

- **AstrBot** — 多平台 LLM 聊天机器人与 Agent 开发框架，支持 OpenAI、Claude、Gemini、通义千问等主流大模型
- **NapCatQQ** — 基于 NTQQ 的现代化 Bot 协议端，实现 OneBot 11 标准协议
- **混合部署架构** — AstrBot 原生运行 + NapCat 在 proot 容器中运行，资源占用最优
- **一键初始化** — 首次启动自动安装所有依赖，终端实时显示进度和预估时间
- **WebUI 管理** — 内置 NapCat 和 AstrBot 的 WebUI 入口，点击即用浏览器打开
- **开机自启** — 可选的开机自启动，后台持续运行
- **故障自检** — 安装失败自动诊断，给出修复建议
- **双套下载源** — 自动检测网络环境，国内用户自动使用镜像源加速

## 操作指南

### 环境要求

| 项目 | 要求 |
|------|------|
| 系统 | Android 7.0+ |
| 架构 | ARM64 (aarch64) |
| 存储 | 至少 2GB 可用空间 |
| 内存 | 建议 4GB+ RAM |
| 网络 | 稳定的网络连接（首次安装需下载约 500MB 数据） |

> **建议在 WiFi 环境下安装**，首次安装耗时约 5-15 分钟，取决于网络速度。

### 安装步骤

1. 从 [Releases](https://github.com/linger-su/astrbot-termux/releases) 下载最新版 APK
2. 安装并打开 AstrBot APP
3. 首次启动将自动初始化，终端会实时显示安装进度
4. 安装完成后，终端会显示 WebUI 地址
5. 在浏览器中访问 WebUI 进行配置：
   - **NapCat WebUI**: `http://localhost:6099` — 扫码登录 QQ
   - **AstrBot WebUI**: `http://localhost:6185` — 配置机器人和大模型

### 注意事项

- **首次安装耗时较长**（5-15分钟），请勿中途退出，应用会显示预估剩余时间
- **请允许所有请求的权限**，包括存储、网络、后台运行等
- **小米/红米用户**：建议在「设置 → 应用管理 → AstrBot APP → 自启动」中开启自启动权限，以确保后台持续运行
- **如安装失败**，应用会自动诊断原因并给出修复建议，重启应用即可重试（已安装的依赖会自动跳过）
- **确保设备有足够的存储空间**（建议至少 2GB 可用）
- **WebSocket 通信**：AstrBot 与 NapCat 通过 localhost WebSocket 连接，无网络延迟

### 可选依赖

安装完成后，可运行以下命令安装增强功能的可选依赖：

```bash
bash ~/install-optional.sh all    # 全部安装
bash ~/install-optional.sh 1 3    # 只安装第1和第3项
```

| 编号 | 依赖 | 作用 | 大小 |
|------|------|------|------|
| 1 | faiss-cpu | 向量检索 / 语义搜索 / RAG | 约 50MB |
| 2 | pillow | 图像处理 / 图片生成 | 约 15MB |
| 3 | pydub | 音频格式转换 | 约 8MB |
| 4 | silk-python | QQ 语音消息编码 | 约 3MB |
| 5 | mcp | MCP 协议支持 / 工具调用 | 约 10MB |

### 管理服务

```bash
# 查看服务状态
screen -ls

# 查看 NapCat 日志
screen -r napcat

# 查看 AstrBot 日志
screen -r astrbot

# 退出日志（不停止服务）
# 按 Ctrl+A，然后按 D

# 重启服务
bash ~/start-services.sh

# 故障诊断
bash ~/diagnose.sh
```

## 相关文档

- [AstrBot 官方文档](https://docs.astrbot.app/)
- [AstrBot GitHub](https://github.com/AstrBotDevs/AstrBot)
- [NapCatQQ 官方文档](https://napcat.napneko.icu/)
- [NapCatQQ GitHub](https://github.com/NapNeko/NapCatQQ)
- [Termux Wiki](https://wiki.termux.com/)

## 总结

AstrBot APP 让你在 Android 设备上轻松运行 QQ 机器人，无需电脑、无需服务器。只需安装 APK，等待初始化完成，即可通过 WebUI 管理你的 AI 聊天机器人。采用混合部署架构（AstrBot 原生 + NapCat proot），资源占用最优，适合作为个人 AI 助手长期运行。

## 致谢

- [Termux](https://github.com/termux/termux-app) — Android 终端模拟器，提供 Linux 环境
- [AstrBot](https://github.com/AstrBotDevs/AstrBot) — 多平台 LLM 聊天机器人与 Agent 开发框架
- [NapCatQQ](https://github.com/NapNeko/NapCatQQ) — 基于 NTQQ 的现代化 Bot 协议端
- [proot-distro](https://github.com/termux/proot-distro) — Termux 容器化方案
- [NapCat-Installer](https://github.com/NapNeko/NapCat-Installer) — NapCat 一键安装脚本

## 许可证

本项目基于 GPLv3 许可证开源。AstrBot 基于 AGPL-3.0 许可证，NapCatQQ 使用混合许可证。

---

**下载地址**: [GitHub Releases](https://github.com/linger-su/astrbot-termux/releases)
