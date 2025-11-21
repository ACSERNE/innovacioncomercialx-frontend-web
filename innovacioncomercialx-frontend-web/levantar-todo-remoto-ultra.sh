#!/bin/bash
set -e

# Cargar variables de entorno
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "🐳 Limpiando contenedores antiguos..."
docker compose down -v --remove-orphans

echo "🔧 Creando archivos necesarios si no existen..."
# Puedes agregar aquí lógica de creación de nginx.conf, index.html, etc.
# Ejemplo:
# [ ! -f frontend-web/nginx.conf ] && cp frontend-web/nginx.conf.template frontend-web/nginx.conf

echo "🚀 Construyendo contenedores sin cache..."
docker compose build --no-cache

echo "⏳ Levantando contenedor de PostgreSQL primero..."
docker compose up -d db

# Esperar hasta que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté lista..."
RETRIES=30
until docker exec ${DB_CONTAINER_NAME:-innovacioncomercialx-db} pg_isready -U "${DB_USER}" >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Esperando PostgreSQL..."
  sleep 2
  ((RETRIES--))
done

if [ $RETRIES -eq 0 ]; then
  echo "❌ PostgreSQL no arrancó a tiempo. Revisa los logs con: docker logs ${DB_CONTAINER_NAME:-innovacioncomercialx-db}"
  exit 1
fi

echo "✅ PostgreSQL está lista. Levantando el resto de contenedores..."
docker compose up -d backend frontend-web frontend-mobile

echo "✅ Todos los contenedores levantados correctamente en los puertos:"
echo "  Backend: ${PORT_BACKEND}"
echo "  Frontend Web: ${PORT_FRONTEND_WEB}"
echo "  Frontend Mobile: ${PORT_FRONTEND_MOBILE}"
