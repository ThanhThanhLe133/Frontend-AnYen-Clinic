import joi from 'joi'

export const phone_number = joi.string()
    .pattern(/^\+[1-9]{1}[0-9]{1,3}[0-9]{7,10}$/)
    .required()
    .messages({
        "string.empty": "Số điện thoại không được để trống",
        "string.pattern.base": "Số điện thoại không hợp lệ, cần có mã vùng hợp lệ",
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
export const password = joi.string()
    .min(6)
    .required()
    .pattern(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*])/)
    .messages({
        'string.min': 'Password must be at least 6 characters long.',
        'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.',
        'any.required': 'Password is required.',
    });
export const dateOfBirth = joi.date().iso();

export const gender = joi.string().valid('male', 'female', 'other');

export const healthRecordSchema = joi.object({
    recordDate: joi.date().iso().required().messages({
        'any.required': 'recordDate is required',
        'date.base': 'recordDate must be a valid date in YYYY-MM-DD format'
    }),
    height: joi.number().min(0).required().messages({
        'any.required': 'height is required',
        'number.base': 'height must be a number',
        'number.min': 'height must be a positive number'
    }),
    weight: joi.number().min(0).required().messages({
        'any.required': 'weight is required',
        'number.base': 'weight must be a number',
        'number.min': 'weight must be a positive number'
    }),
});