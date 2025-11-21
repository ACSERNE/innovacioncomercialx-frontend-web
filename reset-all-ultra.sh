#!/bin/bash
set -e

echo "🧹 Limpiando contenedores, imágenes, redes y volúmenes huérfanos..."
docker compose down -v --remove-orphans
docker system prune -af --volumes || true

echo "🔍 Liberando puertos ocupados (3000, 5001, 19000)..."
for PORT in 3000 5001 19000; do
  PID=$(netstat -ano 2>/dev/null | grep ":$PORT " | awk '{print $5}' | sort -u)
  if [ -n "$PID" ]; then
    echo "⚠️  Puerto $PORT ocupado por PID(s): $PID. Matando proceso(s)..."
    for p in $PID; do
      taskkill //PID $p //F 2>/dev/null || true
    done
  else
    echo "✅ Puerto $PORT libre."
  fi
done

echo "⚡ Reconstruyendo y levantando servicios..."
docker compose up -d --build

echo "⏳ Esperando a que PostgreSQL esté listo..."
until docker exec innovacioncomercialx-db pg_isready -U postgres >/dev/null 2>&1; do
  echo "Esperando a PostgreSQL..."
  sleep 2
done
echo "✅ PostgreSQL listo."

echo "⏳ Esperando a que pgAdmin esté listo..."
sleep 5  # pgAdmin suele tardar unos segundos en arrancar
echo "✅ pgAdmin listo."

echo "📊 Resumen final de contenedores activos:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "🔍 Verificando puertos críticos..."
for PORT in 3000 5001 19000; do
  if netstat -ano 2>/dev/null | grep ":$PORT " >/dev/null; then
    echo "❌ Puerto $PORT sigue ocupado."
  else
    echo "✅ Puerto $PORT libre."
  fi
done

echo "✅ Todo levantado y listo!"
