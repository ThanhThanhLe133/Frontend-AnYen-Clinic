import 'dart:convert';

import 'package:anyen_clinic/OTP_verification/otp_verification_screen.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/widget/buildPasswordField.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:anyen_clinic/widget/phoneCode_drop_down/country_code_provider.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widget/inputPhoneNumber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String apiUrl = dotenv.env['API_URL'] ?? 'https://default-api.com';
  bool obscurePassword = true;
  bool isChecked = false;
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  Future<void> sendOTP() async {
    final selectedCountryCode = ref.read(countryCodeProvider);

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn phải đồng ý với điều khoản")),
      );
      return;
    }

    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập số điện thoại")),
      );
      return;
    } else if (!phoneNumber.startsWith(selectedCountryCode)) {
      phoneNumber = "$selectedCountryCode$phoneNumber";
    }

    String password = passController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập password")),
      );
      return;
    }
    ref.read(phoneNumberProvider.notifier).state = phoneNumber;
    ref.read(passwordProvider.notifier).state = password;
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/otp/send-otp'),
        //thay = địa chỉ ipv4 ở đây nếu run = điện thoại
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(source: "register"),
          ),
        );
      } else {
        throw Exception(responseData["message"] ?? "Lỗi đăng ký");
      }
    } catch (e) {
      debugPrint("🔍$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng ký: ${e.toString()}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Chỉ cho phép màn hình dọc khi vào màn hình này
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Khôi phục cài đặt gốc khi thoát màn hình này
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
            SizedBox(
              height: screenHeight * 0.1,
            ),
            Text(
              'Đăng ký',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF119CF0),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.1,
              width: screenWidth * 0.8,
            ),
            InputPhoneNumber(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              controller: phoneController,
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            PasswordField(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              hintText: "Nhập mật khẩu",
              controller: passController,
            ),
            SizedBox(
              width: screenWidth * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                    side: BorderSide(color: Color(0xFF40494F), width: 1),
                    activeColor: Colors.blue,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontFamily: 'Inter-Medium',
                          color: Color(0xFF40494F),
                        ),
                        children: [
                          TextSpan(text: 'Tôi đã đọc và đồng ý với các '),
                          TextSpan(
                            text: 'điều khoản',
                            style: TextStyle(color: Color(0xFF119CF0)),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          TextSpan(text: ' và '),
                          TextSpan(
                            text: 'chính sách bảo mật',
                            style: TextStyle(color: Color(0xFF119CF0)),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Đăng ký",
              action: sendOTP,
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter-Medium',
                      color: Color(0xFF9AA5AC),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Đăng nhập',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Inter-Medium',
                        color: Color(0xFF119CF0),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Chuyển màn hình sang LoginScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
