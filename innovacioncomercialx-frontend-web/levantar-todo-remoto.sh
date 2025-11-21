#!/bin/bash
set -e

echo "🛑 Cerrando procesos antiguos..."
for port in 8080 19006 5001 5432; do
    if lsof -i:$port >/dev/null; then
        echo "🔹 Cerrando proceso en puerto $port..."
        kill -9 $(lsof -t -i:$port) || true
    fi
    echo "✅ Puerto $port libre"
done

echo "🧹 Limpiando contenedores e imágenes antiguas..."
docker compose down -v --remove-orphans || true

echo "🐳 Iniciando PostgreSQL en Docker..."
docker compose up -d db

echo "⏳ Esperando a que PostgreSQL acepte conexiones..."
until docker exec -i innovacioncomercialx-db-1 pg_isready -U $POSTGRES_USER >/dev/null 2>&1; do
    sleep 2
done
echo "✅ PostgreSQL listo!"

echo "🛠️ Verificando extensión pgcrypto y función uuid_generate_v4()..."
docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -d $POSTGRES_DB <<SQL
CREATE EXTENSION IF NOT EXISTS pgcrypto;
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'uuid_generate_v4') THEN
       CREATE FUNCTION uuid_generate_v4() RETURNS uuid AS 'SELECT gen_random_uuid();' LANGUAGE SQL;
   END IF;
END\$\$;
SQL

echo "🔧 Parcheando automáticamente todas las tablas con migraciones pendientes..."
# Detecta tablas que no tengan columna 'id' y agrega UUID
TABLES=$(docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -d $POSTGRES_DB -t -c "
SELECT table_name
FROM information_schema.tables
WHERE table_schema='public' AND table_type='BASE TABLE';
" | xargs)

for table in $TABLES; do
    HAS_ID=$(docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -d $POSTGRES_DB -t -c "
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='$table' AND column_name='id'
    );
    " | xargs)
    
    if [ "$HAS_ID" != "t" ]; then
        echo "🔹 Parcheando tabla $table con id UUID..."
        docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -d $POSTGRES_DB <<SQL
ALTER TABLE "$table" ADD COLUMN IF NOT EXISTS id UUID PRIMARY KEY DEFAULT uuid_generate_v4();
SQL
    fi
done
echo "✅ Todas las tablas parcheadas automáticamente"

mkdir -p ./backups

echo "🔄 Ejecutando migraciones y seeds..."
MAX_RETRIES=3
RETRY=0
SUCCESS=false
while [ $RETRY -lt $MAX_RETRIES ]; do
    set +e
    docker exec -i innovacioncomercialx-backend-1 npx sequelize db:migrate && \
    docker exec -i innovacioncomercialx-backend-1 npx sequelize db:seed:all
    if [ $? -eq 0 ]; then
        SUCCESS=true
        break
    else
        echo "❌ Error en migraciones/seeds. Haciendo backup y reiniciando DB..."
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        docker exec -i innovacioncomercialx-db-1 pg_dump -U $POSTGRES_USER $POSTGRES_DB > ./backups/icx_backup_$TIMESTAMP.sql
        docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -c "DROP DATABASE $POSTGRES_DB;"
        docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -c "CREATE DATABASE $POSTGRES_DB;"
    fi
    RETRY=$((RETRY+1))
    set -e
done

if [ "$SUCCESS" = false ]; then
    echo "❌ No se pudieron ejecutar migraciones/seeds después de $MAX_RETRIES intentos."
    echo "✅ Restaurando último backup..."
    LATEST_BACKUP=$(ls -t ./backups/icx_backup_*.sql | head -1)
    if [ -f "$LATEST_BACKUP" ]; then
        docker exec -i innovacioncomercialx-db-1 psql -U $POSTGRES_USER -d $POSTGRES_DB < "$LATEST_BACKUP"
    fi
fi

echo "🔨 Reconstruyendo imágenes Docker..."
if [ -f "innovacioncomercialx-frontend-web/frontend-web/nginx.conf" ]; then
    docker build -t frontend-web innovacioncomercialx-frontend-web/frontend-web
else
    echo "⚠️ nginx.conf no encontrado, se saltará configuración personalizada."
    docker build -t frontend-web innovacioncomercialx-frontend-web/frontend-web --build-arg SKIP_NGINX_CONF=true
fi

docker build -t innovacioncomercialx-backend backend
docker build -t frontend-mobile innovacioncomercialx-frontend-mobile

docker compose up -d
echo "✅ Todos los servicios levantados correctamente."
