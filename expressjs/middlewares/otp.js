import supabase from "../config/supabaseClient.js";
import createError from "http-errors";

export const sendOtp = async (req, res, next) => {

    const { phone_number } = req.body;

    if (!phone_number) {
        return next(createError(400, "Số điện thoại là bắt buộc"));
    }

    try {
        const { data, error } = await supabase.auth.signInWithOtp({ phone: phone_number });

        if (error) {
            return next(createError(500, `Lỗi gửi OTP: ${error.message}`));
        }

        return res.status(200).json({
            success: true,
            message: "OTP đã được gửi thành công. Vui lòng kiểm tra tin nhắn của bạn.",
        });
    } catch (err) {
        next(createError(500, "Lỗi hệ thống khi xác thực OTP"));
    }
};

export const verifyOtp = async (req, res, next) => {
    const { phone_number, otp } = req.body;

    if (!phone_number || !otp) {
        return next(createError(400, "Số điện thoại và OTP là bắt buộc"));
    }

    try {
        const { data, error } = await supabase.auth.verifyOtp({
            phone: phone_number,
            token: otp,
            type: "sms",
        });

        if (error) {
            return res.status(401).send("OTP không hợp lệ hoặc đã hết hạn");
        }

        next();
    } catch (err) {

        next(createError(500, "Lỗi hệ thống khi xác thực OTP"));
    }
};

