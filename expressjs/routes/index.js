import verifyOtp from "./verify_otp"
import authRoute from "./authRoute"
import userRoute from "./userRoute"

const initRoutes = (app) => {
    app.use('/api/otp', verifyOtp)
    app.use("/api/auth", authRoute);
    app.use("/api/user", userRoute);

}
