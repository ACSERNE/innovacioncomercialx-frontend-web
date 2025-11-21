#!/bin/bash
set -e

echo "🚀 Creando archivos Docker y .env..."

# 1️⃣ .env
cat << EENV > .env
# PostgreSQL
DB_USER=admin
DB_PASSWORD=1234
DB_NAME=innovacion
DB_HOST=postgres-innovacion
DB_PORT=5432

# PgAdmin
PGADMIN_DEFAULT_EMAIL=admin@admin.com
PGADMIN_DEFAULT_PASSWORD=admin
EENV

# 2️⃣ docker-compose.yml
cat << DCOMPOSE > docker-compose.yml
services:
  backend:
    build: ./backend
    container_name: comercialx-backend
    ports:
      - "5002:5001"
    env_file:
      - ./.env
    depends_on:
      - postgres-innovacion

  frontend-web:
    build: ./frontend-web
    container_name: frontend-web
    ports:
      - "80:80"
    depends_on:
      - backend

  frontend-mobile:
    build: ./frontend-mobile
    container_name: frontend-mobile
    ports:
      - "19000-19002:19000-19002"
      - "19006:19006"
    depends_on:
      - backend

  postgres-innovacion:
    image: postgres:latest
    container_name: postgres-innovacion
    environment:
      POSTGRES_USER: \${DB_USER}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
      POSTGRES_DB: \${DB_NAME}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  pgadmin-innovacion:
    image: dpage/pgadmin4:latest
    container_name: pgadmin-innovacion
    environment:
      PGADMIN_DEFAULT_EMAIL: \${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: \${PGADMIN_DEFAULT_PASSWORD}
    ports:
      - "5050:80"
    depends_on:
      - postgres-innovacion

volumes:
  pgdata:
DCOMPOSE

# 3️⃣ Dockerfile backend
mkdir -p backend
cat << DBE > backend/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5001
CMD ["node", "index.js"]
DBE

# 4️⃣ Dockerfile frontend-web
mkdir -p frontend-web
cat << DFW > frontend-web/Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DFW

# 5️⃣ Dockerfile frontend-mobile
mkdir -p frontend-mobile
cat << DFM > frontend-mobile/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install -g expo-cli
COPY . .
EXPOSE 19000-19002
EXPOSE 19006
CMD ["expo", "start", "--tunnel"]
DFM

echo "✅ Todos los archivos Docker y .env creados correctamente."
