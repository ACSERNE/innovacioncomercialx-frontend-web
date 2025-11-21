#!/bin/bash
set -e

echo "🔹 Iniciando build del frontend..."

# Convertir rutas de Git Bash a formato Windows absoluto para Docker
FRONTEND_WEB_PATH=$(pwd -W)/innovacioncomercialx-frontend-web
FRONTEND_MOBILE_PATH=$(pwd -W)/innovacioncomercialx-frontend-mobile

echo "📁 Ruta frontend-web: $FRONTEND_WEB_PATH"
echo "📁 Ruta frontend-mobile: $FRONTEND_MOBILE_PATH"

# -------------------------------
# Build frontend-web (React Web / CRA)
# -------------------------------
if [ -f "$FRONTEND_WEB_PATH/package.json" ]; then
    echo "⚙️  Construyendo frontend-web..."
    docker run --rm -it \
        -v "${FRONTEND_WEB_PATH}:/app" \
        -w /app \
        node:20-alpine sh -c "\
            apk add --no-cache bash git python3 make g++ && \
            npm install && \
            if [ -d public ] && [ -f public/index.html ]; then \
                npm run build; \
            else \
                echo '❌ No se encontró public/index.html, creando estructura mínima...' && \
                mkdir -p public && echo '<!DOCTYPE html><html><head><title>App</title></head><body><div id=\"root\"></div></body></html>' > public/index.html && \
                npm run build; \
            fi"
else
    echo "⚠️  frontend-web no encontrado en $FRONTEND_WEB_PATH, omitiendo..."
fi

# -------------------------------
# Build frontend-mobile (Expo Web)
# -------------------------------
if [ -f "$FRONTEND_MOBILE_PATH/package.json" ]; then
    echo "⚙️  Construyendo frontend-mobile (Expo Web)..."
    docker run --rm -it \
        -v "${FRONTEND_MOBILE_PATH}:/app" \
        -w /app \
        node:20-alpine sh -c "\
            apk add --no-cache bash git python3 make g++ && \
            npm install -g expo-cli && \
            npm install && \
            expo prebuild && \
            expo build:web"
else
    echo "⚠️  frontend-mobile no encontrado en $FRONTEND_MOBILE_PATH, omitiendo..."
fi

echo "✅ Build completado."
