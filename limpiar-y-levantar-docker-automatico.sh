#!/bin/bash

# Colores para terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔎 Detectando puertos del docker-compose.yml..."

# Extraer puertos explícitos
extraer_puertos() {
  yq eval '.services | to_entries[] | "\(.key) \(.value.ports // [])"' docker-compose.yml | sed 's/\[//;s/\]//;s/"//g'
}

# Función para liberar un puerto en Windows
liberar_puerto() {
  local PUERTO=$1
  local PID=$(netstat -ano | grep ":$PUERTO" | awk '{print $5}' | tr -d '\r')
  if [ ! -z "$PID" ]; then
    echo -e "⚠️ Puerto $PUERTO ocupado por PID $PID. Cerrando proceso..."
    cmd.exe /c "taskkill /PID $PID /F" >/dev/null 2>&1
    echo -e "${GREEN}✅ Puerto $PUERTO liberado.${NC}"
  else
    echo -e "${GREEN}✅ Puerto $PUERTO libre.${NC}"
  fi
}

# Liberar puertos explícitos de docker-compose.yml
PUERTOS_SERVICIOS=$(extraer_puertos)
while read -r LINE; do
  SERVICE=$(echo $LINE | awk '{print $1}')
  PORTS=$(echo $LINE | awk '{$1=""; print $0}')
  for PUERTO_MAPPING in $PORTS; do
    PUERTO=$(echo $PUERTO_MAPPING | cut -d':' -f2)
    [ -z "$PUERTO" ] && continue
    echo -e "\n🔹 Servicio: $SERVICE - Puerto: $PUERTO"
    liberar_puerto $PUERTO
  done
done <<< "$PUERTOS_SERVICIOS"

# Liberar puertos asignados dinámicamente por Docker a contenedores en ejecución
echo -e "\n🔎 Detectando puertos ocupados por contenedores Docker en ejecución..."
docker ps --format "{{.Names}} {{.Ports}}" | while read -r CONTAINER PORTS; do
  for P in $(echo $PORTS | tr ',' '\n'); do
    PUERTO=$(echo $P | grep -oP '(?<=:)[0-9]+(?->)')
    [ -z "$PUERTO" ] && continue
    echo -e "\n🔹 Contenedor: $CONTAINER - Puerto asignado dinámicamente: $PUERTO"
    liberar_puerto $PUERTO
  done
done

# Limpiar contenedores y volúmenes antiguos
echo -e "\n🚀 Limpiando contenedores y volúmenes antiguos..."
docker-compose down -v --remove-orphans

# Construir y levantar todo
echo -e "\n🚀 Construyendo imágenes Docker sin caché..."
docker-compose build --no-cache

echo -e "\n🚀 Levantando todos los servicios en segundo plano..."
docker-compose up -d

# Resumen final de todos los puertos (explícitos y dinámicos)
echo -e "\n🔹 Estado final de los puertos:"
ALL_PORTS=$(extraer_puertos | awk '{$1=""; print $0}' | tr -d '[]"' | tr ',' '\n')
docker ps --format "{{.Ports}}" | tr ',' '\n' >> /tmp/all_ports_docker.txt
ALL_PORTS+=$(cat /tmp/all_ports_docker.txt)
for PUERTO in $ALL_PORTS; do
  PUERTO_NUM=$(echo $PUERTO | cut -d':' -f2)
  [ -z "$PUERTO_NUM" ] && continue
  STATUS=$(netstat -ano | grep ":$PUERTO_NUM" >/dev/null && echo -e "${RED}OCUPADO${NC}" || echo -e "${GREEN}LIBRE${NC}")
  echo -e "Puerto $PUERTO_NUM: $STATUS"
done
rm -f /tmp/all_ports_docker.txt

echo -e "\n✅ Todos los servicios levantados correctamente."
