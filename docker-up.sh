#!/bin/bash
# Script cockpitizado para validar estructura, instalar dependencias y levantar entorno

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="logs/deploy-$timestamp.log"
mkdir -p logs

echo "🚀 Iniciando validación estructural..." | tee "$log"
./verificador-estructura.sh >> "$log" 2>&1

echo "🔧 Construyendo contenedores por entorno..." | tee -a "$log"
docker-compose build backend >> "$log" 2>&1
docker-compose build frontend-web >> "$log" 2>&1
docker-compose build frontend-mobile >> "$log" 2>&1

echo "🟢 Levantando entorno cockpitizado..." | tee -a "$log"
docker-compose up >> "$log" 2>&1

echo "📋 Log técnico generado: $log"
