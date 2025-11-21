# mover-backend.ps1
# Script para mover contenido de backend/backend a backend y limpiar

$basePath = "C:\Users\usuario\innovacioncomercialx\backend"

Write-Host "🔹 Moviendo archivos de backend/backend a backend..."
# Usamos robocopy para copiar y sobrescribir archivos y carpetas
robocopy "$basePath\backend" "$basePath" /E /MOVE /NFL /NDL /NJH /NJS /nc /ns /np

Write-Host "🔹 Eliminando carpeta backend/backend si quedó vacía..."
Remove-Item "$basePath\backend" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "🔹 Instalando dependencias..."
cd $basePath
npm install

Write-Host "🔹 Iniciando servidor en modo dev..."
npm run dev
