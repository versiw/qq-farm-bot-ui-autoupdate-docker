# 阶段 1: 构建环境
FROM node:20-slim AS builder

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 注意：在 GitHub Action 中，我们会先把源码拉取到当前目录
COPY . .

# 安装所有依赖
RUN pnpm install

# 构建前端静态文件
RUN pnpm build:web

# 阶段 2: 运行环境
FROM node:20-slim

WORKDIR /app

# 从构建阶段复制必要文件
COPY --from=builder /app /app

# 暴露端口
EXPOSE 3000

# 环境变量默认值（可以在运行容器时覆盖）
ENV ADMIN_PASSWORD=admin
ENV NODE_ENV=production

# 挂载点：持久化数据
VOLUME ["/app/core/data"]

# 启动命令
CMD ["pnpm", "dev:core"]