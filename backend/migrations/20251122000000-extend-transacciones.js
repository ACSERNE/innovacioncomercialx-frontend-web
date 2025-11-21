'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('transacciones', 'descripcion', {
      type: Sequelize.STRING,
      allowNull: true
    });

    await queryInterface.addColumn('transacciones', 'observacion', {
      type: Sequelize.STRING,
      allowNull: true
    });

    await queryInterface.addColumn('transacciones', 'metodoPago', {
      type: Sequelize.ENUM('efectivo', 'tarjeta', 'transferencia'),
      allowNull: true
    });

    await queryInterface.addColumn('transacciones', 'productoId', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'productos',
        key: 'id'
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL'
    });

    await queryInterface.addColumn('transacciones', 'userId', {
      type: Sequelize.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id'
      },
      onUpdate: 'CASCADE',
      onDelete: 'CASCADE'
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('transacciones', 'descripcion');
    await queryInterface.removeColumn('transacciones', 'observacion');
    await queryInterface.removeColumn('transacciones', 'metodoPago');
    await queryInterface.removeColumn('transacciones', 'productoId');
    await queryInterface.removeColumn('transacciones', 'userId');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_transacciones_metodoPago";');
  }
};
