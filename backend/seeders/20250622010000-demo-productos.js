'use strict';
function calcularPrecioTotal(unitario, descuento_aplicable = false, descuento_porcentaje = 0) {
  if (!descuento_aplicable || descuento_porcentaje <= 0) return unitario;
  const descuento = unitario * (descuento_porcentaje / 100);
  return unitario - descuento;
}

module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkDelete('productos', null, {});

    const categorias = await queryInterface.sequelize.query(
      `SELECT id, nombre FROM categorias_producto`,
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    const categoriaMap = {};
    categorias.forEach(cat => { categoriaMap[cat.nombre] = cat.id; });

    const usuarios = await queryInterface.sequelize.query(
      `SELECT id FROM Users WHERE correo = 'demo@example.com'`,
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    const userId = usuarios[0]?.id;
    if (!userId) throw new Error('Usuario demo no encontrado para asignar como autor');

    const productos = [
      {
        id: '7285a0a3-555e-49c1-965f-f22043221406',
        nombre: 'Galletas Chocochip',
        descripcion: 'Caja de 12 unidades con chispas de chocolate',
        precio_unitario: 2500,
        descuento_aplicable: true,
        precio_total: calcularPrecioTotal(2500, true, 20),
        stock: 100,
        categoriaId: categoriaMap['Alimentos'],
        userId,
        fecha_vencimiento: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        id: 'd7f92e2f-1b58-4e7f-bf8c-123456789abc',
        nombre: 'Smartphone ZX Pro',
        descripcion: 'Pantalla OLED, 128GB, cámara dual',
        precio_unitario: 180000,
        descuento_aplicable: false,
        precio_total: calcularPrecioTotal(180000, false, 0),
        stock: 25,
        categoriaId: categoriaMap['Electrónica'],
        userId,
        fecha_vencimiento: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        id: 'a3f1c2b4-5d6e-789f-0123-456789abcdef',
        nombre: 'Camisa casual',
        descripcion: 'Camisa manga larga de algodón, talla M',
        precio_unitario: 12000,
        descuento_aplicable: true,
        precio_total: calcularPrecioTotal(12000, true, 10),
        stock: 60,
        categoriaId: categoriaMap['Ropa'],
        userId,
        fecha_vencimiento: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ];

    await queryInterface.bulkInsert('productos', productos);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('productos', {
      id: [
        '7285a0a3-555e-49c1-965f-f22043221406',
        'd7f92e2f-1b58-4e7f-bf8c-123456789abc',
        'a3f1c2b4-5d6e-789f-0123-456789abcdef'
      ],
    });
  },
};
