#!/bin/bash
# Script cockpitizado para verificar entorno y contexto técnico

echo "🔍 Verificando entorno..."

# Detectar shell
if grep -q "Microsoft" /proc/version 2>/dev/null; then
  echo "🧠 Estás en WSL (Linux sobre Windows)"
elif [[ "$OSTYPE" == "msys" ]]; then
  echo "🧠 Estás en Git Bash sobre Windows"
else
  echo "🧠 Entorno desconocido o no soportado"
fi

# Verificar comando make
if command -v make >/dev/null 2>&1; then
  echo "✅ 'make' está instalado"
else
  echo "⚠️  'make' no está instalado. Instálalo con Chocolatey o apt según tu entorno"
fi

# Verificar scripts cockpitizados
for script in limpiar-contexto.sh validar-visor.sh; do
  if [[ -f "$script" ]]; then
    echo "✅ Script '$script' encontrado"
  else
    echo "⚠️  Script '$script' no existe. Recomendado para validación y limpieza"
  fi
done

# Verificar .dockerignore
if [[ -f .dockerignore ]]; then
  echo "✅ .dockerignore presente"
else
  echo "⚠️  .dockerignore no encontrado. Recomendado para evitar saturación de contexto"
fi

echo "🧭 Recomendación: ejecuta 'make limpiar' y 'make validar' si todo está alineado"
