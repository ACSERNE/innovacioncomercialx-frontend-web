# 🚀 Innovación Comercial X

![License: MIT](https://img.shields.io/badge/License-MIT-green)
![Node.js](https://img.shields.io/badge/Node.js-20.x-green)
![React](https://img.shields.io/badge/React-18.x-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-blue)

**Innovación Comercial X** es una plataforma multiplataforma diseñada para **gestionar integralmente ventas, productos, flujo de caja, reportes y alertas**, además de contar con una **tienda online estilo Shopify**. La plataforma es flexible, escalable y fácil de usar, ayudando a optimizar procesos comerciales con herramientas inteligentes y seguras.

---

## 🌐 Tecnologías principales

- **Backend:** Node.js + Express
- **Base de datos:** PostgreSQL + Sequelize ORM
- **Autenticación:** JWT + 2FA
- **Frontend Web:** React.js
- **Frontend Móvil:** React Native (Expo)
- **Contenedores:** Docker + Docker Compose
- **Integraciones:** Zoho CRM, sistemas de pago
- **Reportes:** PDF y Excel, generación automática

---

## ✨ Características clave

<details>
<summary>Click para ver todas las características</summary>

- Gestión completa de **usuarios, productos y categorías**
- Control detallado del **flujo de caja y transacciones**
- Reportes automáticos **diarios, semanales y mensuales**
- Sistema de alertas para **vencimientos y bajo stock**
- **Tienda online** para exhibición y venta de productos
- **Autenticación robusta** con tokens y 2FA
- Análisis de ventas con **IA** y reportes inteligentes

</details>

---

## 🛠️ Instalación y ejecución

1. Clonar el repositorio:

```bash
git clone https://github.com/ACSERNE/innovacioncomercialx.git
cd innovacioncomercialx
```

2. Crear archivo `.env` en la raíz:

```
POSTGRES_USER=tu_usuario
POSTGRES_PASSWORD=tu_contraseña
POSTGRES_DB=nombre_base_datos
DB_HOST=db
DB_PORT=5432
```

3. Construir y levantar contenedores Docker:

```bash
docker-compose build
docker-compose up -d
```

4. Acceder a la aplicación:

- Backend: [http://localhost:5001](http://localhost:5001)
- Frontend Web: [http://localhost:3000](http://localhost:3000)
- Frontend Móvil (Expo): [http://localhost:19006](http://localhost:19006)

Para servir la web de producción local:

```bash
cd frontend-web
npm install -g serve
serve -s build
```

---

## 📂 Estructura del proyecto

```
innovacioncomercialx/
├─ backend/        # API Node.js + Express
├─ frontend-web/   # Aplicación React
├─ frontend-mobile/# Aplicación React Native (Expo)
├─ docker-compose.yml
├─ .env
└─ README.md
```

---

## 📞 Contacto

- GitHub: [ACSERNE](https://github.com/ACSERNE/innovacioncomercialx)
- Correo: innovacioncomercialx@gmail.com

---

## ⚖️ Licencia

MIT License
