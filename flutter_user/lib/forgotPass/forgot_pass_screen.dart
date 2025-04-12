import 'dart:convert';

import 'package:anyen_clinic/OTP_verification/otp_verification_screen.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/inputPhoneNumber.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:anyen_clinic/widget/phoneCode_drop_down/country_code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ForgotPassScreen extends ConsumerStatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends ConsumerState<ForgotPassScreen> {
  final phoneController = TextEditingController();
  Future<void> sendOTP() async {
    final selectedCountryCode = ref.read(countryCodeProvider);
    String code = selectedCountryCode.replaceAll("+", "");
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập số điện thoại")),
      );
      return;
    } else if (phoneNumber.startsWith(code)) {
      //nếu đã nhập mã vùng -> thêm +
      phoneNumber = "+$phoneNumber";
    } else {
      //nếu chưa nhập mã vùng -> thêm mã vùng
      phoneNumber = "+$code$phoneNumber";
    }

    ref.read(phoneNumberProvider.notifier).state = phoneNumber;
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/otp/send-otp'),
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
            builder: (context) => OTPVerificationScreen(source: "forgot"),
          ),
        );
      } else {
        throw Exception(responseData["message"] ?? "Lỗi xác thực");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xác thực: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    final phoneController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Quên mật khẩu",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, vertical: screenHeight * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Nhập số điện thoại đã đăng ký:",
              style: TextStyle(
                  fontSize: screenWidth * 0.045, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.15),
            InputPhoneNumber(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              controller: phoneController,
            ),
            SizedBox(height: screenHeight * 0.05),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Gửi mã xác thực",
              action: sendOTP,
            )
          ],
        ),
      ),
    );
  }
}
