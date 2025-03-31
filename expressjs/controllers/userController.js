import { validationResult } from "express-validator";
import User from "../models/user.js";

// Update user profile
export const updateProfile = async (req, res, next) => {
  try {
    // Validate request data
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { email } = req.body;

    // Check if email already exists (if changing email)
    if (email && email !== req.user.email) {
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: "Email already in use",
        });
      }
    }

    // Update user
    await req.user.update({
      email: email || req.user.email,
    });

    // Return updated user
    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      user: {
        id: req.user.id,
        email: req.user.email,
        created_at: req.user.created_at,
        last_login: req.user.last_login,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Change password
export const changePassword = async (req, res, next) => {
  try {
    // Validate request data
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { currentPassword, newPassword } = req.body;

    // Validate current password
    const isPasswordValid = await req.user.isValidPassword(currentPassword);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Current password is incorrect",
      });
    }

    // Update password
    await req.user.update({
      password_hash: newPassword,
    });

    res.status(200).json({
      success: true,
      message: "Password changed successfully",
    });
  } catch (error) {
    next(error);
  }
};
