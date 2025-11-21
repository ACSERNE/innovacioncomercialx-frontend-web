#!/bin/bash

# --- Funciones ---
wait_for_postgres() {
  echo "⏳ Esperando que PostgreSQL esté listo..."
  until docker exec -i icx-db pg_isready -U postgres > /dev/null 2>&1; do
    echo "Esperando PostgreSQL..."
    sleep 2
  done
  echo "✅ PostgreSQL listo!"
}

enable_uuid_extension() {
  docker exec -i icx-db psql -U postgres -d icx -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
}

mkdir -p ./backups

backup_database() {
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  BACKUP_FILE="./backups/icx_backup_$TIMESTAMP.sql"
  echo "💾 Creando backup de la base de datos en $BACKUP_FILE..."
  docker exec -i icx-db pg_dump -U postgres icx > "$BACKUP_FILE"
  echo "✅ Backup completado"
}

restore_last_backup() {
  LATEST_BACKUP=$(ls -t ./backups/icx_backup_*.sql 2>/dev/null | head -1)
  if [ -f "$LATEST_BACKUP" ]; then
    echo "♻️ Restaurando base de datos desde el último backup: $LATEST_BACKUP"
    docker exec -i icx-db psql -U postgres -c "DROP DATABASE IF EXISTS icx;"
    docker exec -i icx-db psql -U postgres -c "CREATE DATABASE icx;"
    docker exec -i icx-db psql -U postgres icx < "$LATEST_BACKUP"
    enable_uuid_extension
    echo "✅ Restauración completada"
  else
    echo "⚠️ No hay backup disponible para restaurar"
  fi
}

reset_database() {
  backup_database
  echo "🗑️ Reiniciando base de datos icx..."
  docker exec -i icx-db psql -U postgres -c "DROP DATABASE IF EXISTS icx;"
  docker exec -i icx-db psql -U postgres -c "CREATE DATABASE icx;"
  enable_uuid_extension
}

run_migrations_and_seeds() {
  cd backend
  local RETRIES=3
  local COUNT=0
  while [ $COUNT -lt $RETRIES ]; do
    echo "🔄 Ejecutando migraciones y seeds... intento $((COUNT+1))"
    if npx sequelize db:migrate && npx sequelize db:seed:all; then
      cd ..
      return 0
    else
      echo "❌ Error en migraciones/seeds. Se hará backup y se reiniciará la DB..."
      reset_database
    fi
    COUNT=$((COUNT+1))
    sleep 3
  done
  echo "❌ No se pudieron ejecutar migraciones/seeds después de $RETRIES intentos. Intentando restaurar desde último backup..."
  restore_last_backup
  cd ..
}

# --- Script principal ---
echo "🛑 Cerrando procesos antiguos..."
taskkill //F //IM node.exe //T 2>nul
taskkill //F //IM ngrok.exe //T 2>nul

FRONTEND_WEB_PORT=8080
FRONTEND_MOBILE_PORT=19006
BACKEND_PORT=5001
POSTGRES_PORT=5432

echo "✅ Puertos libres verificados"

# Limpiar contenedores e imágenes antiguas
echo "🧹 Limpiando contenedores e imágenes antiguas..."
docker compose down -v
docker system prune -af

# Reconstruir imágenes Docker
echo "🔨 Reconstruyendo imágenes Docker..."
docker build -t innovacion-backend ./backend
docker build -t innovacion-frontend-web ./frontend-web
docker build -t innovacion-frontend-mobile ./frontend-mobile

# Iniciar PostgreSQL
echo "🐳 Iniciando PostgreSQL en Docker..."
docker run -d --name icx-db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=icx -p $POSTGRES_PORT:5432 postgres:15

wait_for_postgres
enable_uuid_extension

# Migraciones y seeds con reintentos y restauración automática
run_migrations_and_seeds

# Levantar backend
echo "⚙️ Iniciando backend en $BACKEND_PORT..."
start cmd /k "cd backend && nodemon index.js"

# Levantar frontend web
echo "⚙️ Levantando frontend web en $FRONTEND_WEB_PORT..."
start cmd /k "cd frontend-web && npm start"

# Levantar frontend móvil (Expo)
echo "⚙️ Levantando frontend móvil en $FRONTEND_MOBILE_PORT..."
start cmd /k "cd frontend-mobile && npm start"

# Cerrar cualquier túnel ngrok existente
ngrok_pid=$(tasklist | findstr ngrok.exe | awk '{print $2}')
if [ ! -z "$ngrok_pid" ]; then
  echo "🔒 Cerrando ngrok existente..."
  taskkill //F //PID $ngrok_pid
fi

# Iniciar ngrok para frontend web
echo "🌐 Iniciando ngrok para frontend web..."
start cmd /k "ngrok http $FRONTEND_WEB_PORT"

echo "🎉 Proyecto remoto levantado correctamente!"
echo "✅ Backend: http://localhost:$BACKEND_PORT"
echo "✅ Frontend Web: http://localhost:$FRONTEND_WEB_PORT"
echo "✅ Frontend Móvil (Expo): exp://localhost:$FRONTEND_MOBILE_PORT"
echo "✅ Todos los backups de DB se guardan en ./backups"
