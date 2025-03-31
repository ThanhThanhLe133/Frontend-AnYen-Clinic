import { validationResult } from "express-validator";
import * as services from '../services'
import { internalServerError, badRequest } from '../middlewares/handle_errors.js'

// Update user profile
export const updateProfile = async (req, res, next) => {

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
export const getCurrent = async (req, res) => {
  try {
    const { id } = req.user
    const response = await services.getOne(id)
    if (!id) return badRequest('User ID is missing!', res);

    return res.status(200).json(response)
  } catch (error) {
    return internalServerError(res)
  }
}
