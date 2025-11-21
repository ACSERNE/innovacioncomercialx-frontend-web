// backend/models/index.js
const fs = require('fs');
const path = require('path');
const { Sequelize, DataTypes } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

const basename = path.basename(__filename);
const db = {};

// Configuración de la conexión
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: 'localhost',           // Puedes poner otra IP si tu DB no está local
    port: process.env.POSTGRES_PORT || 5432,
    dialect: 'postgres',
    logging: false,
  }
);

// Cargar todos los modelos automáticamente
fs.readdirSync(__dirname)
  .filter(file => {
    return (
      file.indexOf('.') !== 0 &&
      file !== basename &&
      file.slice(-3) === '.js'
    );
  })
  .forEach(file => {
    const model = require(path.join(__dirname, file))(sequelize, DataTypes);
    db[model.name] = model;
  });

// Configurar asociaciones si existen
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

// Exportar sequelize y los modelos
db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
