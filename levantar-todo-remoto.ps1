# levantar-todo-remoto.ps1
# ---------------------------------------------------
# Levanta Docker DB + backend + frontend + ngrok + QR + navegador
# ---------------------------------------------------

# ------------------------------
# Configuración de carpetas
# ------------------------------
$ROOT_DIR     = "$PWD"
$FRONTEND_DIR = "$ROOT_DIR/frontend-web"
$BACKEND_DIR  = "$ROOT_DIR/backend"
$QR_DIR       = "$ROOT_DIR/deploy/qr"

# Crear carpeta QR si no existe
if (-Not (Test-Path $QR_DIR)) { New-Item -ItemType Directory -Path $QR_DIR | Out-Null }

# ------------------------------
# Configuración de puertos
# ------------------------------
$START_PORT_FRONTEND = 8080
$PORT_FRONTEND = $START_PORT_FRONTEND
while (Test-NetConnection -ComputerName 127.0.0.1 -Port $PORT_FRONTEND -InformationLevel Quiet) {
    Write-Host "⚠️ Puerto $PORT_FRONTEND ocupado, probando siguiente..." -ForegroundColor Yellow
    $PORT_FRONTEND++
}
Write-Host "✅ Puerto libre frontend: $PORT_FRONTEND" -ForegroundColor Green

$PORT_BACKEND = 5001
while (Test-NetConnection -ComputerName 127.0.0.1 -Port $PORT_BACKEND -InformationLevel Quiet) {
    Write-Host "⚠️ Puerto $PORT_BACKEND ocupado, probando siguiente..." -ForegroundColor Yellow
    $PORT_BACKEND++
}
Write-Host "✅ Puerto libre backend: $PORT_BACKEND" -ForegroundColor Green

$PORT_DB = 5432
while (Test-NetConnection -ComputerName 127.0.0.1 -Port $PORT_DB -InformationLevel Quiet) {
    Write-Host "⚠️ Puerto $PORT_DB ocupado, probando siguiente..." -ForegroundColor Yellow
    $PORT_DB++
}
Write-Host "✅ Puerto libre PostgreSQL: $PORT_DB" -ForegroundColor Green

# ------------------------------
# Levantar Docker DB
# ------------------------------
Write-Host "🐳 Iniciando PostgreSQL en Docker..." -ForegroundColor Cyan
docker run -d --name icx-db `
    -e POSTGRES_USER=postgres `
    -e POSTGRES_PASSWORD=postgres `
    -e POSTGRES_DB=icxdb `
    -p $PORT_DB:5432 `
    postgres:15-alpine | Out-Null
Start-Sleep -Seconds 5

# ------------------------------
# Levantar backend
# ------------------------------
Write-Host "⚙️ Iniciando backend en $PORT_BACKEND..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $BACKEND_DIR; npm install; npx nodemon index.js --port $PORT_BACKEND" -WindowStyle Hidden
Start-Sleep -Seconds 3

# ------------------------------
# Levantar frontend
# ------------------------------
Write-Host "⚙️ Iniciando frontend en $PORT_FRONTEND..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $FRONTEND_DIR; npm install; npx serve -s build -l $PORT_FRONTEND" -WindowStyle Hidden
Start-Sleep -Seconds 3

# ------------------------------
# Levantar ngrok
# ------------------------------
try {
    $ngrokApi = Invoke-RestMethod http://127.0.0.1:4040/api/tunnels -ErrorAction Stop
    $ngrokUrl = $ngrokApi.tunnels | Where-Object {$_.proto -eq "https"} | Select-Object -First 1 -ExpandProperty public_url
    Write-Host "ℹ️ ngrok ya tiene túnel activo: $ngrokUrl" -ForegroundColor Cyan
} catch {
    Write-Host "🌐 Iniciando ngrok para frontend..." -ForegroundColor Cyan
    # Cerrar procesos ngrok existentes por seguridad
    Get-Process ngrok -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Process ngrok -ArgumentList "http $PORT_FRONTEND" -WindowStyle Hidden
    Start-Sleep -Seconds 5
    $ngrokApi = Invoke-RestMethod http://127.0.0.1:4040/api/tunnels
    $ngrokUrl = $ngrokApi.tunnels | Where-Object {$_.proto -eq "https"} | Select-Object -First 1 -ExpandProperty public_url
}

Write-Host "✅ URL pública ngrok: $ngrokUrl" -ForegroundColor Green

# ------------------------------
# Generar QR dinámico
# ------------------------------
$QR_HTML = @"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Acceso Innovacion Comercial X</title>
</head>
<body style="font-family:sans-serif;text-align:center;margin-top:50px;">
  <h1>📱 Acceso rápido</h1>
  <p>Escanea este código QR para abrir el frontend en tu celular:</p>
  <img src="https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$ngrokUrl" alt="QR Code" />
  <p><a href="$ngrokUrl" target="_blank">Abrir en navegador</a></p>
</body>
</html>
"@
$QR_HTML | Set-Content -Path "$QR_DIR/index.html" -Encoding UTF8
Write-Host "✅ Página QR actualizada: $QR_DIR/index.html" -ForegroundColor Green

# ------------------------------
# Abrir navegador con User-Agent personalizado
# ------------------------------
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$customUA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ngrok-skip-browser-warning"
Start-Process -FilePath $chromePath -ArgumentList "--new-window", "$ngrokUrl", "--user-agent=$customUA"

Write-Host "🎉 Proyecto remoto levantado correctamente!" -ForegroundColor Green
