import * as controllers from '../controllers'
import express from 'express'
import verifyOtp from '../middlewares/verify_otp'

const router = express.Router()
router.use(verifyOtp)
router.post('/send-otp', controllers.sendOtp)
router.post('/verify-otp', controllers.verifyOtp)

module.exports = router