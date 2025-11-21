FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --production --silent

FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build --if-present

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app ./
USER node
EXPOSE 5001
CMD ["node", "dist/index.js"]
