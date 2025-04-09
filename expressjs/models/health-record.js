'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
    class Health_record extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate(models) {
            Health_record.belongsTo(models.Patient, {
                foreignKey: 'patient_id',
                targetKey: 'patient_id',
                as: 'patient'
            });
        }
    }
    Health_record.init({
        patient_id: {
            allowNull: false,
            type: DataTypes.UUID,
        },
        record_date: {
            allowNull: false,
            type: DataTypes.DATEONLY
        },
        height: {
            allowNull: false,
            type: DataTypes.FLOAT
        },
        weight: {
            allowNull: false,
            type: DataTypes.FLOAT
        }
    }, {
        sequelize,
        modelName: 'Health_record',
        tableName: 'Health_records',
    });
    return Health_record;
};