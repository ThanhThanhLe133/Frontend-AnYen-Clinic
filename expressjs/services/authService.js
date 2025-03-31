import express from "express";
import { body } from "express-validator";
import * as userController from "../controllers/userController.js";
import { authenticate } from "../middlewares/authMiddleware.js";
import e from "express";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Update profile route
router.put(
  "/profile",
  [
    body("email")
      .optional()
      .isEmail()
      .withMessage("Please provide a valid email"),
  ],
  userController.updateProfile
);

// Change password route
router.put(
  "/change-password",
  [
    body("currentPassword")
      .notEmpty()
      .withMessage("Current password is required"),
    body("newPassword")
      .isLength({ min: 8 })
      .withMessage("Password must be at least 8 characters long")
      .matches(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*])/)
      .withMessage(
        "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
      ),
  ],
  userController.changePassword
);

export { router };
