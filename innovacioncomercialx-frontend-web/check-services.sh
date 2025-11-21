#!/bin/bash

echo "🔎 Verificando servicios de InnovacionComercialX..."

# Función para verificar si un puerto responde
check_service() {
  local name=$1
  local url=$2
  if curl -s --max-time 3 "$url" > /dev/null; then
    echo "🌐 $name ($url): ✅ Responde"
  else
    echo "🌐 $name ($url): ⚠️ No responde"
  fi
}

# Backend
check_service "Backend" "http://localhost:5002/api/users"

# Frontend Web
check_service "Frontend Web" "http://localhost:3000"

# Frontend Mobile (Expo)
check_service "Frontend Mobile" "http://localhost:19006"

# pgAdmin
check_service "pgAdmin" "http://localhost:5050"

echo "✔️ Checklist completado."
