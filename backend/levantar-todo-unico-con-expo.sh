#!/bin/bash
# levantar-todo-unico-con-expo.sh
# Script unificado para levantar toda la stack y mostrar QR de Expo

set -e

# ------------------------------
# 1️⃣ Cargar variables de .env
# ------------------------------
if [ ! -f .env ]; then
    echo "❌ Archivo .env no encontrado en $(pwd)"
    exit 1
fi

export $(grep -v '^#' .env | xargs)
echo "✔ Variables de entorno cargadas desde .env"

# ------------------------------
# 2️⃣ Verificar Docker
# ------------------------------
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no instalado"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no instalado"
    exit 1
fi

echo "✔ Docker y Docker Compose detectados"

# ------------------------------
# 3️⃣ Limpiar puertos y contenedores antiguos
# ------------------------------
declare -A PUERTOS=( ["backend"]=5001 ["frontend-web"]=3000 ["frontend-mobile"]=19000 )

for SERVICIO in "${!PUERTOS[@]}"; do
    PUERTO=${PUERTOS[$SERVICIO]}
    if lsof -ti:$PUERTO &> /dev/null; then
        echo "⚠ Puerto $PUERTO ($SERVICIO) ocupado. Liberando..."
        lsof -ti:$PUERTO | xargs -r kill -9
        echo "✔ Puerto $PUERTO liberado"
    fi
done

docker system prune -f
echo "✔ Contenedores y redes antiguas limpiadas"

# ------------------------------
# 4️⃣ Levantar stack completo
# ------------------------------
docker-compose --env-file .env up --build -d
echo "🚀 Stack completo levantado con Docker Compose"

# ------------------------------
# 5️⃣ Verificar servicios y mostrar URLs
# ------------------------------
echo "✔ Backend: http://localhost:5001"
echo "✔ Frontend Web: http://localhost:3000"

# ------------------------------
# 6️⃣ Levantar Expo localmente y mostrar QR
# ------------------------------
if [ -d "frontend-mobile" ]; then
    echo "✔ Iniciando Expo para Frontend Mobile..."
    cd frontend-mobile

    # Instala dependencias si es necesario
    if [ ! -d "node_modules" ]; then
        echo "📦 Instalando dependencias de frontend-mobile..."
        npm install
    fi

    # Usa npx para evitar problemas con la versión global
    npx expo start --tunnel &
    EXPO_PID=$!

    echo "✔ Expo iniciado con PID $EXPO_PID"
    echo "📱 Escanea el QR que aparece en la terminal para tu celular"
    cd ..
else
    echo "⚠ Carpeta frontend-mobile no encontrada, no se levantará Expo"
fi

# ------------------------------
# 7️⃣ Mensaje final
# ------------------------------
echo "✅ Todos los servicios levantados. Para ver logs:"
echo "docker-compose logs -f backend"
echo "docker-compose logs -f frontend-web"
echo "cd frontend-mobile && npx expo logs"
