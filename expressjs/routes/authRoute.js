import express from "express";
import * as controllers from "../controllers";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Register route
router.post("/register", controllers.register);

// Login route
router.post("/login", controllers.login);

// Refresh token route
router.post("/refresh-token", controllers.refreshTokenController);

// // Logout route
// router.post("/logout", controllers.logout);

// // Get current user route
// router.get("/me", authenticate, controllers.me);
export { router };
