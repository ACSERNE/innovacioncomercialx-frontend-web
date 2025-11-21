// backend/server.js
const express = require('express');
const cors = require('cors');
const compression = require('compression');
const dotenv = require('dotenv');
const { sequelize } = require('./models'); // Asegúrate de tener models/index.js
const userRoutes = require('./routes/user.routes'); // ejemplo de rutas

dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
app.use('/api/users', userRoutes);

// Conexión a DB y levantar servidor
const PORT = process.env.BACKEND_PORT || process.env.PORT || 5003;

sequelize.authenticate()
  .then(() => {
    console.log('✅ Conectado a la base de datos');
    app.listen(PORT, () => {
      console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ No se pudo conectar a la base de datos:', err);
  });
