#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔎 Detectando todos los puertos de docker-compose.yml automáticamente..."

# Requiere yq
if ! command -v yq &> /dev/null; then
  echo -e "${RED}❌ yq no está instalado. Instala yq para continuar.${NC}"
  exit 1
fi

# Función para liberar puerto
liberar_puerto() {
  local PUERTO=$1
  local PID
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    PID=$(netstat -ano | grep ":$PUERTO" | awk '{print $5}' | tr -d '\r')
    if [ ! -z "$PID" ]; then
      echo "⚠️ Puerto $PUERTO ocupado por PID $PID. Cerrando proceso..."
      cmd.exe /c "taskkill /PID $PID /F" >/dev/null 2>&1
      echo -e "${GREEN}✅ Puerto $PUERTO liberado.${NC}"
    else
      echo -e "${GREEN}✅ Puerto $PUERTO libre.${NC}"
    fi
  else
    PID=$(lsof -ti tcp:$PUERTO)
    if [ ! -z "$PID" ]; then
      echo "⚠️ Puerto $PUERTO ocupado por PID $PID. Cerrando proceso..."
      kill -9 $PID >/dev/null 2>&1
      echo -e "${GREEN}✅ Puerto $PUERTO liberado.${NC}"
    else
      echo -e "${GREEN}✅ Puerto $PUERTO libre.${NC}"
    fi
  fi
}

# Extraer todos los puertos (host:container) automáticamente
echo "🔹 Revisando puertos expuestos..."
mapfile -t PUERTOS < <(yq eval '.services[]?.ports[]?' docker-compose.yml | grep -o '^[0-9]\+')

for PORT in "${PUERTOS[@]}"; do
  [[ -z "$PORT" ]] && continue
  liberar_puerto $PORT
done

# Limpiar contenedores y volúmenes antiguos
echo -e "\n🚀 Limpiando contenedores y volúmenes antiguos..."
docker-compose down -v --remove-orphans

# Construir y levantar todo
echo -e "\n🚀 Construyendo imágenes Docker sin caché..."
docker-compose build --no-cache

echo -e "\n🚀 Levantando todos los servicios en segundo plano..."
docker-compose up -d

# Mostrar estado final de todos los puertos detectados
echo -e "\n🔹 Estado final de los puertos:"
for PORT in "${PUERTOS[@]}"; do
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    netstat -ano | grep ":$PORT" >/dev/null && STATUS="${RED}OCUPADO${NC}" || STATUS="${GREEN}LIBRE${NC}"
  else
    lsof -ti tcp:$PORT >/dev/null && STATUS="${RED}OCUPADO${NC}" || STATUS="${GREEN}LIBRE${NC}"
  fi
  echo -e "Puerto $PORT: $STATUS"
done

echo -e "\n✅ Todos los servicios levantados correctamente."
