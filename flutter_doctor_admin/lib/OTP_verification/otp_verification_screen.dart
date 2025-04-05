import 'dart:convert';

import 'package:ayclinic_doctor_admin/OTP_verification/otp_provider.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dashboard_doctor/dashboard.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessScreen.dart';
import 'package:ayclinic_doctor_admin/user.dart';
import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key, required this.source});
  final String source;
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  String apiUrl = dotenv.env['API_URL']!;

  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  FocusNode otpFocusNode = FocusNode();
  final int timeCount = 60;
  int countdown = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
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
    double screenHeight = MediaQuery.of(context).size.height;
    String phoneNumber = ref.watch(phoneNumberProvider);
    String password = ref.watch(passwordProvider);

    Future<void> callRegisterAPI() async {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/auth/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone_number": phoneNumber, "password": password}),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          showSuccessScreen(context, Dashboard());
        } else {
          throw Exception(responseData["message"] ?? "Lỗi đăng ký");
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi đăng ký: ${e.toString()}")));

        Navigator.pop(context);
      }
    }

    Future<void> callLoginAPI() async {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/auth/login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone_number": phoneNumber, "password": password}),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          showSuccessScreen(context, Dashboard());
        } else {
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
          Uri.parse('$apiUrl/otp/verify-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone_number": phoneNumber, "otp": otpCode}),
        );
        debugPrint("🔍 API Response: ${response.body}");
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
        debugPrint("🔍$e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi OTP: ${e.toString()}")));
      }
    }

    Future<void> resendOtp() async {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/otp/send-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone_number": phoneNumber}),
        );
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          startCountdown();
          ref.read(otpProvider.notifier).resetOTP();
          for (var controller in otpControllers) {
            controller.clear();
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Mã OTP đã được gửi lại!")));
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
          child: Container(color: Color(0xFF9BA5AC)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.1,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nhập mã 6 chữ số mà chúng tôi đã gửi cho bạn qua tin nhắn SMS:",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Color(0xFF40494F),
                ),
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
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        height: 1.0,
                      ),
                      maxLength: 1,
                      autofocus: index == 0,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.03,
                          horizontal: screenWidth * 0.02,
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        otpFocusNode.requestFocus();
                      },
                      onChanged: (value) {
                        String otp = otpControllers.map((c) => c.text).join();
                        ref.read(otpProvider.notifier).updateOTP(otp);

                        if (value.isNotEmpty) {
                          if (index < 5) {
                            otpFocusNodes[index + 1].requestFocus();
                          }
                        } else {
                          if (index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: screenHeight * 0.15),
              Center(
                child:
                    countdown > 0
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
