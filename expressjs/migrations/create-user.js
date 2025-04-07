'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Users', {
            id: {
                allowNull: false,
                type: Sequelize.UUID,
                defaultValue: Sequelize.literal('gen_random_uuid()'),
                primaryKey: true,
            },
            role_id: {
                allowNull: false,
                type: Sequelize.UUID,
            },
            phone_number: {
                type: Sequelize.STRING,
                allowNull: false,
                unique: true,
            },
            is_active: {
                type: Sequelize.BOOLEAN,
                allowNull: false,
                defaultValue: true,
            },
            password: {
                type: Sequelize.STRING,
                allowNull: false,
            },
            avatar_url: {
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
        await queryInterface.dropTable('Users');
    }
};
