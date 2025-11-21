#!/bin/bash
set -e

echo "🐳 Limpiando contenedores antiguos..."
docker rm -f innovacioncomercialx-frontend-web-1 innovacioncomercialx-frontend-mobile-1 innovacioncomercialx-pgadmin-1 || true

echo "🔨 Reconstruyendo y levantando todos los contenedores..."
docker compose up --build -d

echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

echo "📦 Instalando dependencias y build Frontend Web..."
docker exec -it innovacioncomercialx-frontend-web-1 sh -c "cd /app && npm install && npm run build && nginx -s reload"

echo "📦 Instalando dependencias Frontend Mobile (Expo)..."
docker compose run --rm frontend-mobile sh -c "npm install"

echo "✅ Todos los servicios deberían estar levantados:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🌐 Accede desde tu navegador:"
echo "Backend: http://localhost:5001"
echo "Frontend Web: http://localhost:3000"
echo "PgAdmin: http://localhost:5050"
echo "Frontend Mobile (Expo): abre con la app de Expo usando el túnel o la IP de WSL2"

