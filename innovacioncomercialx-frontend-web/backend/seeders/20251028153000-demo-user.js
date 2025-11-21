// backend/seeders/20251028153000-demo-user.js
'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  up: async (queryInterface) => {
    const passwordHash = await bcrypt.hash('admin123', 10);
    await queryInterface.bulkInsert('users', [
      {
        nombre: 'Admin',
        correo: 'admin@admin.com',
        password: passwordHash,
        role: 'admin',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]);
  },

  down: async (queryInterface) => {
    await queryInterface.bulkDelete('users', { correo: 'admin@admin.com' });
  },
};
