'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('categorias_producto', [
      {
        id: queryInterface.sequelize.literal('gen_random_uuid()'),
        nombre: 'Alimentos',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        id: queryInterface.sequelize.literal('gen_random_uuid()'),
        nombre: 'Electrónica',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        id: queryInterface.sequelize.literal('gen_random_uuid()'),
        nombre: 'Ropa',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('categorias_producto', { nombre: ['Alimentos','Electrónica','Ropa'] }, {});
  }
};
