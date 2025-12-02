# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## 项目概述

HaloLight 容器化自托管版本，支持 Docker Compose 一键部署，集成 Traefik 和 Let's Encrypt。

## 技术栈

- **框架**: Next.js 15 + React 19 + TypeScript
- **样式**: Tailwind CSS 4、shadcn/ui
- **容器**: Docker + Docker Compose
- **反向代理**: Traefik v3
- **证书**: Let's Encrypt (自动)
- **数据库**: PostgreSQL 16

## 常用命令

```bash
pnpm dev                    # 本地开发
docker compose up -d        # 启动所有服务
docker compose logs -f      # 查看日志
docker compose down         # 停止服务
docker compose build        # 重新构建
```

## Docker 镜像构建

### 多阶段构建

```dockerfile
# 阶段 1: 依赖安装
FROM node:20-alpine AS deps
# 阶段 2: 构建
FROM node:20-alpine AS builder
# 阶段 3: 运行
FROM node:20-alpine AS runner
```

### Next.js Standalone

启用 standalone 输出减小镜像体积：
```js
// next.config.ts
export default { output: 'standalone' }
```

## 目录结构

```
halolight-docker/
├── docker-compose.yml       # 开发环境
├── docker-compose.prod.yml  # 生产环境
├── Dockerfile               # 应用镜像
├── traefik/                 # Traefik 配置
│   ├── traefik.yml
│   └── acme.json
├── .env.example             # 环境变量模板
└── src/                     # 应用代码
```

## 环境变量

```bash
# 应用
NODE_ENV=production
NEXT_PUBLIC_API_URL=/api

# 数据库
DB_HOST=postgres
DB_PORT=5432
DB_PASSWORD=your-secure-password

# Traefik
DOMAIN=halolight.example.com
ACME_EMAIL=admin@example.com
```

## 生产部署检查清单

- [ ] 配置强密码
- [ ] 启用 HTTPS
- [ ] 配置健康检查
- [ ] 设置资源限制
- [ ] 配置日志轮转
- [ ] 设置备份策略
