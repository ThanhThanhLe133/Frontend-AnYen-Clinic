import 'package:flutter_riverpod/flutter_riverpod.dart';

// State chứa mã OTP nhập vào
class OTPNotifier extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  // Cập nhật mã OTP
  void updateOTP(String otp) {
    state = otp;
  }

  // Reset mã OTP
  void resetOTP() {
    state = "";
  }
}

// Provider để quản lý OTP state
final otpProvider = NotifierProvider<OTPNotifier, String>(() => OTPNotifier());
