import * as services from '../services'
import { phone, otp } from '../helpers/joi_schema';
import { internalServerError, badRequest } from '../middleWares/handle_error'
import joi from 'joi'

export const sendOtp = async (req, res) => {
    try {
        const { error } = joi.object({ phone: phone }).validate(req.body);
        if (error) return badRequest(error.details[0]?.message, res);

        const response = await sendOtp(req.body.phone);
        res.status(200).json({ message: "OTP đã được gửi!", data: response });
    } catch (err) {
        return internalServerError(res)
    }
};

export const verifyOtp = async (req, res, next) => {
    try {
        const phoneValidation = joi.object({ phone: phone }).validate(req.body);
        const otpValidation = joi.object({ otp: otp }).validate(req.body);

        if (phoneValidation.error) return next(phoneValidation.error);
        if (otpValidation.error) return next(otpValidation.error);

        const response = await verifyOtp(req.body.phone, req.body.otp);
        res.status(200).json({ message: "OTP hợp lệ!", data: response });
    } catch (err) {
        next(err);
    }
};
