import 'dart:convert';

import 'package:anyen_clinic/OTP_verification/otp_provider.dart';
import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/dialog/SuccessScreen.dart';
import 'package:anyen_clinic/patient_provider.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen(
      {super.key, required this.phone, required this.source});
  final String phone;
  final String source;
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  final int timeCount = 60;
  int countdown = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(otpFocusNodes[0]);
    });
    startCountdown();
  }

  void startCountdown() {
    setState(() {
      countdown = timeCount;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String phoneNumber = ref.watch(phoneNumberProvider);
    String password = ref.watch(passwordProvider);

    Future<void> callRegisterAPI() async {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phone_number": phoneNumber,
            "password": password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          showSuccessScreen(context, Dashboard());
        } else {
          throw Exception(responseData["message"] ?? "Lỗi đăng ký");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng ký: ${e.toString()}")),
        );

        Navigator.pop(context);
      }
    }

    Future<void> callLoginAPI() async {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phone_number": phoneNumber,
            "password": password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Nếu đăng nhập thành công, chuyển đến màn hình Dashboard
          showSuccessScreen(context, Dashboard());
        } else {
          // Nếu có lỗi, ném ngoại lệ và quay lại LoginScreen
          throw Exception(responseData["message"] ?? "Lỗi đăng nhập");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng nhập: ${e.toString()}")),
        );

        Navigator.pop(context);
      }
    }

    Future<void> verifyOTP() async {
      String otpCode = ref.read(otpProvider);
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/verify-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phone": widget.phone,
            "token": otpCode,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (widget.source == "register") {
            await callRegisterAPI();
          } else {
            await callLoginAPI();
          }
        } else {
          throw Exception(responseData["message"] ?? "Xác thực OTP thất bại");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi OTP: ${e.toString()}")),
        );
      }
    }

    Future<void> resendOtp() async {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/send-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": widget.phone}),
        );
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          startCountdown();
          ref.read(otpProvider.notifier).resetOTP();
          for (var controller in otpControllers) {
            controller.clear();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mã OTP đã được gửi lại!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${responseData['message']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi gửi lại OTP: ${e.toString()}")),
        );
      }
    }

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
          "Xác nhận số điện thoại",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, vertical: screenHeight * 0.1),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nhập mã 6 chữ số mà chúng tôi đã gửi cho bạn qua tin nhắn SMS:",
                style: TextStyle(
                    fontSize: screenWidth * 0.045, color: Color(0xFF40494F)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.01,
                        vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                      child: TextField(
                        controller: otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                        maxLength: 1,
                        focusNode: otpFocusNodes[index],
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          String otp = otpControllers.map((c) => c.text).join();
                          ref.read(otpProvider.notifier).updateOTP(otp);

                          if (value.isNotEmpty) {
                            if (index < 5) {
                              FocusScope.of(context)
                                  .requestFocus(otpFocusNodes[index + 1]);
                            } else {
                              FocusScope.of(context)
                                  .unfocus(); // Tự động bỏ focus nếu nhập xong 6 ký tự
                            }
                          } else {
                            if (index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(otpFocusNodes[index - 1]);
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: screenHeight * 0.15),
              Center(
                child: countdown > 0
                    ? RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF9BA5AC),
                          ),
                          children: [
                            TextSpan(text: "Gửi lại mã sau: "),
                            TextSpan(
                              text: "${countdown}s",
                              style: TextStyle(
                                color: Color(0xFF119CF0),
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: resendOtp,
                        child: Text(
                          "Gửi lại mã",
                          style: TextStyle(
                            color: Color(0xFF119CF0),
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.05),
              normalButton(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                label: "Xác nhận",
                action: verifyOTP,
              )
            ],
          ),
        ),
      ),
    );
  }
}
