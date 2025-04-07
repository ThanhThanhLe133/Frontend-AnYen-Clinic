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
            // define association here
            User.belongsTo(models.Role, { foreignKey: 'role_id', targetKey: 'id', as: 'roleData' })
        }
    }
    User.init({
        id: {
            allowNull: false,
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        role_id: {
            allowNull: false,
            type: DataTypes.UUID,
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