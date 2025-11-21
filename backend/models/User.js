// backend/models/User.js
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    nombre: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    correo: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM('admin', 'user'),
      defaultValue: 'user',
    },
  }, {
    tableName: 'users',
    timestamps: true,
  });

  // Asociaciones si necesitas
  User.associate = models => {
    // Por ejemplo: User.hasMany(models.Transaccion);
  };

  return User;
};
