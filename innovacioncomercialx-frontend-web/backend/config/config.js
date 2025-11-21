module.exports = {
  development: {
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'innovacion',
    host: process.env.DB_HOST || 'db',
    port: process.env.POSTGRES_PORT || 5432,
    dialect: 'postgres'
  }
};
