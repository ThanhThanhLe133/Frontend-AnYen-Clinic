const { Sequelize } = require('sequelize');
const sequelize = new Sequelize('postgres', 'postgres', '12345', {
    host: 'localhost',
    dialect: 'postgres',
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