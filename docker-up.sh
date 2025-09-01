#!/bin/bash
set -e

echo "🛑 Deteniendo y eliminando contenedores antiguos..."
docker-compose down -v

echo "🔨 Construyendo imágenes y levantando servicios..."
docker-compose up --build -d

echo "⏳ Esperando a que PostgreSQL esté listo en postgres-innovacion:5432..."
until docker exec postgres-innovacion pg_isready -U $DB_USER -d $DB_NAME; do
  sleep 2
done

echo "✅ PostgreSQL listo"
echo "🚀 Todos los servicios deberían estar levantados:"
echo "🔹 Backend: http://localhost:5002"
echo "🔹 Frontend Web: http://localhost:3000"
echo "🔹 Frontend Móvil (Expo): http://localhost:19006"
echo "🔹 pgAdmin: http://localhost:8080"
