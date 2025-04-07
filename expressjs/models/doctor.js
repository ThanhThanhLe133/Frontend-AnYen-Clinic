'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class Doctor extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            // define association here
            Doctor.hasOne(models.User, { foreignKey: 'doctor_id', targetKey: 'id', as: 'doctorId' })
        }
    }
    Doctor.init({
        doctor_id: {
            allowNull: false,
            type: DataTypes.UUID,
            primaryKey: true,
        },

        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        specialization: {
            type: DataTypes.STRING,
        },
        workplace: {
            type: DataTypes.STRING,
        },
        specialization: {
            type: DataTypes.STRING,
        },
        year_experience: {
            type: DataTypes.INTEGER,
        },
        work_experience: {
            type: DataTypes.STRING,
        },
        education_history: {
            type: DataTypes.STRING,
        },
        medical_license: {
            type: DataTypes.STRING,
        },
        price: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        gender: {
            type: DataTypes.ENUM('male', 'female', 'other'),
        },
    }, {
        sequelize,
        modelName: 'Doctor',
        tableName: 'Doctors',
    });
    return Doctor;
};