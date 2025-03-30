import Joi from 'joi';
const supabase = require('../config/supabaseClient');

export const sendOtp = async (phone) => {
    try {
        const { data, error } = await supabase.auth.signInWithOtp({ phone });
        if (error) throw new Error(error.message);
        return data;
    } catch (err) {
        console.error("Lỗi gửi OTP:", err.message);
        throw err;
    }
};

export const verifyOtp = async (phone, token) => {
    const { data, error } = await supabase.auth.verifyOtp({
        phone,
        token,
        type: 'sms',
    });
    if (error) throw new Error(error.message);
    return data;
}

