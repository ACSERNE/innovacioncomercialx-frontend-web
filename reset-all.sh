#!/bin/bash
set -e

echo "🧹 Limpiando contenedores, redes, volúmenes e imágenes huérfanas..."
docker compose down -v --remove-orphans || true
docker system prune -af --volumes || true

# Función para liberar puertos ocupados
free_port() {
  PORT=$1
  echo "🔓 Verificando puerto $PORT..."
  if command -v lsof >/dev/null 2>&1; then
    PID=$(lsof -ti tcp:$PORT)
    if [ -n "$PID" ]; then
      echo "💥 Puerto $PORT ocupado por PID $PID, matando proceso..."
      kill -9 $PID || true
      sleep 2
    else
      echo "✅ Puerto $PORT libre."
    fi
  else
    echo "⚠️ lsof no disponible, no se puede verificar puerto $PORT. Asegúrate que esté libre manualmente."
  fi
}

# Lista de puertos que usan los servicios
PORTS=(3000 19000 5001 8080 5432)

for P in "${PORTS[@]}"; do
  free_port $P
done

echo "⚡ Reconstruyendo y levantando todos los servicios..."
docker compose up -d --build

echo "⏳ Esperando a que PostgreSQL esté listo..."
until docker exec innovacioncomercialx-db pg_isready -U postgres >/dev/null 2>&1; do
  echo "Esperando a PostgreSQL..."
  sleep 2
done
echo "✅ PostgreSQL listo."

echo "⏳ Esperando 10s para que pgAdmin y frontends se inicien..."
sleep 10

echo "📊 Contenedores activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "✅ Todos los servicios levantados correctamente!"
docker compose logs -f --tail=50
