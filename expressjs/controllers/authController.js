import jwt from "jsonwebtoken";
import { validationResult } from "express-validator";
import {
  generateTokens,
  verifyRefreshToken,
  saveRefreshToken,
  revokeRefreshToken,
  blacklistAccessToken,
} from "../utils/tokenUtils.js";
import { AppError } from "../middlewares/errorMiddleware.js";

import * as services from '../services'
import { internalServerError, badRequest } from '../middlewares/handle_errors.js'
import { phone_number, password, refresh_token, otp } from '../helpers/joi_schema'
import joi from 'joi'

export const register = async (req, res) => {
  try {
    const { error } = joi.object({ phone_number, password }).validate(req.body)
    if (error)
      return badRequest(error.details[0]?.message, res)

    const response = await services.register(req.body)

    return res.status(200).json(response)
  } catch (error) {
    console.log(error);

    return internalServerError(res)
  }
}

export const login = async (req, res) => {
  try {
    const { error } = joi.object({ phone_number, password }).validate(req.body)
    if (error)
      return badRequest(error.details[0]?.message, res)
    const response = await services.login(req.body)

    return res.status(200).json(response)
  } catch (error) {
    console.log(error);
    return internalServerError(res)
  }
}
export const refreshTokenController = async (req, res) => {
  try {
    const { error } = joi.object({ refresh_token }).validate(req.body)

    if (error)
      return badRequest(error.details[0]?.message, res)

    const response = await services.refreshToken(req.body.refresh_token);

    return res.status(200).json(response)
  } catch (error) {
    console.error('Error in refreshTokenController: ', error);
    return internalServerError(res)
  }
}
// // Logout user
// export const logout = async (req, res, next) => {
//   try {
//     // Get refresh token from cookie
//     const refreshToken = req.cookies.refreshToken;

//     if (refreshToken) {
//       // Revoke refresh token
//       await revokeRefreshToken(refreshToken);
//     }

//     // If user is authenticated, blacklist access token
//     if (req.user && req.jti) {
//       const decoded = jwt.decode(req.headers.authorization.split(" ")[1]);
//       await blacklistAccessToken(req.jti, decoded.exp);
//     }

//     // Clear refresh token cookie
//     res.clearCookie("refreshToken");

//     res.status(200).json({
//       success: true,
//       message: "Logout successful",
//     });
//   } catch (error) {
//     next(error);
//   }
// };

// // Get current user profile
// export const me = async (req, res, next) => {
//   try {
//     // User is already set in req by auth middleware
//     res.status(200).json({
//       success: true,
//       user: {
//         id: req.user.id,
//         email: req.user.email,
//         created_at: req.user.created_at,
//         last_login: req.user.last_login,
//       },
//     });
//   } catch (error) {
//     next(error);
//   }
// };
