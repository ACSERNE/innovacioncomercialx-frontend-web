#!/bin/bash
set -e

MAX_RETRIES=3
SLEEP_BETWEEN_RETRIES=5

echo "🚀 Iniciando despliegue completo de Docker en paralelo..."

# Función para verificar puerto libre
check_port() {
  PORT=$1
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Puerto $PORT en uso. Abortando."
    exit 1
  else
    echo "✅ Puerto $PORT libre."
  fi
}

# Obtener servicios de docker-compose
SERVICES=($(docker compose config --services))
POSTGRES_SERVICE=$(echo "${SERVICES[@]}" | tr ' ' '\n' | grep -i 'postgres')
OTHER_SERVICES=($(echo "${SERVICES[@]}" | tr ' ' '\n' | grep -vi 'postgres'))

# Detener y eliminar contenedores
echo "🔹 Deteniendo y eliminando contenedores existentes..."
docker compose down || true

# Limpiar imágenes, volúmenes y redes
docker image prune -f
docker volume prune -f
docker network prune -f

# Verificar puertos
PORTS=$(docker compose config | grep 'ports:' -A 5 | grep -Eo '[0-9]+(?=:)' | tr '\n' ' ')
for PORT in $PORTS; do
  check_port $PORT
done

# Construir imágenes
echo "🔹 Construyendo imágenes de todos los servicios..."
docker compose build

# Levantar PostgreSQL primero
echo "🔹 Levantando PostgreSQL..."
docker compose up -d $POSTGRES_SERVICE

# Esperar a PostgreSQL
DB_USER=$(grep DB_USER .env | cut -d '=' -f2)
DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2)
until docker exec -i $POSTGRES_SERVICE pg_isready -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
  echo "⏳ Esperando PostgreSQL..."
  sleep 2
done
echo "✅ PostgreSQL listo."

# Función para levantar servicios con retry
up_service_with_retry() {
  local SERVICE=$1
  local ATTEMPT=1
  while [ $ATTEMPT -le $MAX_RETRIES ]; do
    echo "🔹 Levantando servicio $SERVICE (intento $ATTEMPT/$MAX_RETRIES)..."
    if docker compose up -d $SERVICE; then
      echo "✅ Servicio $SERVICE levantado correctamente."
      return 0
    else
      echo "⚠️ Error al levantar $SERVICE. Reintentando en $SLEEP_BETWEEN_RETRIES segundos..."
      sleep $SLEEP_BETWEEN_RETRIES
      ATTEMPT=$((ATTEMPT + 1))
    fi
  done
  echo "❌ No se pudo levantar el servicio $SERVICE después de $MAX_RETRIES intentos."
  exit 1
}

# Levantar servicios en paralelo (backend y frontends)
echo "🔹 Levantando servicios backend y frontends en paralelo..."
for SERVICE in "${OTHER_SERVICES[@]}"; do
  up_service_with_retry $SERVICE &
done
wait

echo "✅ Todos los servicios levantados correctamente:"
docker compose ps
