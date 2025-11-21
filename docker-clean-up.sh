#!/bin/bash
set -e

echo "🚀 Iniciando limpieza y despliegue de Docker..."

# 🔹 Crear Dockerfile de frontend web
mkdir -p frontend-web
cat <<'EOT' > frontend-web/Dockerfile
# Stage 1: Build React
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOT

# 🔹 Nginx config para frontend web
cat <<'EOT' > frontend-web/nginx.conf
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
EOT

# 🔹 Dockerfile de backend
mkdir -p backend
cat <<'EOT' > backend/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5001
CMD ["node", "server.js"]
EOT

# 🔹 Dockerfile de frontend mobile (Expo)
mkdir -p frontend-mobile
cat <<'EOT' > frontend-mobile/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install -g expo-cli
RUN npm install
COPY . .
EXPOSE 19000-19002 19006
CMD ["expo", "start", "--tunnel"]
EOT

# 🔹 docker-compose.yml sin versión
cat <<'EOT' > docker-compose.yml
services:
  postgres-innovacion:
    image: postgres:latest
    container_name: postgres-innovacion
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  pgadmin-innovacion:
    image: dpage/pgadmin4:latest
    container_name: pgadmin-innovacion
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
    ports:
      - "8080:80"
    depends_on:
      - postgres-innovacion
    restart: always

  comercialx-backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: comercialx-backend
    environment:
      DB_HOST: postgres-innovacion
      DB_PORT: 5432
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}
    ports:
      - "5002:5001"
    depends_on:
      - postgres-innovacion
    restart: always

  frontend-web:
    build:
      context: ./frontend-web
      dockerfile: Dockerfile
    container_name: frontend-web
    ports:
      - "80:80"
    depends_on:
      - comercialx-backend
    restart: always

  frontend-mobile:
    build:
      context: ./frontend-mobile
      dockerfile: Dockerfile
    container_name: frontend-mobile
    ports:
      - "19000-19002:19000-19002"
      - "19006:19006"
    restart: always

volumes:
  pgdata:
EOT

# 🔹 Limpiar contenedores e imágenes anteriores
docker compose down -v --remove-orphans
docker image prune -af

# 🔹 Construir y levantar contenedores
docker compose up --build -d

echo "✅ Todo listo. Frontend Web en Nginx, Backend Node, PostgreSQL y PgAdmin corriendo."
