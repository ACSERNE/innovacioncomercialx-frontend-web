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
