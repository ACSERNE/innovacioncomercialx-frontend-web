#!/bin/bash
set -e

# 🔹 Ruta base del proyecto
BASE_DIR="$(pwd)"

echo "✔ Variables de entorno cargadas desde .env"

# 🔹 Verificar y crear .env si no existe
if [ ! -f "$BASE_DIR/.env" ]; then
  echo "⚠ .env no encontrado. Creando uno por defecto..."
  cat <<EOT > "$BASE_DIR/.env"
POSTGRES_USER=usuario
POSTGRES_PASSWORD=contraseña
POSTGRES_DB=comercialx
EOT
fi

export $(grep -v '^#' "$BASE_DIR/.env" | xargs)

# 🔹 Limpiar contenedores, redes e imágenes antiguas
echo "✔ Limpiando contenedores, redes e imágenes antiguas..."
docker-compose down -v
docker system prune -af

# 🔹 Levantar Docker Compose
echo "✔ Levantando Docker Compose..."
docker-compose up --build -d

# 🔹 Frontend Mobile
FRONTEND_MOBILE_DIR="$BASE_DIR/frontend-mobile"
if [ -d "$FRONTEND_MOBILE_DIR" ]; then
  echo "✔ Limpiando frontend-mobile..."
  rm -rf "$FRONTEND_MOBILE_DIR/node_modules" "$FRONTEND_MOBILE_DIR/package-lock.json"

  # 🔹 Reemplazar react-native-web por versión compatible
  PACKAGE_JSON="$FRONTEND_MOBILE_DIR/package.json"
  if [ -f "$PACKAGE_JSON" ]; then
    echo "✔ Ajustando react-native-web a ~0.19.10..."
    sed -i.bak 's/"react-native-web":.*"/"react-native-web": "~0.19.10"/' "$PACKAGE_JSON"
  fi

  # 🔹 Instalar dependencias
  echo "✔ Instalando dependencias de frontend-mobile..."
  cd "$FRONTEND_MOBILE_DIR"
  npm install
fi

# 🔹 Iniciar Expo
echo "✔ Iniciando Expo..."
npx expo start --tunnel
