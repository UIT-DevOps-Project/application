FROM node:20-bookworm-slim AS builder

WORKDIR /app

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

# Xóa npm và npx để giảm kích thước image, vì chúng không cần thiết cho runtime và 
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

# Copy file từ builder và gán quyền cho user 'node' có sẵn của image
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/src ./src
COPY --chown=node:node --from=builder /app/package*.json ./
COPY --chown=node:node --from=builder /app/prisma ./prisma

USER node

EXPOSE 3000

# Lệnh này giờ sẽ hoạt động trơn tru vì curl đã được cài
HEALTHCHECK CMD curl -f http://localhost:3000 || exit 1

CMD ["node", "src/server.js"]