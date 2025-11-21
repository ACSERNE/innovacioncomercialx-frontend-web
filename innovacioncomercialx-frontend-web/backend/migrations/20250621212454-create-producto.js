'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('productos', {
      id: {
        type: Sequelize.UUID,
        allowNull: false,
        primaryKey: true,
        defaultValue: Sequelize.literal('gen_random_uuid()')
      },
      nombre: { type: Sequelize.STRING, allowNull: false },
      precio_unitario: { type: Sequelize.FLOAT, allowNull: false },
      precio_total: { type: Sequelize.FLOAT, allowNull: false },
      descuento_aplicable: { type: Sequelize.BOOLEAN, defaultValue: false },
      stock: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 0 },
      categoriaId: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'categorias_producto', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      userId: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'Users', key: 'id' },
        onUpdate: 'SET NULL',
        onDelete: 'SET NULL'
      },
      fecha_vencimiento: { type: Sequelize.DATE, allowNull: true },
      createdAt: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('productos');
  }
};
