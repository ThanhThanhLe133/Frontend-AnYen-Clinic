import jwt, { TokenExpiredError } from 'jsonwebtoken'
import { notAuth } from '../middlewares/handle_errors.js'

const verifyToken = (req, res, next) => {
    const token = req.headers.authorization
    if (!token) return notAuth('Require authorization!', res)

    const access_token = token.split(' ')[1]

    jwt.verify(access_token, process.env.JWT_SECRET, (err, user) => {
        const isChecked = err instanceof TokenExpiredError
        if (err) {
            if (!isChecked) return notAuth('Access token invalid', res, isChecked)
            if (isChecked) return notAuth('Access token expired', res, isChecked)
        }
        req.user = user
        next()
    })
}
export default verifyToken