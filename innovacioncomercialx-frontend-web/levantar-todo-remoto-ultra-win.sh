#!/bin/bash
set -e

echo "🚀 Iniciando levantamiento del entorno (ultra offline Windows)..."

# Cargar variables de entorno desde .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "✅ Variables de entorno cargadas desde .env"
else
    echo "⚠️ No se encontró archivo .env"
fi

# Función para verificar puertos (asume libres si lsof no existe)
check_port() {
    PORT=$1
    echo "🔎 Verificando puerto $PORT..."
    if ! command -v lsof &> /dev/null; then
        echo "ℹ️ lsof no instalado, se asume puerto $PORT libre"
    else
        if lsof -i:$PORT; then
            echo "⚠️ Puerto $PORT está en uso"
        else
            echo "✅ Puerto $PORT libre"
        fi
    fi
}

check_port 8080
check_port 19006
check_port 5001
check_port 5432

# Verificar Docker Desktop
echo "⏳ Verificando Docker Desktop..."
if ! docker info &> /dev/null; then
    echo "❌ Docker Desktop no está corriendo"
    exit 1
else
    echo "✅ Docker Desktop está listo."
fi

# Limpiar contenedores, imágenes y volúmenes antiguos
echo "🧹 Limpiando contenedores, imágenes y volúmenes antiguos..."
docker compose down -v --rmi all

# Reconstruir y levantar contenedores
echo "🐳 Reconstruyendo y levantando contenedores..."
docker compose build --no-cache
docker compose up -d

# Esperar a que PostgreSQL esté lista (Windows no tiene pg_isready)
echo "⏳ Esperando a que PostgreSQL esté lista..."
until docker exec innovacioncomercialx-db-1 sh -c "pg_isready -U $DB_USER -d $DB_NAME" >/dev/null 2>&1; do
    echo "Esperando a PostgreSQL..."
    sleep 3
done
echo "✅ PostgreSQL está lista."

# Aplicar migraciones y seeds en el contenedor backend
echo "📦 Aplicando migraciones y seeds..."
docker exec -e DB_USER="$DB_USER" \
            -e DB_PASSWORD="$DB_PASSWORD" \
            -e DB_NAME="$DB_NAME" \
            -e DB_HOST="$DB_HOST" \
            -e DB_PORT="$DB_PORT" \
            innovacioncomercialx-backend-1 sh -c "npx sequelize db:migrate && npx sequelize db:seed:all"

echo "✅ Migraciones y seeds aplicadas correctamente"
echo "🎉 Entorno levantado con éxito"
