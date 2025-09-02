#!/bin/bash
# 🚀 Script cockpitizado para desplegar en GitHub Pages

echo "🔍 Verificando estado del repositorio..."

# Verificar si hay cambios
if [[ -n $(git status --porcelain) ]]; then
  echo "📦 Cambios detectados. Preparando commit..."
  git add .
  git commit -m "Despliegue cockpitizado en GitHub Pages: visor federado y dashboard maestro"
else
  echo "✅ No hay cambios pendientes. Nada que commitear."
fi

# Verificar conexión remota
if git remote -v | grep -q "github.com"; then
  echo "🌐 Repositorio remoto detectado:"
  git remote -v
else
  echo "❌ No se detectó repositorio remoto. Agrega uno con:"
  echo "git remote add origin https://github.com/usuario/repositorio.git"
  exit 1
fi

# Push a rama main
echo "🚀 Haciendo push a GitHub..."
git push origin main

# Confirmar URL pública
REPO=$(git remote get-url origin | sed 's/.*github.com[:\/]//' | sed 's/.git$//')
USER=$(echo "$REPO" | cut -d'/' -f1)
NAME=$(echo "$REPO" | cut -d'/' -f2)

echo "🌐 Tu visor cockpitizado estará disponible en:"
echo "https://$USER.github.io/$NAME/visor.html"

echo "🧭 Si usas dominio personalizado, configúralo en Settings → Pages → Custom Domain"
