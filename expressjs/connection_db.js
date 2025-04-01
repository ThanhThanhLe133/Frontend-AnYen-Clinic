const { Sequelize } = require('sequelize');
const sequelize = new Sequelize('postgres', 'postgres.jqbpguplezywjemitmna', 'o8K4oXtUJrM9Msxh', {
    host: 'aws-0-ap-southeast-1.pooler.supabase.com',
    dialect: 'postgres',
    port: 6543,
    dialectOptions: {
        ssl: {
            require: true,
            rejectUnauthorized: false
        }
    },
    logging: false
});

(async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Kết nối thành công!');
    } catch (error) {
        console.error('❌ Lỗi kết nối:', error);
    }
})();