#!/bin/bash
set -e

echo "🛠 Ajustando entorno y configuraciones..."

# Buscar el primer puerto libre entre 5001 y 5010
for port in {5001..5010}; do
  if ! netstat -ano 2>/dev/null | grep -q ":$port "; then
    BACKEND_PORT=$port
    break
  fi
done

if [ -z "$BACKEND_PORT" ]; then
  echo "❌ No se encontró ningún puerto libre entre 5001 y 5010."
  exit 1
fi

echo "✅ Puerto asignado para backend: $BACKEND_PORT"

# Actualizar .env
if [ -f ".env" ]; then
  sed -i "s/^PORT=.*/PORT=$BACKEND_PORT/" .env || echo "PORT=$BACKEND_PORT" >> .env
else
  echo "PORT=$BACKEND_PORT" > .env
fi
echo "✅ .env actualizado con puerto $BACKEND_PORT"

# Actualizar server.js
if [ -f "backend/server.js" ]; then
  sed -i "s/const PORT = .*/const PORT = process.env.PORT || $BACKEND_PORT;/" backend/server.js
  echo "✅ server.js actualizado con puerto $BACKEND_PORT"
else
  echo "⚠️ No se encontró backend/server.js"
fi

# Crear docker-compose.yml actualizado
cat <<DOCKER > docker-compose.yml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: \${DB_NAME}
      POSTGRES_USER: \${DB_USER}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - innovacioncomercialx_postgres_data:/var/lib/postgresql/data
    networks:
      - innovacioncomercialx-net

  backend:
    build: ./backend
    ports:
      - "$BACKEND_PORT:$BACKEND_PORT"
    environment:
      - PORT=$BACKEND_PORT
      - DB_NAME=\${DB_NAME}
      - DB_USER=\${DB_USER}
      - DB_PASSWORD=\${DB_PASSWORD}
    depends_on:
      - db
    networks:
      - innovacioncomercialx-net

  frontend-web:
    build: ./frontend-web
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - innovacioncomercialx-net

  frontend-mobile:
    build: ./frontend-mobile
    ports:
      - "19006:19006"
    depends_on:
      - backend
    networks:
      - innovacioncomercialx-net

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - db
    networks:
      - innovacioncomercialx-net

volumes:
  innovacioncomercialx_postgres_data:

networks:
  innovacioncomercialx-net:
DOCKER

echo "✅ docker-compose.yml creado con puertos actualizados."

# Limpiar contenedores antiguos
echo "🧹 Limpiando contenedores, redes y volúmenes antiguos..."
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
docker system prune -f >/dev/null 2>&1 || true

# Verificar si el puerto sigue ocupado y liberar
if netstat -ano 2>/dev/null | grep -q ":$BACKEND_PORT "; then
  echo "⚙️ Liberando puerto $BACKEND_PORT..."
  PID=$(netstat -ano | grep ":$BACKEND_PORT " | awk '{print $5}' | head -n 1)
  if [ -n "$PID" ]; then
    taskkill //PID $PID //F >/dev/null 2>&1 || true
  fi
fi

echo "🚀 Levantando servicios con Docker Compose..."
docker compose up --build -d

echo ""
echo "✅ Todos los contenedores se levantaron correctamente."
echo "🌐 Backend ejecutándose en el puerto: $BACKEND_PORT"
echo "📊 PgAdmin disponible en: http://localhost:5050"
echo "💻 Frontend Web en: http://localhost:3000"
echo "📱 Frontend Mobile en: http://localhost:19006"
