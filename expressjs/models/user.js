'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class User extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            User.belongsToMany(models.Role, {
                through: models.UserRole,
                foreignKey: 'user_id',
                otherKey: 'role_id',
                as: 'roles'
            });

        }
    }
    User.init({
        id: {
            allowNull: false,
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        phone_number: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        is_active: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        avatar_url: {
            type: DataTypes.STRING,
        },
        refresh_token: {
            type: DataTypes.STRING,
        },

    }, {
        sequelize,
        modelName: 'User',
        tableName: 'Users'
    });
    return User;
};