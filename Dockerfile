# -------------------------
# 1. Base image (dependencies stage)
# -------------------------
FROM node:20-alpine AS base

WORKDIR /app

# Install dependencies only when needed
COPY package*.json ./

RUN npm install


# -------------------------
# 2. Build stage
# -------------------------
FROM node:20-alpine AS builder

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY . .

# Build Next.js app
RUN npm run build


# -------------------------
# 3. Production stage (lightweight)
# -------------------------
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy only required output (standalone build)
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000

CMD ["node", "server.js"]