#!/bin/bash
set -e

BASE_DIR="$(pwd)"
echo "✔ Variables de entorno cargadas desde .env"

# 🔹 Crear .env por defecto si no existe
if [ ! -f "$BASE_DIR/.env" ]; then
  echo "⚠ .env no encontrado. Creando uno por defecto..."
  cat <<EOT > "$BASE_DIR/.env"
POSTGRES_USER=usuario
POSTGRES_PASSWORD=contraseña
POSTGRES_DB=comercialx
EOT
fi

export $(grep -v '^#' "$BASE_DIR/.env" | xargs)

# 🔹 Limpiar contenedores y redes antiguas
echo "✔ Limpiando contenedores y redes antiguas..."
docker-compose down -v
docker system prune -af

# 🔹 Levantar Docker Compose
echo "✔ Levantando Docker Compose..."
docker-compose up --build -d

# 🔹 Frontend Mobile optimizado
FRONTEND_MOBILE_DIR="$BASE_DIR/frontend-mobile"
PACKAGE_JSON="$FRONTEND_MOBILE_DIR/package.json"
NODE_MODULES="$FRONTEND_MOBILE_DIR/node_modules"

if [ -d "$FRONTEND_MOBILE_DIR" ]; then
  echo "✔ Frontend-mobile detectado"

  cd "$FRONTEND_MOBILE_DIR"

  # 🔹 Ajustar versiones compatibles con Expo
  if [ -f "$PACKAGE_JSON" ]; then
    echo "✔ Ajustando versiones de react-native y react-native-web..."
    npx npm-check-updates -u \
      --filter "react-native,react-native-web,expo" \
      --target minor
  fi

  # 🔹 Instalar dependencias solo si no existen o package.json cambió
  if [ ! -d "$NODE_MODULES" ] || [ ! -f "$NODE_MODULES/.installed-for" ] || ! cmp -s "$PACKAGE_JSON" "$NODE_MODULES/.installed-for"; then
    echo "✔ Instalando dependencias frontend-mobile..."
    npm install
    # Guardar referencia de package.json para futuras comparaciones
    cp "$PACKAGE_JSON" "$NODE_MODULES/.installed-for"
  else
    echo "✔ node_modules ya existe y coincide con package.json, saltando instalación"
  fi

  # 🔹 Iniciar Expo CLI local (evita el legacy)
  echo "✔ Iniciando Expo con túnel..."
  npx expo start --tunnel
fi
