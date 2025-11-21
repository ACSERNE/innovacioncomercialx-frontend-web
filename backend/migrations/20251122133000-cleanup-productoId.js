'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('transacciones');

    // Si existe productoid, eliminar su constraint y la columna
    if (table.productoid) {
      try {
        await queryInterface.sequelize.query('ALTER TABLE transacciones DROP CONSTRAINT IF EXISTS transacciones_productId_fkey;');
      } catch (e) { /* ignore */ }
      await queryInterface.removeColumn('transacciones', 'productoid');
    }

    // Asegurar FK sobre productoId
    if (table.productoId) {
      const [results] = await queryInterface.sequelize.query(
        "SELECT conname FROM pg_constraint WHERE conrelid = 'transacciones'::regclass AND pg_get_constraintdef(oid) LIKE '%productoId%';"
      );
      if (!results || results.length === 0) {
        await queryInterface.sequelize.query(
          'ALTER TABLE transacciones ADD CONSTRAINT transacciones_productoId_fkey FOREIGN KEY (\"productoId\") REFERENCES productos(id) ON UPDATE CASCADE ON DELETE SET NULL;'
        );
      }
    }
  },

  async down(queryInterface, Sequelize) {
    // No revert automático por seguridad; podrías implementar si lo necesitas.
  }
};
