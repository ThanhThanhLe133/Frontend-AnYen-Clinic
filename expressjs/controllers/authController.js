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

export const forgotPassword = async (req, res) => {
  try {
    const { error } = joi.object({ phone_number, password }).validate(req.body)
    if (error)
      return badRequest(error.details[0]?.message, res)

    const response = await services.forgotPassword(req.body)

    return res.status(200).json(response)
  } catch (error) {
    console.log(error);
    return internalServerError(res)
  }
}

export const resetPassword = async (req, res) => {
  try {
    const userId = req.user?.id;

    if (!userId) return badRequest('Missing user id', res);
    const { oldPassword, newPassword } = req.body;
    const { error } = joi.object({
      newPassword: password
    }).validate({ newPassword });
    if (error)
      return badRequest(error.details[0]?.message, res)

    const response = await services.resetPassword({
      userId,
      oldPassword,
      newPassword
    });


    return res.status(200).json(response)
  } catch (error) {
    console.log(error);
    return internalServerError(res)
  }
}

export const logout = async (req, res) => {
  try {
    const userId = req.user?.id;

    if (!userId) return badRequest('Missing user id', res);

    const response = await services.logout({ userId });

    return res.status(200).json(response);
  } catch (error) {
    console.log(error);
    return internalServerError(res);
  }
};



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
