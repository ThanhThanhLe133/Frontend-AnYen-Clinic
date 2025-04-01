import supabase from "../config/supabaseClient";

export const sendOtp = async (phone_number) => {
  try {
    console.log(phone_number);

    const { data, error } = await supabase.auth.signInWithOtp({ phone: phone_number });
    if (error) throw new Error(error.message);
    return data;
  } catch (err) {
    console.error("Lỗi gửi OTP:", err.message);
    throw err;
  }
};

export const verifyOtp = async (phone_number, otp) => {
  const { data, error } = await supabase.auth.verifyOtp({
    phone: phone_number,
    token: otp,
    type: "sms",
  });

  if (error) throw new Error(error.message);
  return data;
};
