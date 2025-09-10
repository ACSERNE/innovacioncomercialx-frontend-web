#!/bin/bash

# Buscar primer puerto libre a partir de 3000
PORT=3000
while netstat -aon | grep ":$PORT" > /dev/null; do
  PORT=$((PORT + 1))
done

# Ruta absoluta compatible con Docker en Windows/Linux
if command -v cygpath >/dev/null 2>&1; then
    DEV_PATH=$(cygpath -w "$(pwd)")
else
    DEV_PATH=$(pwd)
fi

echo "🔧 Desarrollo activo en http://localhost:$PORT"

# Ejecutar contenedor de desarrollo
docker run --rm -it \
  -v "$DEV_PATH:/app" \
  -w /app \
  -p $PORT:3000 \
  node:20-alpine sh -c "npm install && npm run dev -- --host 0.0.0.0 --port 3000" &

# Esperar unos segundos a que CRA levante el servidor
sleep 5

# Abrir automáticamente la URL en el navegador predeterminado (Windows, macOS, Linux)
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://localhost:$PORT"
elif command -v open >/dev/null 2>&1; then
    open "http://localhost:$PORT"
elif command -v start >/dev/null 2>&1; then
    start "http://localhost:$PORT"
fi
