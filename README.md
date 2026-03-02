# QQ 农场助手 - Docker 自动同步版

本仓库是 [Penty-d/qq-farm-bot-ui](https://github.com/Penty-d/qq-farm-bot-ui) 的独立 Docker 封镜像构建服务。

## 🌟 仓库特色

- **智能构建**：每日自动检查原作者发布的最新版本，一旦检测到核心版本号更新，即刻触发镜像构建。
- **开箱即用**：封装了经过优化的 Dockerfile，内置了中国时区（Asia/Shanghai），确保农场任务时间准确。

## 🚀 快速开始

使用 Docker 快速部署：

```bash
docker run -d \
  --name qq-farm-bot-ui-autoupdate-docker \
  -p 3000:3000 \
  -v ./farm-data:/app/core/data \
  -e ADMIN_PASSWORD=你的管理密码 \
  ghcr.io/versiw/qq-farm-bot-ui-autoupdate-docker:latest
```

## 📝 持久化说明

为了防止容器更新或重启后数据丢失，**请务必挂载** `/app/core/data` 目录。

## 免责声明

本项目仅供学习与研究用途。使用本工具可能违反游戏服务条款，由此产生的一切后果由使用者自行承担。

> **说明**：本项目仅对原项目进行 Docker 容器化封装与自动化分发，核心逻辑版权归原作者所有。