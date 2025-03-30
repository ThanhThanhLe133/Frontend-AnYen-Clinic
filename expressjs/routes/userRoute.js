const express = require("express");
const { body } = require("express-validator");
const userController = require("../controllers/userController");
const { authenticate } = require("../middlewares/authMiddleware");

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

module.exports = router;
