import joi from 'joi'

export const phone = joi.string()
    .pattern(/^[0-9]{10,12}$/)
    .required()
    .messages({
        "string.empty": "Số điện thoại không được để trống",
        "string.pattern.base": "Số điện thoại không hợp lệ",
        "any.required": "Số điện thoại là bắt buộc",
    });

export const otp = joi.string()
    .length(6)
    .pattern(/^[0-9]+$/)
    .required()
    .messages({
        "string.empty": "OTP không được để trống",
        "string.length": "OTP phải có đúng 6 chữ số",
        "string.pattern.base": "OTP chỉ được chứa số",
        "any.required": "OTP là bắt buộc",
    });
