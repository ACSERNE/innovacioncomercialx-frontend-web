# Usar Node 20 Alpine como base
FROM node:20-alpine

# Instalar dependencias del sistema necesarias
RUN apk add --no-cache bash git python3 make g++

# Establecer directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Actualizar npm y limpiar cache
RUN npm install -g npm@11.6.1
RUN npm cache clean --force

# Instalar Expo CLI globalmente
RUN npm install -g expo-cli

# Instalar dependencias del proyecto
RUN npm install --legacy-peer-deps --retry=5 --fetch-timeout=60000

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto de la app
EXPOSE 19006

# Comando por defecto
CMD ["npm", "start"]
