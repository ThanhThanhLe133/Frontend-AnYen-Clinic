'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class Admin extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            Admin.belongsTo(models.User, {
                foreignKey: 'admin_id',
                targetKey: 'id',
                as: 'admin'
            });
        }
    }
    Admin.init({
        admin_id: {
            allowNull: false,
            type: DataTypes.UUID,
            primaryKey: true,
        },
        avatar_url: {
            type: DataTypes.STRING,
        },
        name: {
            type: DataTypes.STRING,
        },
    }, {
        sequelize,
        modelName: 'Admin',
        tableName: 'Admins',
        timestamps: false
    });
    return Admin;
};