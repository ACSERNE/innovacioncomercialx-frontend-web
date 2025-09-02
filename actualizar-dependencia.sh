#!/bin/bash
# Script quirúrgico para actualizar react-native-web a una versión válida

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/actualizacion-$timestamp.log"
mkdir -p logs

echo "🔍 Buscando versión válida para react-native-web..." | tee "$log"

# Buscar última versión publicada en 0.18.x o 0.20.x
version=$(npm view react-native-web versions | grep -E '^0\.18\.|^0\.20\.' | tail -1)

if [ -z "$version" ]; then
  echo "❌ No se encontró versión válida en 0.18.x ni 0.20.x" | tee -a "$log"
else
  echo "✅ Versión sugerida: react-native-web@$version" | tee -a "$log"
  sed -i "s/react-native-web@0.19.16/react-native-web@$version/" package.json
  echo "🛠️ package.json actualizado con versión válida" | tee -a "$log"
fi

echo "📦 Ejecutando instalación forzada..." | tee -a "$log"
npm install --legacy-peer-deps >> "$log" 2>&1

echo "📋 Log técnico generado: $log"
