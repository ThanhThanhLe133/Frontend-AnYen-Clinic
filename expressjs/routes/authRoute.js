import express from "express";
import * as authController from "../controllers/authController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Register route
router.post("/register", authController.register);

// Login route
router.post("/login", authController.login);

// Refresh token route
router.post("/refresh-token", authController.refreshAccessToken);

// Logout route
router.post("/logout", authController.logout);

// Get current user route
router.get("/me", authenticate, authController.me);
export { router };
