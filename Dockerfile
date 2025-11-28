# 第一阶段：拉取代码并构建
FROM node:22.12-alpine AS builder

# 使用阿里云镜像加速并安装 git 和 pnpm
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache git && \
    npm config set registry https://registry.npmmirror.com && \
    npm install -g pnpm && \
    pnpm config set registry https://registry.npmmirror.com


# 设置工作目录
WORKDIR /app

# 克隆项目代码
RUN git clone https://github.com/trebleC/note-app.git .


# 安装依赖
RUN pnpm install --frozen-lockfile

# 构建项目
RUN pnpm run build

# 第二阶段：使用 nginx 部署
FROM nginx:alpine

# 从构建阶段复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
RUN echo 'server { \
    listen 8043; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api { \
        proxy_pass http://host.docker.internal:6090; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 8043

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
