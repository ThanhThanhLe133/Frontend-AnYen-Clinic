import express from "express";
import { body } from "express-validator";
import verifyToken from '../middleWares/verify_token'
import * as controllers from '../controllers'
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

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
  controllers.changePassword
);
router.use(verifyToken)
router.get('/', controllers.getCurrent)
export { router };
