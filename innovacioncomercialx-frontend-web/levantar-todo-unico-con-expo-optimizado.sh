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

  # 🔹 Ajustar react-native-web solo si package.json existe
  if [ -f "$PACKAGE_JSON" ]; then
    echo "✔ Ajustando react-native-web a ~0.19.10..."
    sed -i.bak 's/"react-native-web":.*"/"react-native-web": "~0.19.10"/' "$PACKAGE_JSON"
  fi

  # 🔹 Instalar dependencias solo si no existen
  if [ ! -d "$NODE_MODULES" ]; then
    echo "✔ Instalando dependencias frontend-mobile..."
    cd "$FRONTEND_MOBILE_DIR"
    npm install
  else
    echo "✔ node_modules ya existe, saltando instalación"
  fi

  # 🔹 Iniciar Expo con túnel
  echo "✔ Iniciando Expo..."
  cd "$FRONTEND_MOBILE_DIR"
  npx expo start --tunnel
fi
