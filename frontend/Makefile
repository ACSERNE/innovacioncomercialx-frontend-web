# Makefile cockpitizado multiplataforma

DEV_PATH := $(shell pwd | sed 's|/c/|C:/|')

build-dev:
	docker build -t frontend-web-dev -f Dockerfile.dev .

build-prod:
	docker build -t frontend-web-prod -f Dockerfile.prod .

	@DEV_PATH=$(shell pwd | sed 's|/c/|C:/|'); \
	PORT=3000; \
	while netstat -aon | grep ":2815PORT" > /dev/null; do \
		PORT=`expr 2815PORT + 1`; \
	done; \
	echo "🔧 Desarrollo activo en http://localhost:2815PORT"; \
	docker run -d -p 2815PORT:3000 \
		-v "2815DEV_PATH:/app" \
		-w "/app" \
		frontend-web-dev \
		sh -c "npm install && npm run dev -- --host 0.0.0.0 --port 2815PORT"

run-prod:
	@PORT=3000; \
	while netstat -aon | grep ":2815PORT" > /dev/null; do \
		PORT=`expr 2815PORT + 1`; \
	done; \
	echo "🚀 Producción activa en http://localhost:2815PORT"; \
	docker run -d -p 2815PORT:80 frontend-web-prod

logs-dev:
	@docker logs -f $(shell docker ps -q --filter ancestor=frontend-web-dev)

logs-prod:
	@docker logs -f $(shell docker ps -q --filter ancestor=frontend-web-prod)

clean:
	-docker ps -aq | xargs -r docker stop
	-docker ps -aq | xargs -r docker rm
	-docker images -q | xargs -r docker rmi -f
	@echo "🧼 Entorno completamente limpiado"

validate:
	@echo "🔍 Contenedores activos:"
	@docker ps
	@echo "🌐 Puertos en uso:"
	@netstat -aon | grep ":3000" || echo "Puerto 3000 libre"
	@netstat -aon | grep ":5173" || echo "Puerto 5173 libre"

optimize:
	@echo "🧼 Optimización de contexto de build"
	@echo "→ Validando .dockerignore"
	@cat .dockerignore
	@echo "→ Tamaño del contexto actual:"
	@du -sh . | cut -f1

audit:
	@echo "🔍 Auditoría de dependencias"
	@docker run --rm -v "$(shell pwd):/app" -w /app node:20-alpine sh -c "npm audit || true"

export:
	@echo "📦 Exportación técnica cockpitizada"
	@mkdir -p export
	@cp Dockerfile.dev Dockerfile.prod Makefile .dockerignore export/
	@echo "→ Artefactos exportados a ./export"

federate:
	@echo "🌐 Federando artefactos por país y entorno"
	@mkdir -p federado/cl
	@cp Dockerfile.dev Dockerfile.prod Makefile .dockerignore federado/cl/
	@echo "→ Artefactos federados en ./federado/cl"

badge:
	@echo "🏷️ Generando badge SVG cockpitizado"
	@mkdir -p badges
	@echo '<svg xmlns="http://www.w3.org/2000/svg" width="150" height="20"><rect width="150" height="20" fill="#222"/><text x="75" y="14" fill="#fff" font-size="12" text-anchor="middle">ComercialX Cockpit</text></svg>' > badges/comercialx.svg
	@echo "→ Badge generado en ./badges/comercialx.svg"

deploy:
	@echo "🚀 Despliegue automatizado en entorno federado"
	@docker run --rm -v "$(shell pwd):/app" -w /app node:20-alpine sh -c "npm run build"
	@echo "→ Build completado"
	@docker build -t comercialx-prod -f Dockerfile.prod .
	@PORT=8080; \
	while netstat -aon | grep ":2815PORT" > /dev/null; do \
		PORT=`expr 2815PORT + 1`; \
	done; \
	docker run -d -p 2815PORT:80 comercialx-prod; \
	echo "✅ Desplegado en http://localhost:2815PORT"

	@DEV_PATH=$(shell pwd | sed 's|/c/|C:/|'); \
	PORT=3000; \
	while netstat -aon | grep ":$3000" > /dev/null; do \
		PORT=`expr $$PORT + 1`; \
	done; \
	echo "🔧 Desarrollo activo en http://localhost:$3000"; \
	docker run -d -p $3000:3000 \
		-v "$C:/Users/usuario/innovacioncomercialx/innovacioncomercialx-frontend-web:/app" \
		-w "/app" \
		frontend-web-dev \
		sh -c "npm install && npm run dev -- --host 0.0.0.0 --port $3000"



run-dev:
	@DEV_PATH=$(shell pwd | sed 's|^/c/|C:/|'); \
	PORT=3000; \
	while netstat -aon | grep ":$3000" > /dev/null; do \
		PORT=`expr $$PORT + 1`; \
	done; \
	echo "🔧 Desarrollo activo en http://localhost:$3000"; \
	docker run -d -p $3000:3000 \
		-v "$C:/Users/usuario/innovacioncomercialx/innovacioncomercialx-frontend-web/frontend-web:/app" \
		-w "/app" \
		frontend-web-dev \
		sh -c "npm install && npm run dev -- --host 0.0.0.0 --port $3000"

run-dev:
	@DEV_PATH=$(shell cygpath -w "$(PWD)"); \
	PORT=3000; \
	while netstat -aon | grep ":$3000" > /dev/null; do \
		PORT=`expr $$PORT + 1`; \
	done; \
	echo "🔧 Desarrollo activo en http://localhost:$3000"; \
	docker run -d -p $3000:3000 \
		-v "$C:/Users/usuario/innovacioncomercialx/innovacioncomercialx-frontend-web/frontend-web:/app" \
		-w "/app" \
		frontend-web-dev \
		sh -c "npm install && npm run dev -- --host 0.0.0.0 --port $3000"

run-dev:
	@DEV_PATH=\$$(pwd -W); \
	PORT=3000; \
	while netstat -aon | grep ":$${PORT}" > /dev/null; do \
		PORT=`expr $$PORT + 1`; \
	done; \
	CONTAINER_NAME=frontend-web-dev-container; \
	if [ "$$(docker ps -aq -f name=$$CONTAINER_NAME)" ]; then \
		echo "🛑 Deteniendo contenedor previo $$CONTAINER_NAME..."; \
		docker stop $$CONTAINER_NAME >/dev/null 2>&1 || true; \
		docker rm $$CONTAINER_NAME >/dev/null 2>&1 || true; \
	fi; \
	echo "🔧 Desarrollo activo en http://localhost:$$PORT"; \
	docker run -d -p $$PORT:3000 \
		-v "$$DEV_PATH:/app" \
		--name $$CONTAINER_NAME \
		frontend-web-dev \
		sh -c "cd /app && npm install && npm run dev -- --host 0.0.0.0 --port $$PORT"
