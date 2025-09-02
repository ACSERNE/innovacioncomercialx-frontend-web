#!/bin/bash
# Script de limpieza y diagnóstico de contexto Docker

echo "🔍 Verificando .dockerignore..."
if [[ -f .dockerignore ]]; then
  echo "✅ .dockerignore encontrado"
else
  echo "⚠️  .dockerignore no existe. Recomendado para evitar saturación"
fi

echo "📦 Calculando tamaño del contexto..."
du -sh . | grep -v node_modules

echo "🧹 Archivos sugeridos para excluir:"
echo "----------------------------------"
cat <<EOL
node_modules
.git
*.log
*.tmp
*.sqlite
coverage
.env
.DS_Store
.vscode
__pycache__/
EOL

echo "----------------------------------"
echo "🧭 Recomendación: revisa y actualiza .dockerignore antes de ejecutar:"
echo "docker build -t backend-cockpit ."
