#!/bin/bash

# =========================================
# Levantar todo: Backend + Frontend Web + Mobile
# =========================================

# Cargar variables de entorno desde .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "✔ Variables de entorno cargadas desde .env"
else
  echo "⚠ No se encontró archivo .env"
fi

# Limpiar contenedores, redes y cache antiguos
echo "✔ Limpiando contenedores y redes antiguas..."
docker system prune -af --volumes
echo "✔ Cache y contenedores antiguos eliminados"

# =========================================
# Build y levantamiento de contenedores
# =========================================

# Levantar backend
echo "✔ Construyendo y levantando Backend..."
docker build --no-cache -t innovacion-backend ./backend
docker run -d --name backend -p 5001:5001 --env-file .env innovacion-backend

# Levantar frontend web
echo "✔ Construyendo y levantando Frontend Web..."
docker build --no-cache -t innovacion-frontend-web ./frontend-web
docker run -d --name frontend-web -p 3000:80 innovacion-frontend-web

# Levantar frontend mobile (Expo)
echo "✔ Construyendo y levantando Frontend Mobile..."
docker build --no-cache -t innovacion-frontend-mobile ./frontend-mobile
docker run -d --name frontend-mobile -p 19006:19006 innovacion-frontend-mobile

echo "✅ Todos los servicios levantados correctamente"

