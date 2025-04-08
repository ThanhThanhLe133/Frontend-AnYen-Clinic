import express from "express";
import * as controllers from "../controllers";
import { checkRole } from "../middlewares/authMiddleware.js";
import verifyToken from '../middlewares/verify_token'

const router = express.Router();

// Register route
router.post("/register", controllers.register);


// Login route
router.post('/login', controllers.login);

router.post("/forgot-pass", controllers.forgotPassword);
// Refresh token route
router.post("/refresh-token", controllers.refreshTokenController);


router.post("/logout", verifyToken, controllers.logout);
// // Logout route
// router.post("/logout", controllers.logout);

export { router };
