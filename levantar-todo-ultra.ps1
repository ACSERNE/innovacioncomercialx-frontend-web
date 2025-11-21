# ============================
# Script PowerShell para levantar todo
# ============================

# Función para obtener un puerto libre
function Get-FreePort {
    param([int]$StartPort=5003)
    $Port = $StartPort
    while (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue) {
        $Port++
    }
    return $Port
}

Write-Host "🛠 Ajustando entorno y configuraciones..."

# --- Detectar puerto libre para backend ---
$PORT = Get-FreePort
Write-Host "✅ Puerto asignado para backend: $PORT"

# --- Actualizar server.js ---
$serverPath = ".\backend\server.js"
if (Test-Path $serverPath) {
    (Get-Content $serverPath) | ForEach-Object { $_ -replace 'const PORT = .*;', "const PORT = $PORT;" } | Set-Content $serverPath
    Write-Host "✅ server.js actualizado con puerto $PORT"
}

# --- Actualizar .env ---
$envPath = ".\.env"
if (Test-Path $envPath) {
    if (Select-String -Path $envPath -Pattern '^PORT=' -Quiet) {
        (Get-Content $envPath) | ForEach-Object { $_ -replace '^PORT=.*', "PORT=$PORT" } | Set-Content $envPath
    } else {
        Add-Content -Path $envPath -Value "PORT=$PORT"
    }
    Write-Host "✅ .env actualizado con puerto $PORT"
}

# --- Crear docker-compose.yml ---
@"
services:
  backend:
    build: ./backend
    ports:
      - "$PORT:$PORT"
    environment:
      - PORT=$PORT
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=innovacion
    networks:
      - innovacioncomercialx-net
  frontend-web:
    build: ./frontend/web
    ports:
      - "3000:3000"
    networks:
      - innovacioncomercialx-net
  frontend-mobile:
    build: ./frontend/mobile
    ports:
      - "19000:19000"
    networks:
      - innovacioncomercialx-net
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=innovacion
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - innovacioncomercialx-net
  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "8082:80"
    networks:
      - innovacioncomercialx-net

volumes:
  postgres_data:

networks:
  innovacioncomercialx-net:
"@ | Set-Content docker-compose.yml

Write-Host "🔧 docker-compose.yml creado con puertos actualizados."

# --- Limpiar contenedores, volúmenes y redes antiguas ---
Write-Host "🧹 Limpiando contenedores, volúmenes y redes antiguas..."
docker compose down -v -t 0

$containers = docker ps -aq
if ($containers) {
    docker rm -f $containers
}

docker volume prune -f
docker network prune -f

# --- Levantar todo ---
Write-Host "🚀 Levantando contenedores..."
docker compose up -d --build

Write-Host "✅ Todo listo. Contenedores levantados correctamente."
Write-Host "🌐 FRONTEND WEB en http://localhost:3000"
Write-Host "📱 FRONTEND MOBILE en http://localhost:19000"
Write-Host "🧠 BACKEND en http://localhost:$PORT"
Write-Host "🐘 PostgreSQL en puerto 5433"
Write-Host "🗂 PgAdmin en http://localhost:8082"
