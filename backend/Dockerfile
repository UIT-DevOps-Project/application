# STAGE 1: Build dependencies & Prisma
FROM node:20-bullseye-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY prisma ./prisma
COPY src ./src

RUN npx prisma generate

# STAGE 2: Runtime
FROM node:20-bullseye-slim AS production

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma

USER node

EXPOSE 3000

HEALTHCHECK CMD curl -f http://localhost:3000 || exit 1

CMD ["node", "src/server.js"]
