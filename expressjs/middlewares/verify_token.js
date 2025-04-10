import jwt from 'jsonwebtoken';
import { notAuth } from '../middlewares/handle_errors.js';

const verifyToken = (req, res, next) => {
    // console.log('Headers:', req.headers);
    const token = req.headers.authorization;
    // console.log(token);
    if (!token) return notAuth('Require authorization!', res);
    const access_token = token.split(' ')[1];

    jwt.verify(access_token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            if (err.name === 'TokenExpiredError') {
                return notAuth('Access token expired', res, true);
            }
            return notAuth('Access token invalid', res, false);
        }
        req.user = user;
        next();
    });
};

export default verifyToken;
