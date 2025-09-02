require('dotenv').config();
const express = require('express');
const cors = require('cors');
const compression = require('compression');
const { sequelize } = require('./models');

const app = express();

app.use(cors());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/products', require('./routes/product.routes'));

// Conectar a DB y levantar servidor
const PORT = process.env.PORT || 5001;
sequelize.sync({ alter: true }).then(() => {
  console.log('DB conectada');
  app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
});
