#!/bin/bash
# Script de validación federada para visor frontend-mobile

URL_BASE="https://tudominio.com"  # ← reemplaza con tu dominio en producción

artefactos=(
  "index.html"
  "visor-frontend.html"
  "dashboard-frontend.json"
  "badge-cl.svg"
  "badge-mx.svg"
  "badge-es.svg"
)

echo "🔍 Validando artefactos cockpitizados en $URL_BASE"
echo "-----------------------------------------------"

for archivo in "${artefactos[@]}"; do
  url="$URL_BASE/$archivo"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [[ "$status" == "200" ]]; then
    echo "✅ $archivo accesible"
  else
    echo "❌ $archivo no disponible (HTTP $status)"
  fi
done

echo "-----------------------------------------------"
echo "🧭 Validación completada $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
