import express from "express";
import * as controllers from "../controllers/otp.js";
import { verifyOtp } from "../middlewares/otp.js";

const router = express.Router();

router.post("/verify-otp", verifyOtp, controllers.verifyOtp);

export { router };
