import { phone, otp } from "../helpers/joi_schema.js";
import {
  internalServerError,
  badRequest,
} from "../middlewares/handle_errors.js";
import joi from "joi";
import * as services from '../services'

export const sendOtp = async (req, res) => {
  try {
    const { error } = joi.object({ phone: phone }).validate(req.body);
    if (error) return badRequest(error.details[0]?.message, res);

    const response = await services.sendOtp(req.body.phone);
    res.status(200).json({ message: "OTP đã được gửi!", data: response });
  } catch (err) {
    return internalServerError(res);
  }
};

export const verifyOtp = async (req, res, next) => {
  try {
    const phoneValidation = joi.object({ phone: phone }).validate(req.body);
    const otpValidation = joi.object({ otp: otp }).validate(req.body);

    if (phoneValidation.error) return next(phoneValidation.error);
    if (otpValidation.error) return next(otpValidation.error);

    const response = await services.verifyOtp(req.body.phone, req.body.otp);
    res.status(200).json({ message: "OTP hợp lệ!", data: response });
  } catch (err) {
    next(err);
  }
};
