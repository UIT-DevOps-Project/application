# STAGE 1: Builder
FROM node:22.17.0-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Cài đặt dependencies
RUN npm ci

COPY . .

RUN npm run build 

# STAGE 2: Runtime
FROM nginx:1.27-alpine

# Lệnh mới: Ép Alpine cập nhật toàn bộ thư viện lên bản vá mới nhất
RUN apk update && apk upgrade --no-cache

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Cấu hình Rootless (Tạo user)
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Cấp quyền sở hữu các thư mục cấu hình Nginx cho appuser
RUN chown -R appuser:appuser /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html
RUN touch /var/run/nginx.pid && chown -R appuser:appuser /var/run/nginx.pid

# Copy source đã build và gán quyền sở hữu luôn cho appuser
COPY --chown=appuser:appuser --from=builder /app/dist /usr/share/nginx/html 

# Copy script khởi động và cấp quyền thực thi
COPY --chown=appuser:appuser entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Chuyển sang user thường
USER appuser

# QUAN TRỌNG: User thường không thể mở port < 1024. Phải chuyển sang 8080.
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]