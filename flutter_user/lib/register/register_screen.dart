import 'dart:convert';

import 'package:anyen_clinic/OTP_verification/otp_verification_screen.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:anyen_clinic/widget/phoneCode_drop_down/country_code_provider.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/inputPhoneNumber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabase = Supabase.instance.client;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phoneNumber}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP đã được gửi đến $phoneNumber")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPVerificationScreen(phone: phoneNumber, source: "register"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${responseData['message']}")),
        );
      }
      // Chuyển đến màn hình nhập OTP
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    }
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
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.2,
              child: TextField(
                controller: passController,
                onChanged: (value) {
                  passController.text = value;
                  passController.selection = TextSelection.fromPosition(
                    TextPosition(offset: passController.text.length),
                  );
                },
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  hintText: "Nhập mật khẩu",
                  hintStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Color(0xFF9AA5AC),
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Color(0xFF9AA5AC), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
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
