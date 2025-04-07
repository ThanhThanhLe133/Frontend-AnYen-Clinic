'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('Roles', {
            id: {
                allowNull: false,
                primaryKey: true,
                type: Sequelize.UUID,
                defaultValue: Sequelize.literal('gen_random_uuid()'),
            },
            value: {
                type: Sequelize.STRING,
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
        await queryInterface.dropTable('Roles');
    }
};