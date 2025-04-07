import { where } from 'sequelize';
import db from '../models'

export const getOne = (phone_number) =>
    new Promise(async (resolve, reject) => {
        try {
            const response = await db.User.findOne({
                where: { phone_number }
            });
            resolve({
                err: response ? 0 : 1,
                mes: response ? 'User found' : 'User not found',
                userData: response || null
            })
        } catch (error) {
            reject(error);
        }
    });
