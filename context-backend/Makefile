# 🛠️ Makefile cockpitizado para visor y backend federado

# Variables generales
VISOR_DIR=web-build
BACKEND_IMAGE=backend-cockpit
VISOR_IMAGE=visor-frontend
PORT=8081

# 🔧 Exportar visor
exportar:
	npx expo export --output-dir $(VISOR_DIR)

# 🔍 Validar visor
validar:
	./validar-visor.sh

# 🧹 Limpiar contexto
limpiar:
	./limpiar-contexto.sh

# 🏗️ Build backend
build-backend:
	docker build -t $(BACKEND_IMAGE) .

# 🏗️ Build visor
build-visor:
	docker build -t $(VISOR_IMAGE) .

# 🚀 Levantar visor local
up-visor:
	docker-compose up -d

# 🛑 Detener visor local
down-visor:
	docker-compose down

# 🌐 Abrir visor en navegador
abrir:
	xdg-open http://localhost:$(PORT)/index.html || start http://localhost:$(PORT)/index.html || open http://localhost:$(PORT)/index.html

# 🚀 Desplegar visor en producción
prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 🌎 Targets federados por país

# 🇨🇱 Chile
exportar-CL:
	npx expo export --output-dir $(VISOR_DIR)/CL

validar-CL:
	./validar-visor.sh CL

deploy-CL:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 🇲🇽 México
exportar-MX:
	npx expo export --output-dir $(VISOR_DIR)/MX

validar-MX:
	./validar-visor.sh MX

deploy-MX:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 🇪🇸 España
exportar-ES:
	npx expo export --output-dir $(VISOR_DIR)/ES

validar-ES:
	./validar-visor.sh ES

deploy-ES:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 🧠 Diagnóstico técnico
verificar:
	./verificar-contexto.sh

# 📋 Ayuda
help:
	@echo "Comandos disponibles:"
	@echo "  make exportar        → Exporta visor general"
	@echo "  make validar         → Valida visor general"
	@echo "  make limpiar         → Limpia contexto Docker"
	@echo "  make build-backend   → Build backend cockpitizado"
	@echo "  make build-visor     → Build visor cockpitizado"
	@echo "  make up-visor        → Levanta visor local"
	@echo "  make down-visor      → Detiene visor local"
	@echo "  make abrir           → Abre visor en navegador"
	@echo "  make prod            → Despliega visor en producción"
	@echo "  make exportar-CL     → Exporta visor para Chile"
	@echo "  make validar-MX      → Valida visor para México"
	@echo "  make deploy-ES       → Despliega visor para España"
	@echo "  make verificar       → Diagnóstico técnico del entorno"
