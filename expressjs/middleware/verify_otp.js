import supabase from "../config/supabaseClient.js";
import createError from "http-errors";

const verifyOtp = async (req, res, next) => {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
        return next(createError(400, "Số điện thoại và OTP là bắt buộc"));
    }

    try {
        const { data, error } = await supabase.auth.verifyOtp({
            phone,
            token: otp,
            type: "sms",
        });

        if (error) {
            return next(createError(401, "OTP không hợp lệ hoặc đã hết hạn"));
        }

        req.user = data.user;
        next();
    } catch (err) {
        next(createError(500, "Lỗi hệ thống khi xác thực OTP"));
    }
};

export default verifyOtp;
