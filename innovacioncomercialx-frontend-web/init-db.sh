#!/bin/sh
set -e

echo "🛠️ Verificando extensiones requeridas en PostgreSQL..."

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

echo "✅ Extensión pgcrypto verificada!"
