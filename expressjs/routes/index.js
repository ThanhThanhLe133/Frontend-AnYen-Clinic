import verifyOtp from "./verify_otp"

const initRoutes = (app) => {

    app.use('/api/otp', verifyOtp)
}