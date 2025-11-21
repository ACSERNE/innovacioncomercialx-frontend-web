#!/bin/bash
set -e

echo "🧹 LIMPIEZA TOTAL DEL ENTORNO - INNOVACIONCOMERCIALX"
echo "------------------------------------------------------"

# 1️⃣ ELIMINAR CARPETAS DUPLICADAS
echo "🔍 Buscando carpetas duplicadas..."
for folder in frontend-web frontend-mobile backend; do
  if [ -d "innovacioncomercialx-$folder" ] && [ -d "$folder" ]; then
    echo "🗑️ Eliminando carpeta duplicada: innovacioncomercialx-$folder"
    rm -rf "innovacioncomercialx-$folder"
  fi
done

# 2️⃣ LIMPIAR DOCKER
echo "🐳 Eliminando contenedores, imágenes, redes y volúmenes antiguos..."
docker rm -f $(docker ps -aq) 2>/dev/null || true
docker rmi -f $(docker images -q) 2>/dev/null || true
docker volume rm $(docker volume ls -q) 2>/dev/null || true
docker network prune -f
docker builder prune -a -f

# 3️⃣ LIMPIAR CACHÉ DE NODE Y DIRECTORIOS
echo "🗑️ Eliminando node_modules, dist y build..."
find . -type d \( -name "node_modules" -o -name "dist" -o -name "build" \) -exec rm -rf {} +

echo "🧼 Limpiando caché de npm..."
npm cache clean --force

# 4️⃣ REINSTALAR DEPENDENCIAS
echo "📦 Instalando dependencias del backend..."
cd backend && npm install && cd ..

if [ -d "frontend-web" ]; then
  echo "📦 Instalando dependencias del frontend-web..."
  cd frontend-web && npm install && cd ..
fi

if [ -d "frontend-mobile" ]; then
  echo "📦 Instalando dependencias del frontend-mobile..."
  cd frontend-mobile && npm install && cd ..
fi

# 5️⃣ RECONSTRUIR DOCKER
echo "⚙️ Reconstruyendo imágenes Docker..."
docker-compose build --no-cache

# 6️⃣ LEVANTAR CONTENEDORES
echo "🚀 Levantando contenedores..."
docker-compose up -d

echo "------------------------------------------------------"
echo "✅ TODO LISTO: Proyecto InnovacionComercialX limpio y funcionando"
echo "Backend: http://localhost:5001"
echo "Frontend Web: http://localhost:3000"
echo "Frontend Mobile: http://localhost:19006"
echo "------------------------------------------------------"
