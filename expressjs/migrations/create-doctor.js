'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {

        await queryInterface.createTable('Doctors', {
            doctor_id: {
                allowNull: false,
                type: Sequelize.UUID,
                primaryKey: true,
            },
            name: {
                type: Sequelize.STRING,
                allowNull: false,
            },
            avatar_url: {
                type: Sequelize.TEXT,
            },
            gender: {
                type: Sequelize.ENUM('male', 'female', 'other'),
            },
            specialization: {
                type: Sequelize.STRING,
            },
            workplace: {
                type: Sequelize.STRING,
            },
            specialization: {
                type: Sequelize.STRING,
            },
            year_experience: {
                type: Sequelize.INTEGER,
                defaultValue: 0,
            },
            work_experience: {
                type: Sequelize.STRING,
            },
            education_history: {
                type: Sequelize.STRING,
            },
            medical_license: {
                type: Sequelize.STRING,
            },
            price: {
                type: Sequelize.INTEGER,
                allowNull: false,
                defaultValue: 0,
            },
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('Doctors');
    }
};
