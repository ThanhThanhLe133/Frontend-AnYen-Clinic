import { phone_number, otp } from "../helpers/joi_schema.js";
import {
  internalServerError,
  badRequest,
} from "../middlewares/handle_errors.js";
import joi from "joi";
import * as services from '../services'

export const sendOtp = async (req, res) => {
  try {
    const phoneValidation = joi.object({ phone_number: phone_number }).validate(req.body);
    if (phoneValidation.error) return next(phoneValidation.error);

    const response = await services.sendOtp(req.body.phone_number);
    res.status(200).json({ message: "OTP đã được gửi!", data: response });
  } catch (err) {
    console.log(123);

    return internalServerError(res);
  }
};

export const verifyOtp = async (req, res, next) => {
  try {
    const { error: phoneError } = joi.object({
      phone_number: phone_number,
      otp: otp,
    }).validate(req.body);

    if (phoneError) {
      return badRequest(phoneError.details[0].message, res);
    }

    const response = await services.verifyOtp(req.body.phone_number, req.body.otp);

    res.status(200).json({ message: "OTP hợp lệ!" });
  } catch (err) {
    next(err);
  }
};
