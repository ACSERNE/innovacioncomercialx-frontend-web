#!/bin/bash
set -e

BASE_DIR="$(pwd)"
BACKUP_DIR="$BASE_DIR/backup_$(date +%Y%m%d%H%M%S)"
CONFLICTS=0

echo "🧹 Iniciando limpieza avanzada del proyecto..."
mkdir -p "$BACKUP_DIR"

# Función para mover archivos evitando sobrescritura
move_file() {
    SRC="$1"
    DEST="$2"
    BASENAME=$(basename "$SRC")
    if [ -e "$DEST/$BASENAME" ]; then
        i=1
        EXT="${BASENAME##*.}"
        NAME="${BASENAME%.*}"
        while [ -e "$DEST/$NAME"_"$i"."$EXT" ]; do
            ((i++))
        done
        BASENAME="$NAME"_"$i"."$EXT"
        ((CONFLICTS++))
        echo "⚠️ Conflicto: $SRC renombrado a $BASENAME"
    fi
    mv "$SRC" "$DEST/$BASENAME"
}

# Crear estructura frontend-web
mkdir -p "$BASE_DIR/frontend-web/src"
mkdir -p "$BASE_DIR/frontend-web/public"

# Procesar frontends
for dir in "$BASE_DIR"/*/; do
    if [ -d "$dir/src" ] || [ -d "$dir/public" ]; then
        FRONTEND=$(basename "$dir")
        [ "$FRONTEND" == "frontend-web" ] && continue
        echo "📂 Procesando frontend: $FRONTEND"
        cp -r "$dir" "$BACKUP_DIR/"
        # Mover src
        if [ -d "$dir/src" ]; then
            for f in "$dir/src"/*; do
                [ -e "$f" ] && move_file "$f" "$BASE_DIR/frontend-web/src"
            done
        fi
        # Mover public
        if [ -d "$dir/public" ]; then
            for f in "$dir/public"/*; do
                [ -e "$f" ] && move_file "$f" "$BASE_DIR/frontend-web/public"
            done
        fi
        rm -rf "$dir"
    fi
done

# Procesar backends
for dir in "$BASE_DIR"/*/; do
    if [ -f "$dir/package.json" ]; then
        BACKEND=$(basename "$dir")
        if [ "$BACKEND" != "backend" ]; then
            echo "📂 Moviendo backend: $BACKEND"
            cp -r "$dir" "$BACKUP_DIR/"
            mv "$dir" "$BASE_DIR/backend" 2>/dev/null || true
        fi
    fi
done

# Eliminar OneDrive
ONEDRIVE_PATH="$BASE_DIR/OneDrive"
if [ -d "$ONEDRIVE_PATH" ]; then
    echo "🗑 Eliminando OneDrive..."
    rm -rf "$ONEDRIVE_PATH"
fi

echo "✅ Proyecto unificado correctamente."
echo "📦 Respaldo de carpetas en: $BACKUP_DIR"
echo "⚠️ Conflictos renombrados: $CONFLICTS"

