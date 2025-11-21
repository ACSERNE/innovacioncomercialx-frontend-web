#!/bin/bash

echo "🔎 Detectando puertos expuestos de docker-compose..."

# Función para buscar un puerto libre a partir de un número base
buscar_puerto_libre() {
  local PUERTO_BASE=$1
  local PUERTO=$PUERTO_BASE
  while netstat -ano | grep ":$PUERTO" >/dev/null 2>&1; do
    PUERTO=$((PUERTO+1))
  done
  echo $PUERTO
}

# Función para intentar liberar un puerto
liberar_puerto() {
  local PUERTO=$1
  PID=$(netstat -ano | grep ":$PUERTO" | awk '{print $5}' | tr -d '\r')
  if [ ! -z "$PID" ]; then
    echo "⚠️ Puerto $PUERTO ocupado por PID $PID. Intentando cerrar..."
    cmd.exe /c "taskkill /PID $PID /F" >/dev/null 2>&1 || true
    sleep 1
  fi
  if netstat -ano | grep ":$PUERTO" >/dev/null 2>&1; then
    echo "⚠️ Puerto $PUERTO aún ocupado, se reasignará automáticamente."
  else
    echo "✅ Puerto $PUERTO libre."
  fi
}

# Verificar que yq esté instalado
if ! command -v yq >/dev/null 2>&1; then
  echo "❌ Necesitas instalar yq para extraer los puertos automáticamente."
  echo "   En Windows PowerShell: choco install yq -y"
  exit 1
fi

# Leer puertos del docker-compose.yml
PUERTOS_RAW=$(yq e '.services[].ports[]' docker-compose.yml | tr -d '"')
declare -A PUERTOS_MAP
declare -A SERVICIO_MAP

for P in $PUERTOS_RAW; do
  HOST_PORT=$(echo $P | cut -d':' -f1)
  CONT_PORT=$(echo $P | cut -d':' -f2)
  # Detectar el servicio correspondiente
  SERVICIO=$(yq e ".services | to_entries[] | select(.value.ports[] == \"$P\") | .key" docker-compose.yml)
  SERVICIO_MAP[$SERVICIO]=$CONT_PORT

  liberar_puerto $HOST_PORT
  LIBRE=$(buscar_puerto_libre $HOST_PORT)
  PUERTOS_MAP[$SERVICIO]=$LIBRE
done

# Generar docker-compose.override.yml
echo "🔹 Generando docker-compose.override.yml con puertos actualizados..."
cat > docker-compose.override.yml <<EOF
services:
