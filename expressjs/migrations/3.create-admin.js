'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Admins', {
            admin_id: {
                allowNull: false,
                type: Sequelize.UUID,
                primaryKey: true,
                references: {
                    model: 'Users',
                    key: 'id'
                },
                onDelete: 'CASCADE',
                onUpdate: 'CASCADE'

            },
            avatar_url: {
                type: Sequelize.TEXT,
                defaultValue: 'https://jqbpguplezywjemitmna.supabase.co/storage/v1/object/public/image-mobile-app//user.png'
            },
            name: {
                type: Sequelize.STRING,

            },
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('Admins');
    }
};
