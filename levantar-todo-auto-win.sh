#!/bin/bash
set -e

echo "⚙️ MODO ULTRA AUTOMÁTICO ACTIVADO"

# PUERTOS INICIALES
FRONTEND_PORT=3000
BACKEND_PORT=5001
MOBILE_PORT=19006

# Función para cerrar procesos por puerto en Windows
kill_port() {
  local port=$1
  local pid
  pid=$(netstat -ano | grep ":$port " | awk '{print $5}' | tr -d '\r')
  if [[ -n "$pid" ]]; then
    echo "🛑 Cerrando proceso en puerto $port (PID $pid)..."
    taskkill //PID $pid //F 2>/dev/null || echo "No se pudo cerrar PID $pid"
  fi
}

# CERRAR PROCESOS SI PUERTOS OCUPADOS
kill_port $FRONTEND_PORT
kill_port $BACKEND_PORT
kill_port $MOBILE_PORT

# Función para chequear puerto libre
check_port() {
  local port=$1
  if netstat -ano 2>/dev/null | grep -q ":$port "; then
    return 1
  else
    return 0
  fi
}

# Buscar puerto libre
find_free_port() {
  local start_port=$1
  while true; do
    if check_port "$start_port"; then
      echo "$start_port"
      return
    fi
    start_port=$((start_port + 1))
  done
}

# BUSCAR PUERTOS LIBRES
FRONTEND_PORT=$(find_free_port $FRONTEND_PORT)
BACKEND_PORT=$(find_free_port $BACKEND_PORT)
MOBILE_PORT=$(find_free_port $MOBILE_PORT)

echo "🟢 Puerto frontend: $FRONTEND_PORT"
echo "🟢 Puerto backend: $BACKEND_PORT"
echo "🟢 Puerto mobile: $MOBILE_PORT"

# RESPALDAR docker-compose.yml
cp docker-compose.yml docker-compose.yml.bak

# ACTUALIZAR docker-compose.yml con los nuevos puertos
sed -i.bak "s/- '3000:3000'/- '${FRONTEND_PORT}:3000'/g" docker-compose.yml
sed -i.bak "s/- '5001:5001'/- '${BACKEND_PORT}:5001'/g" docker-compose.yml
sed -i.bak "s/- '19006:19006'/- '${MOBILE_PORT}:19006'/g" docker-compose.yml

# LIMPIAR DOCKER
echo "🧹 Limpiando Docker..."
docker compose down -v --remove-orphans || true
docker system prune -a -f || true
docker volume prune -f || true

# RECONSTRUIR IMÁGENES
echo "🔨 Reconstruyendo imágenes..."
docker compose build --no-cache

# LEVANTAR CONTENEDORES
echo "🚀 Iniciando contenedores..."
docker compose up -d

# RESTAURAR docker-compose.yml original
mv docker-compose.yml.bak docker-compose.yml

echo "======================================"
echo "✅ TODO LISTO - ENTORNO INICIADO"
echo "🌐 Frontend: http://localhost:$FRONTEND_PORT"
echo "🧠 Backend:  http://localhost:$BACKEND_PORT"
echo "📱 Mobile:   http://localhost:$MOBILE_PORT"
echo "======================================"
