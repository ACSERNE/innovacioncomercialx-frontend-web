#!/bin/bash

echo "🛑 Deteniendo y limpiando contenedores antiguos..."
docker compose down -v

echo "🧹 Limpiando caché y reconstruyendo imágenes..."
docker compose build --no-cache

echo "🚀 Levantando servicios en segundo plano..."
docker compose up -d

echo "✅ Todo listo. Contenedores activos:"
docker ps
