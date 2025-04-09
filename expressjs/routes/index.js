import { router as verifyOtp } from "./verify_otp.js";
import { router as sendOtp } from "./send_otp.js";
import { router as authRoute } from "./authRoute.js";
import { router as userRoute } from "./userRoute.js";
import { router as patientProfile } from "./patient_profile.js";

const initRoutes = (app) => {
  app.use("/api/otp", verifyOtp);
  app.use("/api/otp", sendOtp);
  app.use("/api/auth", authRoute);
  app.use("/api/user", userRoute);
  app.use("/api/patient", patientProfile);
};

export default initRoutes;
