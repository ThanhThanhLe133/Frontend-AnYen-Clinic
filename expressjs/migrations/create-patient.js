'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Patients', {
            patient_id: {
                allowNull: false,
                type: Sequelize.UUID,
                primaryKey: true,
            },
            fullname: {
                type: Sequelize.STRING,
                unique: true,
            },
            date_of_birth: {
                type: Sequelize.DATE,
            },
            gender: {
                type: Sequelize.ENUM('male', 'female', 'other'),
            },
            anonymous_name: {
                type: Sequelize.STRING,
                defaultValue: 'UserUnknown',
                allowNull: false,
            },
            medical_history: {
                type: Sequelize.TEXT,
            },
            allergies: {
                type: Sequelize.TEXT,
            },

        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('Patients');
    }
};
