#!/bin/bash
set -e

echo "$(date '+%Y-%m-%d %H:%M:%S') ✅ Revisando .env en cada servicio..."
for envfile in ./backend/.env ./innovacioncomercialx-frontend-web/.env ./innovacioncomercialx-frontend-mobile/.env; do
  if [ -f "$envfile" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ✅ .env revisado: $envfile"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ❌ No existe: $envfile"
    exit 1
  fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') 🧹 Limpiando contenedores, volúmenes e imágenes antiguas..."
docker compose down -v --remove-orphans || true

echo "$(date '+%Y-%m-%d %H:%M:%S') 🏗 Construyendo imágenes..."
docker compose build

echo "$(date '+%Y-%m-%d %H:%M:%S') 🚀 Levantando servicios..."
docker compose up -d

echo "$(date '+%Y-%m-%d %H:%M:%S') ⏳ Esperando a que PostgreSQL (innovacioncomercialx-db-1) esté lista..."
until docker exec innovacioncomercialx-db-1 pg_isready -U postgres > /dev/null 2>&1; do
  echo "   ⏳ Esperando a PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL respondió a pg_isready."
echo "⏳ Esperando 10s extra para estabilizar PostgreSQL..."
sleep 10

# 🔧 Crear extensión uuid-ossp (si no existe)
echo "🔧 Creando extensión uuid-ossp (si no existe)..."
export $(grep -v '^#' ./backend/.env | xargs)
docker exec -i innovacioncomercialx-db-1 \
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

echo "🎉 Todo listo."
