import express from "express";
import * as controllers from "../controllers/verify_otp.js";
import verifyOtp from "../middlewares/verify_otp.js";

const router = express.Router();
router.use(verifyOtp);
router.post("/send-otp", controllers.sendOtp);
router.post("/verify-otp", controllers.verifyOtp);

export { router };
