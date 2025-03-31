'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class Patient extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            // define association here
            //   User.belongsTo(models.Role, { foreignKey: 'role_code', targetKey: 'code', as: 'roleData' })
        }
    }
    Patient.init({
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
        date_of_birth: {
            type: DataTypes.DATE,
        },
        gender: {
            type: DataTypes.ENUM('male', 'female', 'other'),
        },
        anonymous_name: {
            type: DataTypes.STRING,
            unique: true,
        },
        medical_history: {
            type: DataTypes.TEXT,
        },
        allergies: {
            type: DataTypes.TEXT,
        },
    }, {
        sequelize,
        modelName: 'Patient',
    });
    return Patient;
};