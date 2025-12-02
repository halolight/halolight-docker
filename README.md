# HaloLight Docker

[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Available-2496ED.svg?logo=docker)](https://hub.docker.com/r/halolight/halolight-docker)
[![Next.js](https://img.shields.io/badge/Next.js-15-%23000000.svg)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-%233178C6.svg)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-19-%2361DAFB.svg)](https://react.dev/)

HaloLight 后台管理系统的 **容器化自托管版本**，支持 Docker Compose 一键部署，集成 Traefik 反向代理和 Let's Encrypt 自动证书。

- 在线预览：<https://halolight-docker.h7ml.cn>
- GitHub：<https://github.com/halolight/halolight-docker>

## 功能亮点

- **Docker Compose**：一键启动完整环境
- **Traefik 反向代理**：自动路由和负载均衡
- **Let's Encrypt**：自动 HTTPS 证书
- **多阶段构建**：优化镜像体积
- **健康检查**：容器健康监控
- **日志管理**：集中日志收集

## 快速开始

### 使用 Docker Compose

```bash
# 克隆仓库
git clone https://github.com/halolight/halolight-docker.git
cd halolight-docker

# 复制环境变量
cp .env.example .env

# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f
```

### 仅运行应用

```bash
# 拉取镜像
docker pull halolight/halolight-docker:latest

# 运行容器
docker run -d \
  --name halolight \
  -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=/api \
  halolight/halolight-docker:latest
```

## Docker 配置

### Dockerfile

```dockerfile
# 构建阶段
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# 运行阶段
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=/api
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.halolight.rule=Host(`halolight.example.com`)"
      - "traefik.http.routers.halolight.tls.certresolver=letsencrypt"

  traefik:
    image: traefik:v3.0
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik:/etc/traefik

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: halolight
      POSTGRES_USER: halolight
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## 生产部署

### 1. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 配置域名、数据库密码等
```

### 2. 配置 Traefik

```yaml
# traefik/traefik.yml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /etc/traefik/acme.json
      httpChallenge:
        entryPoint: web
```

### 3. 启动服务

```bash
docker compose -f docker-compose.prod.yml up -d
```

## 健康检查

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## 相关链接

- [HaloLight 文档](https://halolight.docs.h7ml.cn)
- [Docker 文档](https://docs.docker.com/)
- [Traefik 文档](https://doc.traefik.io/traefik/)

## 许可证

[MIT](LICENSE)
