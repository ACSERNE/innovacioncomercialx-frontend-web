#!/bin/bash

echo "🔹 Deteniendo y eliminando contenedores antiguos..."
docker ps -aq | xargs -r docker stop
docker ps -aq | xargs -r docker rm

echo "🔹 Eliminando imágenes antiguas..."
docker images -q frontend-web-dev frontend-web-prod visor-frontend | xargs -r docker rmi -f

echo "🔹 Construyendo imagen desarrollo..."
docker build -t frontend-web-dev --target dev .

echo "🔹 Construyendo imagen producción..."
docker build -t frontend-web-prod --target build .

echo "🔹 Buscando puerto libre para producción (desde 3000)..."
PROD_PORT=3000
while netstat -aon | grep -q ":$PROD_PORT"; do PROD_PORT=$((PROD_PORT+1)); done

echo "🔹 Buscando puerto libre para desarrollo (desde 5173)..."
DEV_PORT=5173
while netstat -aon | grep -q ":$DEV_PORT"; do DEV_PORT=$((DEV_PORT+1)); done

echo "🔹 Levantando contenedores..."
docker run -d -p $PROD_PORT:80 frontend-web-prod
docker run -d -p $DEV_PORT:5173 -v $(pwd):/app frontend-web-dev

echo "✅ Contenedor producción corriendo en http://localhost:$PROD_PORT"
echo "✅ Contenedor desarrollo corriendo en http://localhost:$DEV_PORT"
