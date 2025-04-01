'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Patients', {
            id: {
                allowNull: false,
                type: Sequelize.UUID,
                defaultValue: Sequelize.UUIDV4,
                primaryKey: true,
            },
            phone_number: {
                type: Sequelize.STRING,
                allowNull: false,
                unique: true,
            },
            password: {
                type: Sequelize.STRING,
                allowNull: false,
            },
            avatar_url: {
                type: Sequelize.TEXT,
            },
            refresh_token: {
                type: Sequelize.STRING,
            },
            date_of_birth: {
                type: Sequelize.DATE,
            },
            gender: {
                type: Sequelize.ENUM('male', 'female', 'other'),
            },
            anonymous_name: {
                type: Sequelize.STRING,
                unique: true,
            },
            medical_history: {
                type: Sequelize.TEXT,
            },
            allergies: {
                type: Sequelize.TEXT,
            },
            refresh_token: {
                type: Sequelize.STRING
            },
            createdAt: {
                allowNull: false,
                type: 'TIMESTAMP',
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            },
            updatedAt: {
                allowNull: false,
                type: 'TIMESTAMP',
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            }
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('Patients');
    }
};
