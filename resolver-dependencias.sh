#!/bin/bash
# Script quirúrgico para resolver conflictos de dependencias en frontend-mobile

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/dependencias-$timestamp.log"
mkdir -p logs

echo "🔍 Verificando react-native-web inválido..." | tee "$log"

# Buscar última versión válida de react-native-web@0.19.x
version=$(npm view react-native-web versions | grep '^0\.19\.' | tail -1)

if [ -z "$version" ]; then
  echo "❌ No se encontró versión válida para react-native-web@0.19.x" | tee -a "$log"
else
  echo "✅ Versión sugerida: react-native-web@$version" | tee -a "$log"
  sed -i "s/react-native-web@0.19.16/react-native-web@$version/" package.json
  echo "🛠️ package.json actualizado con versión válida" | tee -a "$log"
fi

echo "📦 Ejecutando instalación forzada..." | tee -a "$log"
npm install --legacy-peer-deps >> "$log" 2>&1

echo "📋 Log técnico generado: $log"
