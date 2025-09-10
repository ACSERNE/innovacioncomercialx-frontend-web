#!/bin/bash
set -e

# Cargar variables de entorno desde .env
if [ -f .env ]; then
  echo "🌿 Cargando variables de entorno desde .env"
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️ No se encontró archivo .env. Asegúrate de crearlo con POSTGRES_USER, POSTGRES_PASSWORD y POSTGRES_DB"
  exit 1
fi

echo "🔎 Detectando contenedores Docker existentes..."
containers=$(docker ps -aq)
if [ -n "$containers" ]; then
  echo "🚀 Deteniendo y eliminando contenedores existentes..."
  docker stop $containers
  docker rm $containers
else
  echo "✅ No hay contenedores activos."
fi

echo "🧹 Limpiando imágenes intermedias antiguas..."
docker image prune -f

echo "🔨 Construyendo imágenes Docker..."
docker-compose build --no-cache

echo "🚀 Levantando todos los servicios..."
docker-compose up -d

echo "✅ Todos los servicios están corriendo."
echo "🌐 Frontend Web: http://localhost:3000"
echo "📱 Frontend Mobile: http://localhost:19006"
echo "⚙️ Backend: http://localhost:5001"
echo "🗄️ Base de datos: Puerto 5432"
