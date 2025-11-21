# =========================================
# Levantar todo: Backend + Frontend Web + Mobile
# =========================================

# Cambiar directorio a la raíz del proyecto
Set-Location -Path "C:\Users\usuario\innovacioncomercialx"

# Cargar variables de entorno desde .env
if (Test-Path ".env") {
    Get-Content .env | ForEach-Object {
        if ($_ -notmatch '^#' -and $_ -match '=') {
            $parts = $_ -split '='
            [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1], "Process")
        }
    }
    Write-Host "✔ Variables de entorno cargadas desde .env"
} else {
    Write-Host "⚠ No se encontró archivo .env"
}

# Limpiar contenedores, redes y cache antiguos
Write-Host "✔ Limpiando contenedores y redes antiguas..."
docker system prune -af --volumes
Write-Host "✔ Cache y contenedores antiguos eliminados"

# =========================================
# Build y levantamiento de contenedores
# =========================================

# Levantar backend
Write-Host "✔ Construyendo y levantando Backend..."
docker build --no-cache -t innovacion-backend ./backend
docker run -d --name backend -p 5001:5001 --env-file .env innovacion-backend

# Levantar frontend web
Write-Host "✔ Construyendo y levantando Frontend Web..."
docker build --no-cache -t innovacion-frontend-web ./frontend-web
docker run -d --name frontend-web -p 3000:80 innovacion-frontend-web

# Levantar frontend mobile (Expo)
Write-Host "✔ Construyendo y levantando Frontend Mobile..."
docker build --no-cache -t innovacion-frontend-mobile ./frontend-mobile
docker run -d --name frontend-mobile -p 19006:19006 innovacion-frontend-mobile

Write-Host "✅ Todos los servicios levantados correctamente"
