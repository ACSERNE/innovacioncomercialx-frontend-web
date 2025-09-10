#!/bin/bash

COMPOSE_FILE="docker-compose.yml"

echo "🔎 Detectando puertos expuestos en $COMPOSE_FILE..."

# Extraer puertos del docker-compose.yml
PUERTOS=$(grep -oP '(?<=- ")[0-9]+(?=:)' "$COMPOSE_FILE" | sort -u)

# Función para liberar un puerto
liberar_puerto() {
  PUERTO=$1
  PID=$(netstat -ano | grep ":$PUERTO" | awk '{print $5}' | tr -d '\r')
  if [ ! -z "$PID" ]; then
    echo "⚠️ Puerto $PUERTO ocupado por PID $PID. Cerrando proceso..."
    cmd.exe /c "taskkill /PID $PID /F" >/dev/null 2>&1
    echo "✅ Puerto $PUERTO liberado."
  else
    echo "✅ Puerto $PUERTO libre."
  fi
}

# Revisar y liberar cada puerto encontrado
for PUERTO in $PUERTOS; do
  liberar_puerto $PUERTO
done

echo "🚀 Limpiando contenedores Docker antiguos..."
docker-compose down -v --remove-orphans

echo "🚀 Construyendo y levantando Docker Compose..."
docker-compose build --no-cache
docker-compose up -d

echo "✅ Todos los servicios levantados correctamente."
