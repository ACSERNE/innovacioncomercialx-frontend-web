#!/bin/bash
set -e

echo "🚀 Iniciando despliegue robusto de Docker..."

# Función para verificar si un puerto está libre
check_port() {
  PORT=$1
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Puerto $PORT en uso. Abortando."
    exit 1
  else
    echo "✅ Puerto $PORT libre."
  fi
}

# Leer servicios y puertos desde docker-compose
SERVICES=($(docker compose config --services))
POSTGRES_SERVICE=$(echo "${SERVICES[@]}" | tr ' ' '\n' | grep -i 'postgres')
OTHER_SERVICES=($(echo "${SERVICES[@]}" | tr ' ' '\n' | grep -vi 'postgres'))

echo "🔹 Deteniendo contenedores existentes..."
docker compose stop || true

echo "🔹 Eliminando contenedores existentes..."
docker compose rm -f || true

echo "🔹 Limpiando imágenes, volúmenes y redes huérfanas..."
docker image prune -f
docker volume prune -f
docker network prune -f

# Extraer puertos de los servicios para verificación
PORTS=$(docker compose config | grep 'ports:' -A 5 | grep -Eo '[0-9]+(?=:)' | tr '\n' ' ')
for PORT in $PORTS; do
  check_port $PORT
done

echo "🔹 Levantando PostgreSQL primero: $POSTGRES_SERVICE"
docker compose up -d $POSTGRES_SERVICE

echo "⏳ Esperando a que PostgreSQL esté listo..."
DB_USER=$(grep DB_USER .env | cut -d '=' -f2)
DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2)

until docker exec -i $POSTGRES_SERVICE pg_isready -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
  echo "Esperando PostgreSQL..."
  sleep 2
done
echo "✅ PostgreSQL listo."

echo "🔹 Construyendo y levantando el resto de los servicios..."
docker compose build ${OTHER_SERVICES[@]}
docker compose up -d ${OTHER_SERVICES[@]}

echo "✅ Todos los servicios levantados correctamente. Estado actual:"
docker compose ps
