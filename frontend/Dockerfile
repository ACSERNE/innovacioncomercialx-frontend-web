# Etapa 1: build de React/Expo web
FROM node:20-alpine AS build

WORKDIR /app

# Copiamos package.json y package-lock.json
COPY package*.json ./

# Instalamos dependencias
RUN npm install

# Copiamos el resto del proyecto
COPY . .

# Generamos build web de React/Expo
RUN npm run build

# Etapa 2: servir build con Nginx
FROM nginx:alpine

# Copiamos el build al directorio de Nginx
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
