#!/bin/bash
set -e

echo "🧹 Limpiando contenedores, volúmenes y redes..."
docker compose down -v

echo "🔨 Construyendo imágenes desde cero..."
docker compose build --no-cache

echo "🚀 Levantando todos los contenedores..."
docker compose up -d

echo ""
echo "✅ Todo listo. Contenedores levantados correctamente."
echo "🌐 FRONTEND WEB en http://localhost:3000"
echo "📱 FRONTEND MOBILE en http://localhost:19000"
echo "🧠 BACKEND en http://localhost:5003"
echo "🐘 PostgreSQL en puerto 5433"
echo "🗂 PgAdmin en http://localhost:8082"
