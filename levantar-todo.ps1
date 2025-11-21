# ----------------------------
# Script PowerShell: levantar-todo.ps1
# ----------------------------

# Función para verificar si Docker está corriendo
function Check-Docker {
    try {
        docker info > $null 2>&1
        Write-Host "✅ Docker está corriendo."
        return $true
    } catch {
        Write-Host "❌ Docker no está corriendo. Inicia Docker Desktop primero."
        exit 1
    }
}

# Función para liberar un puerto
function Liberar-Puerto {
    param([int]$Puerto)

    $procs = netstat -ano | findstr ":$Puerto"
    if ($procs) {
        $pids = @()
        foreach ($line in $procs) {
            $pid = ($line -split "\s+")[-1]
            if ($pid -and ($pids -notcontains $pid)) { $pids += $pid }
        }
        foreach ($pid in $pids) {
            Write-Host "Puerto $Puerto ocupado por PID $pid. Cerrando proceso..."
            taskkill /PID $pid /F | Out-Null
        }
    } else {
        Write-Host "Puerto $Puerto está libre."
    }
}

# Función para esperar PostgreSQL
function Esperar-Postgres {
    param(
        [string]$Host = "localhost",
        [int]$Port = 5432,
        [int]$Timeout = 60
    )
    $i = 0
    while ($i -lt $Timeout) {
        try {
            $tcp = Test-NetConnection -ComputerName $Host -Port $Port
            if ($tcp.TcpTestSucceeded) {
                Write-Host "✅ PostgreSQL está listo."
                return
            }
        } catch {}
        Write-Host "⏳ Esperando PostgreSQL..."
        Start-Sleep -Seconds 2
        $i++
    }
    Write-Host "❌ Timeout esperando PostgreSQL."
    exit 1
}

# ----------------------------
# Inicio del script
# ----------------------------

# 1️⃣ Verificar Docker
Check-Docker

# 2️⃣ Liberar puertos
$puertos = @(3000, 19006, 5001)
foreach ($p in $puertos) {
    Liberar-Puerto -Puerto $p
}

# 3️⃣ Bajar contenedores y volúmenes
Write-Host "`n🧹 Limpiando contenedores y volúmenes..."
docker compose down -v

# 4️⃣ Levantar contenedores
Write-Host "`n🚀 Levantando Docker Compose..."
docker compose up -d --build

# 5️⃣ Esperar PostgreSQL
Esperar-Postgres -Host "localhost" -Port 5432

# 6️⃣ Ejecutar migraciones y seeds
Write-Host "`n🔄 Ejecutando migraciones y seeds..."
docker compose exec backend npx sequelize-cli db:migrate
docker compose exec backend npx sequelize-cli db:seed:all

# 7️⃣ Mensaje final
Write-Host "`n🎉 Todo levantado y listo para usar."
