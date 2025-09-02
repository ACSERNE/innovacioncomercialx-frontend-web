#!/bin/bash
echo "🧬 Generando cápsula técnica context-backend/..."

# Crear carpeta limpia
rm -rf context-backend
mkdir context-backend

# Symlinks quirúrgicos
ln -s ../backend/Dockerfile context-backend/Dockerfile
ln -s ../backend/src context-backend/src
ln -s ../backend/package.json context-backend/package.json
ln -s ../backend/package-lock.json context-backend/package-lock.json 2>/dev/null

# Dockerignore mínimo
cat <<DOCKERIGNORE > context-backend/.dockerignore
node_modules
public
logs
*.log
*.csv
*.json
*.md
*.html
*.pdf
*.sqlite
DOCKERIGNORE

echo "✅ Contexto federado listo en context-backend/"
echo "🚀 Ejecuta: docker build -f Dockerfile . dentro de context-backend/"
