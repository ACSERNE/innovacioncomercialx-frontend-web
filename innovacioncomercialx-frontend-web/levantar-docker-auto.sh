#!/bin/bash

# ----------------------
# Colores
# ----------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sin color

# ----------------------
# Cargar variables de entorno desde .env
# ----------------------
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo -e "${GREEN}✔ Variables de entorno cargadas desde .env${NC}"
else
  echo -e "${RED}⚠ No se encontró archivo .env. Revisa que esté en la misma carpeta que este script.${NC}"
  exit 1
fi

# ----------------------
# Verificar Docker
# ----------------------
echo -e "${GREEN}🔹 Verificando Docker y Docker Compose...${NC}"
docker --version
docker-compose --version

# ----------------------
# Informar puertos
# ----------------------
echo -e "${GREEN}🔹 Puertos configurados:${NC}"
echo "Backend: $PORT_BACKEND"
echo "Frontend Web: $PORT_FRONTEND"
echo "Frontend Mobile: $PORT_MOBILE"

# ----------------------
# Levantar Docker Compose
# ----------------------
echo -e "${GREEN}🔹 Levantando el stack completo...${NC}"
docker-compose up -d --build

# ----------------------
# Esperar 5 segundos para que los contenedores inicien
# ----------------------
sleep 5

# ----------------------
# Mostrar contenedores activos
# ----------------------
echo -e "${GREEN}🔹 Contenedores activos:${NC}"
docker ps

# ----------------------
# Mostrar logs en tiempo real
# ----------------------
echo -e "${GREEN}🔹 Mostrando logs en tiempo real (CTRL+C para salir)...${NC}"
docker-compose logs -f
