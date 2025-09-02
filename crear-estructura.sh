#!/bin/bash
# Script cockpitizado para preparar estructura de proyecto

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/estructura-$timestamp.log"
mkdir -p logs

echo "📁 Creando .dockerignore en carpetas clave..." | tee "$log"
for dir in backend frontend-web frontend-mobile; do
  if [ -d "$dir" ]; then
    cat <<'DOCKERIGNORE' > "$dir/.dockerignore"
node_modules
logs
*.log
*.csv
*.xlsx
*.pdf
.env
.DS_Store
DOCKERIGNORE
    echo "✅ .dockerignore creado en $dir/" | tee -a "$log"
  else
    echo "⚠️ Carpeta no encontrada: $dir/" | tee -a "$log"
  fi
done

echo "🔐 Creando archivo .env en la raíz..." | tee -a "$log"
cat <<'ENV' > .env
PORT=4000
FRONTEND_WEB_PORT=3000
FRONTEND_MOBILE_PORT=19006

POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=comercialx

PGADMIN_DEFAULT_EMAIL=admin@comercialx.com
PGADMIN_DEFAULT_PASSWORD=admin123

DB_HOST=db
DB_PORT=5432
DB_NAME=comercialx
DB_USER=admin
DB_PASSWORD=admin123
ENV
echo "✅ .env creado en la raíz" | tee -a "$log"

echo "🔧 Generando build-por-servicio.sh..." | tee -a "$log"
cat <<'BUILDSCRIPT' > build-por-servicio.sh
#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/build-$timestamp.log"
mkdir -p logs

for servicio in backend frontend-web frontend-mobile; do
  echo "🔧 Construyendo $servicio..." | tee -a "$log"
  docker-compose build "$servicio" >> "$log" 2>&1
  estado=$?
  if [ $estado -eq 0 ]; then
    echo "✅ $servicio construido correctamente" | tee -a "$log"
  else
    echo "❌ Error al construir $servicio" | tee -a "$log"
  fi
done

echo "📋 Log técnico generado: $log"
BUILDSCRIPT
chmod +x build-por-servicio.sh
echo "✅ build-por-servicio.sh listo para ejecutar" | tee -a "$log"

echo "📋 Log técnico generado: $log"
