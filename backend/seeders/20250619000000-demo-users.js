'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  async up(queryInterface, Sequelize) {
    const adminHash = bcrypt.hashSync('admin123', 10);
    const demoHash = bcrypt.hashSync('demo123', 10);

    await queryInterface.sequelize.query(`
      INSERT INTO "Users" (id, nombre, correo, password, role, "createdAt", "updatedAt")
      VALUES
        (gen_random_uuid(), 'Admin', 'admin@example.com', '${adminHash}', 'admin', NOW(), NOW()),
        (gen_random_uuid(), 'Usuario Demo', 'demo@example.com', '${demoHash}', 'user', NOW(), NOW())
      ON CONFLICT (correo) DO NOTHING;
    `);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Users', { correo: ['admin@example.com','demo@example.com'] }, {});
  }
};
