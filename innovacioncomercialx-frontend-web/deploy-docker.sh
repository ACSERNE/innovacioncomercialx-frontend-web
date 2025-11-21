#!/bin/bash
set -e

echo "🚀 Iniciando despliegue limpio y optimizado de Docker..."

# Detener y eliminar contenedores existentes
echo "🔹 Deteniendo contenedores existentes..."
docker compose down || true

# Limpiar imágenes dangling
echo "🔹 Limpiando imágenes dangling..."
docker image prune -f

# Limpiar volúmenes huérfanos
echo "🔹 Limpiando volúmenes huérfanas..."
docker volume prune -f

# Limpiar redes huérfanas
echo "🔹 Limpiando redes huérfanas..."
docker network prune -f

# Levantar PostgreSQL primero
echo "🔹 Levantando PostgreSQL..."
docker compose up -d postgres-innovacion

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
until docker exec postgres-innovacion pg_isready -U "${DB_USER}" >/dev/null 2>&1; do
    sleep 1
done
echo "✅ PostgreSQL listo."

# Construir y levantar todos los servicios
echo "🔹 Construyendo y levantando todos los servicios..."
DOCKER_BUILDKIT=0 docker compose build --no-cache
DOCKER_BUILDKIT=0 docker compose up -d

echo "✅ Todo listo. Revisa el estado con 'docker compose ps'."
docker compose ps
