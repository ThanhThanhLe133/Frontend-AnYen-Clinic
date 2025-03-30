const express = require("express");
const { body } = require("express-validator");
const authController = require("../controllers/authController");
const { authenticate } = require("../middlewares/authMiddleware");
const { AppError } = require("../middlewares/errorMiddleware");

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

module.exports = router;
