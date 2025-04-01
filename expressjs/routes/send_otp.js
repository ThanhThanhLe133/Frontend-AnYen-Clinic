import express from "express";
import * as controllers from "../controllers/otp.js";
import { sendOtp } from "../middlewares/otp.js";

const router = express.Router();

router.use(sendOtp)
router.post("/send-otp", controllers.sendOtp);

export { router };
