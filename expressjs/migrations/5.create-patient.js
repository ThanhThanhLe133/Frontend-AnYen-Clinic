'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Patients', {
            patient_id: {
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
            avatar_url: {
                type: Sequelize.TEXT,
                defaultValue: 'https://jqbpguplezywjemitmna.supabase.co/storage/v1/object/public/image-mobile-app//user.png'
            },
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('Patients');
    }
};
