import 'dart:convert';

import 'package:ayclinic_doctor_admin/OTP_verification/otp_verification_screen.dart';
import 'package:ayclinic_doctor_admin/forgotPass/forgot_pass_screen.dart';
import 'package:ayclinic_doctor_admin/Provider/UserProvider.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildPasswordField.dart';
import 'package:ayclinic_doctor_admin/widget/inputPhoneNumber.dart';
import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:ayclinic_doctor_admin/widget/phoneCode_drop_down/country_code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  Future<void> sendOTP() async {
    final selectedCountryCode = ref.read(countryCodeProvider);
    String code = selectedCountryCode.replaceAll("+", "");
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập số điện thoại")));
      return;
    } else if (phoneNumber.startsWith(code)) {
      //nếu đã nhập mã vùng -> thêm +
      phoneNumber = "+$phoneNumber";
    } else if (phoneNumber.startsWith("0")) {
      phoneNumber = "+$code${phoneNumber.substring(1)}";
    } else {
      //nếu chưa nhập mã vùng -> thêm mã vùng
      phoneNumber = "+$code$phoneNumber";
    }

    String password = passController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập password")));
      return;
    }
    ref.read(phoneNumberProvider.notifier).state = phoneNumber;
    ref.read(passwordProvider.notifier).state = password;
    try {
      // Bước 1: Kiểm tra đăng nhập
      final loginResponse = await http.post(
        Uri.parse('$apiUrl/auth/check-login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
        }),
      );

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode != 200) {
        debugPrint("⚠️ Error from check-login: ${loginData['mes']}");
        throw Exception(loginData['mes'] ?? "Lỗi đăng nhập");
      }

      // Bước 2: Gửi OTP nếu đăng nhập thành công
      final otpResponse = await http.post(
        Uri.parse('$apiUrl/otp/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
        }),
      );

      final otpData = jsonDecode(otpResponse.body);

      if (otpResponse.statusCode != 200) {
        debugPrint("⚠️ Error from send-otp: ${otpData['mes']}");
        throw Exception(otpData['mes'] ?? "Không thể gửi OTP");
      }

      // Thành công => điều hướng sang màn hình xác thực OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(source: "login"),
        ),
      );
    } catch (e) {
      debugPrint("❌ Exception caught: ${e.toString()}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi đăng nhập: ${e.toString()}")));
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.1),
            Text(
              'Đăng nhập',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF119CF0),
              ),
            ),
            SizedBox(height: screenHeight * 0.1, width: screenWidth * 0.8),
            InputPhoneNumber(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              controller: phoneController,
            ),
            SizedBox(height: screenHeight * 0.02),
            PasswordField(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              hintText: "Nhập mật khẩu",
              controller: passController,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPassScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Quên mật khẩu',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter-Medium',
                      color: Color(0xFF119CF0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Đăng nhập",
              action: () {
                sendOTP();
              },
            ),
          ],
        ),
      ),
    );
  }
}
