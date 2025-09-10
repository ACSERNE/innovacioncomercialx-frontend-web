#!/bin/bash

echo "🚀 Construyendo y ejecutando en PRODUCCIÓN en http://localhost"

docker build -t innovacioncomercialx-frontend-web .
docker run -d --rm \
  -p 80:80 \
  --name innovacioncomercialx-frontend-web \
  innovacioncomercialx-frontend-web
