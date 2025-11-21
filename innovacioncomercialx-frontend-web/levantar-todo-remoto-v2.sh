#!/bin/bash
# levantar-todo-remoto-v2.sh
# ---------------------------------------------------
# Levanta Docker DB + backend + frontend web + frontend mobile + ngrok + QR
# Cada servicio en su propia ventana
# ---------------------------------------------------

set -e

ROOT_DIR="$(pwd)"
FRONTEND_WEB_DIR="$ROOT_DIR/frontend-web"
FRONTEND_MOBILE_DIR="$ROOT_DIR/frontend-mobile"
BACKEND_DIR="$ROOT_DIR/backend"
QR_DIR="$ROOT_DIR/deploy/qr"
mkdir -p "$QR_DIR"

echo "🛑 Cerrando procesos antiguos..."
taskkill /F /IM node.exe 2>/dev/null || true
taskkill /F /IM ngrok.exe 2>/dev/null || true
taskkill /F /IM serve.exe 2>/dev/null || true
sleep 2

# ------------------------------
# Función para buscar puerto libre
# ------------------------------
find_free_port() {
  local port=$1
  while lsof -i:$port >/dev/null 2>&1; do
    port=$((port+1))
  done
  echo $port
}

PORT_FRONTEND_WEB=$(find_free_port 8080)
PORT_FRONTEND_MOBILE=$(find_free_port 19006)
PORT_BACKEND=$(find_free_port 5001)
PORT_DB=$(find_free_port 5432)

echo "✅ Puerto libre frontend web: $PORT_FRONTEND_WEB"
echo "✅ Puerto libre frontend mobile: $PORT_FRONTEND_MOBILE"
echo "✅ Puerto libre backend: $PORT_BACKEND"
echo "✅ Puerto libre PostgreSQL: $PORT_DB"

# ------------------------------
# Levantar Docker DB
# ------------------------------
echo "🐳 Iniciando PostgreSQL en Docker..."
docker rm -f icx-db >/dev/null 2>&1 || true
docker run -d --name icx-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=icxdb \
  -p $PORT_DB:5432 \
  postgres:15-alpine

# Esperar DB lista
echo "⏳ Esperando que PostgreSQL esté listo..."
until docker exec icx-db pg_isready -U postgres >/dev/null 2>&1; do
  sleep 1
done
docker exec -i icx-db psql -U postgres -d icxdb -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
echo "✅ PostgreSQL listo!"

export DB_HOST=127.0.0.1
export DB_PORT=$PORT_DB
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_NAME=icxdb
export PORT=$PORT_BACKEND

# ------------------------------
# Ejecutar migraciones y seeds en nueva ventana
# ------------------------------
start "" powershell -NoExit -Command "cd $BACKEND_DIR; npm install; npx sequelize db:migrate; npx sequelize db:seed:all"

sleep 3

# ------------------------------
# Levantar backend en nueva ventana
# ------------------------------
start "" powershell -NoExit -Command "cd $BACKEND_DIR; npm install; npx nodemon index.js --watch . --ext js,mjs,cjs,json"

sleep 3

# ------------------------------
# Levantar frontend web en nueva ventana
# ------------------------------
start "" powershell -NoExit -Command "cd $FRONTEND_WEB_DIR; npm install; npm run build; npx serve -s build -l $PORT_FRONTEND_WEB"

# ------------------------------
# Levantar frontend mobile (Expo) en nueva ventana
# ------------------------------
start "" powershell -NoExit -Command "cd $FRONTEND_MOBILE_DIR; npm install; npx expo start --port $PORT_FRONTEND_MOBILE --tunnel"

sleep 5

# ------------------------------
# Levantar ngrok en nueva ventana
# ------------------------------
taskkill /F /IM ngrok.exe 2>/dev/null || true
start "" powershell -NoExit -Command "ngrok http $PORT_FRONTEND_WEB --log=stdout"

sleep 5
NGROK_URL=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[] | select(.proto=="https") | .public_url')
echo "✅ URL pública ngrok: $NGROK_URL"

# ------------------------------
# Generar QR dinámico
# ------------------------------
cat > "$QR_DIR/index.html" <<HTML
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Acceso Innovacion Comercial X</title>
</head>
<body style="font-family:sans-serif;text-align:center;margin-top:50px;">
  <h1>📱 Acceso rápido</h1>
  <p>Escanea este código QR para abrir el frontend web en tu celular:</p>
  <img src="https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$NGROK_URL" alt="QR Code" />
  <p><a href="$NGROK_URL" target="_blank">Abrir en navegador</a></p>
</body>
</html>
HTML

echo "✅ Página QR actualizada: $QR_DIR/index.html"

# ------------------------------
# Abrir navegador con ngrok
# ------------------------------
start "" powershell -NoExit -Command "start $NGROK_URL"

echo "🎉 Proyecto remoto full stack levantado correctamente!"
