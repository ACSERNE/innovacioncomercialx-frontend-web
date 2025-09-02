#!/bin/bash
# Script quirúrgico para detectar estructura y validar package.json

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/estructura-$timestamp.log"
mkdir -p logs

echo "🔍 Escaneando estructura de proyecto..." | tee "$log"

for dir in */; do
  if [ -f "$dir/package.json" ]; then
    echo "✅ package.json encontrado en: $dir" | tee -a "$log"
    echo "📦 Ejecutando instalación forzada en $dir..." | tee -a "$log"
    (cd "$dir" && npm install --legacy-peer-deps >> "../$log" 2>&1)
  else
    echo "⚠️ No se encontró package.json en: $dir" | tee -a "$log"
  fi
done

echo "📋 Log técnico generado: $log"
