# **************************************************
# 阶段 1: 构建环境
# node:20-slim：使用 Node.js 20 版本的精简版镜像（slim），它只包含运行 Node 所需的最基本环境，体积较小
# AS builder：给这个阶段起个名字叫 builder，方便后面引用
# **************************************************
FROM node:20-slim AS builder

# 安装 pnpm
# 原项目使用了 pnpm 管理依赖Node.js 16+ 版本内置了 corepack 工具，这两行命令可以让你无需手动 npm install -g pnpm 就能直接激活并使用最新版的 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 设置工作目录
# 在容器内创建一个 /app 文件夹，后续所有命令都在这个目录下执行
WORKDIR /app

# 仅复制依赖相关文件，利用 Docker 层缓存
# 只有当 package.json 或 lock 文件变化时，才会重新执行 pnpm install
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY core/package.json ./core/
COPY web/package.json ./web/

# 安装所有依赖
RUN pnpm install --frozen-lockfile

# 构建前端静态文件
RUN pnpm build:web

# **************************************************
# 阶段 2: 运行环境
# 开启一个新的、干净的 Node 环境
# **************************************************
FROM node:20-slim AS prod-deps

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY core/package.json ./core/
COPY web/package.json ./web/

# 仅安装生产环境必需的依赖
RUN pnpm install --prod --frozen-lockfile


# ==========================================
# 阶段 3: 最终运行镜像 (Runner)
# ==========================================
FROM node:20-slim AS runner

WORKDIR /app

# 环境变量默认值
ENV ADMIN_PASSWORD=admin
ENV NODE_ENV=production
ENV TZ=Asia/Shanghai

# 从构建阶段拷贝前端产物到正确位置
COPY --from=builder /app/web/dist ./web/dist

# 拷贝后端源码
COPY --from=builder /app/core ./core

# 拷贝生产依赖
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=prod-deps /app/core/node_modules ./core/node_modules
COPY --from=prod-deps /app/package.json ./package.json

# 拷贝根目录配置
COPY --from=prod-deps /app/pnpm-workspace.yaml ./

# 暴露端口
EXPOSE 3000

# 挂载点：持久化数据
# 非常重要：原项目的账号信息和配置存放在 core/data 下
# 定义了 VOLUME 后，如果你运行容器时忘记挂载目录，Docker 会自动创建一个匿名卷，防止容器删除时你的账号数据丢失
VOLUME ["/app/core/data"]

WORKDIR /app/core

# 生产环境建议直接用 node 运行主入口，比 pnpm dev 更轻量且稳定
CMD ["node", "client.js"]