FROM node:20-bookworm-slim AS builder

WORKDIR /app

# Cài openssl cho Prisma
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm ci --omit=dev

COPY prisma ./prisma
COPY src ./src

RUN npx prisma generate

# STAGE 2: Runtime | Chỉ cần chạy code không cần cài đặt code
FROM node:20-bookworm-slim AS production

WORKDIR /app

# Cài đặt curl để phục vụ cho lệnh HEALTHCHECK bên dưới
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# 2. Xóa Yarn (vì Bookworm có sẵn Yarn dính nhiều lỗi bảo mật trong /opt/yarn)
RUN rm -rf /opt/yarn* /usr/local/bin/yarn /usr/local/bin/yarnpkg

# Copy file từ builder và gán quyền cho user 'node' có sẵn của image
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/src ./src
COPY --chown=node:node --from=builder /app/package*.json ./
COPY --chown=node:node --from=builder /app/prisma ./prisma

# 3. Xóa sạch NPM/YARN để Trivy không còn gì để soi mói
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /opt/yarn*

USER node

EXPOSE 3000

# Lệnh này giờ sẽ hoạt động trơn tru vì curl đã được cài
HEALTHCHECK CMD curl -f http://localhost:3000 || exit 1

# 4. Lệnh chạy app thông minh: Tự tìm engine và khởi động
CMD ["sh", "-c", "export PRISMA_QUERY_ENGINE_LIBRARY=$(ls /app/node_modules/.prisma/client/libquery_engine-*.so.node | head -n 1) && node src/server.js"]