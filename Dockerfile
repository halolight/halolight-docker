FROM node:18-alpine AS builder
ENV PNPM_HOME="/root/.local/share/pnpm" \
    NODE_ENV=production
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# 仅复制依赖清单以利用缓存
COPY package.json pnpm-lock.yaml* package-lock.json* npm-shrinkwrap.json* ./
RUN pnpm install --frozen-lockfile

# 复制其余源码并构建
COPY . .
RUN pnpm run build

# 运行阶段
FROM node:18-alpine AS runner
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

WORKDIR /app
RUN apk add --no-cache curl \
 && addgroup -S nodejs && adduser -S node -G nodejs

# 复制 standalone 产物
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER node
EXPOSE 3000

# 健康检查（若有 /health 路由可替换）
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -fs http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
