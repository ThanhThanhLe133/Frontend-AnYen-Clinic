import verifyOtp from "./verify_otp"
import auth from "./authRoute"

const initRoutes = (app) => {
    app.use('/api/otp', verifyOtp)
    app.use('/api/auth', auth)
}
