# Dockerfile para frontend-mobile con resolución quirúrgica de dependencias

FROM node:20-alpine AS build

WORKDIR /app
COPY package*.json ./

# Script embebido para resolver conflictos de dependencias
RUN echo '#!/bin/sh' > resolver-dependencias.sh && \
    echo 'echo "🔍 Resolviendo react-native-web inválido..."' >> resolver-dependencias.sh && \
    echo 'version=$(npm view react-native-web versions | grep "^0\\.19\\." | tail -1)' >> resolver-dependencias.sh && \
    echo '[ -n "$version" ] && sed -i "s/react-native-web@0.19.16/react-native-web@$version/" package.json' >> resolver-dependencias.sh && \
    echo 'npm install --legacy-peer-deps' >> resolver-dependencias.sh && \
    chmod +x resolver-dependencias.sh && \
    ./resolver-dependencias.sh

COPY . .
RUN npx expo export --output-dir web-build

FROM nginx:alpine AS stage-1
COPY --from=build /app/web-build /usr/share/nginx/html
