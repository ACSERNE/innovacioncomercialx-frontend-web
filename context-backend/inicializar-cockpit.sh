#!/bin/bash
# 🛠️ Inicializador cockpitizado para context-backend

echo "🔍 Inicializando estructura cockpit..."

# Crear carpetas por país
for pais in CL MX ES; do
  dir="web-build/$pais"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    echo "✅ Carpeta creada: $dir"
  else
    echo "🔁 Carpeta ya existe: $dir"
  fi
done

# Crear archivos clave si no existen
declare -A archivos=(
  ["Makefile"]="Makefile cockpitizado"
  [".dockerignore"]="Exclusión de contexto"
  ["limpiar-contexto.sh"]="Limpieza quirúrgica"
  ["validar-visor.sh"]="Validación remota"
  ["verificar-contexto.sh"]="Diagnóstico técnico"
  ["dashboard-maestro.json"]="Federación visual"
  ["visor.html"]="Visor maestro"
)

for archivo in "${!archivos[@]}"; do
  if [[ ! -f "$archivo" ]]; then
    echo "⚙️ Generando ${archivos[$archivo]}: $archivo"
    touch "$archivo"  # Puedes reemplazar esto por el bloque cockpitizado real
  else
    echo "🔁 Ya existe: $archivo"
  fi
done

echo "🧭 Estructura cockpitizada lista para exportar, validar y desplegar"
