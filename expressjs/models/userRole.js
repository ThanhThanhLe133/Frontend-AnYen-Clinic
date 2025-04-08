'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class UserRole extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            UserRole.belongsTo(models.User,
                { foreignKey: 'user_id', as: 'user' });
            UserRole.belongsTo(models.Role,
                { foreignKey: 'role_id', as: 'role' });
        }
    }
    UserRole.init({
        id: {
            type: DataTypes.UUID,
            defaultValue: sequelize.literal('gen_random_uuid()'),
            primaryKey: true
        },
        user_id: DataTypes.UUID,
        role_id: DataTypes.UUID

    }, {
        sequelize,
        modelName: 'UserRole',
        tableName: 'UserRoles'
    });
    return UserRole;
};