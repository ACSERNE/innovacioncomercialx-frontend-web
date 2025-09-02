# Dockerfile para frontend-mobile cockpitizado con exportación web

# Etapa de build con Node.js 18 compatible con Expo CLI
FROM node:18-alpine AS build

WORKDIR /app

# Copiar dependencias esenciales
COPY package.json ./
COPY package-lock.json ./
COPY app.json ./

# Instalar dependencias del proyecto
RUN npm install --legacy-peer-deps

# Copiar el resto del código fuente
COPY . .

# Exportar visor web con Expo usando CLI local
RUN npx expo export --output-dir web-build

# Etapa final con Nginx para servir el visor web
FROM nginx:alpine AS stage-1
COPY --from=build /app/web-build /usr/share/nginx/html
