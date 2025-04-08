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
            Patient.hasOne(models.User, { foreignKey: 'patient_id', targetKey: 'id', as: 'patientId' })
        }
    }
    Patient.init({
        patient_id: {
            allowNull: false,
            type: DataTypes.UUID,
            primaryKey: true,
        },
        fullname: {
            type: DataTypes.STRING,
            unique: true,
        },
        date_of_birth: {
            type: DataTypes.DATE,
        },
        gender: {
            type: DataTypes.ENUM('male', 'female', 'other'),
        },
        anonymous_name: {
            type: DataTypes.STRING,
            allowNull: false,
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
        tableName: 'Patients'
    });
    return Patient;
};