#!/bin/bash
set -e

cd ~/innovacioncomercialx
echo "📦 Reorganizando proyecto en $(pwd)..."

# Crear carpetas si no existen
mkdir -p backend
mkdir -p frontend

# 1. Mover frontend si está en subcarpeta rara
if [ -d "innovacioncomercialx-frontend-web/frontend-web" ]; then
  echo "➡️ Moviendo frontend..."
  mv innovacioncomercialx-frontend-web/frontend-web/* frontend/ 2>/dev/null || true
  mv innovacioncomercialx-frontend-web/frontend-web/.* frontend/ 2>/dev/null || true
  rm -rf innovacioncomercialx-frontend-web
fi

# 2. Mover archivos del root que son del backend
echo "➡️ Moviendo archivos sueltos al backend..."
for item in *; do
  if [[ "$item" != "backend" && "$item" != "frontend" && "$item" != "docker-compose.yml" && "$item" != ".env" && "$item" != "README.md" && "$item" != "reorganizar.sh" ]]; then
    mv "$item" backend/ 2>/dev/null || true
    echo "   📂 Movido: $item -> backend/"
  fi
done

echo "✅ Proyecto reorganizado en carpetas:"
tree -L 2
