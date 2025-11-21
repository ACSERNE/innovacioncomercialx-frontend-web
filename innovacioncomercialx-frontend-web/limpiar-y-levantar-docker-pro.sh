#!/bin/bash

# 🔹 Script: limpiar-y-levantar-docker-pro.sh
# 🔹 Funcionalidad: detecta puertos de docker-compose, libera procesos que los ocupen y levanta todos los servicios.

echo "🔎 Detectando puertos expuestos de docker-compose..."

# Requiere yq para parsear YAML
if ! command -v yq &> /dev/null; then
    echo "❌ yq no está instalado. Instálalo antes de continuar."
    echo "   https://mikefarah.gitbook.io/yq/"
    exit 1
fi

# Extraer todos los puertos del docker-compose.yml
PUERTOS=($(yq e '.services[]?.ports[]' docker-compose.yml | cut -d':' -f1 | tr -d '"'))

# Función para liberar puerto
liberar_puerto() {
    PUERTO=$1
    # Obtener PID usando netstat
    PID=$(netstat -ano | grep ":$PUERTO" | awk '{print $5}' | tr -d '\r')
    if [ ! -z "$PID" ]; then
        echo "⚠️ Puerto $PUERTO ocupado por PID $PID. Cerrando proceso..."
        powershell.exe -Command "Stop-Process -Id $PID -Force"
        echo "✅ Puerto $PUERTO liberado."
    else
        echo "✅ Puerto $PUERTO libre."
    fi
}

# Liberar todos los puertos detectados
echo "🔹 Detectando contenedores en conflicto de puerto..."
for PUERTO in "${PUERTOS[@]}"; do
    liberar_puerto $PUERTO
done

# Limpiar contenedores antiguos
echo "🚀 Limpiando contenedores Docker antiguos..."
docker-compose down -v --remove-orphans

# Construir y levantar servicios
echo "🚀 Construyendo y levantando Docker Compose..."
docker-compose build --no-cache
docker-compose up -d

echo "✅ Todos los servicios levantados correctamente."
