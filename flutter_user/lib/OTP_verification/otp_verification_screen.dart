import 'dart:convert';
import 'dart:io';

import 'package:anyen_clinic/forgotPass/forgot_pass_screen.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/provider/otp_provider.dart';
import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/register/register_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key, required this.source});
  final String source;
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  FocusNode otpFocusNode = FocusNode();
  final int timeCount = 60;
  int countdown = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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

  // @override
  // void dispose() {
  //   timer.cancel();
  //   for (var controller in otpControllers) {
  //     controller.dispose();
  //   }
  //   for (var focusNode in otpFocusNodes) {
  //     focusNode.dispose();
  //   }
  //   otpFocusNode.dispose();
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);

  //   super.dispose();
  // }

  void resetProvider() {
    ref.read(phoneNumberProvider.notifier).state = '';
    ref.read(passwordProvider.notifier).state = '';
    ref.read(otpProvider.notifier).resetOTP();
  }

  Future<void> callRegisterAPI(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth-patient/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
            context, LoginScreen(), "Xác nhận thành công", "Đăng nhập");
        resetProvider();
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

  Future<void> navigateToForgotPass() async {
    showSuccessDialog(
        context, ForgotPassScreen(), "Xác nhận thành công", "Tạo mật khẩu mới");
  }

  Future<void> setupFCM(String accessToken) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Lấy device token
    String? fcmToken = await messaging.getToken();
    print('FCM Token: $fcmToken');

    // Gửi token lên server
    if (fcmToken != null) {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/create-device-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_token': fcmToken,
          'device_type': Platform.isAndroid ? 'android' : 'ios'
        }),
      );

      if (response.statusCode == 200) {
        print('Device token saved successfully');
      } else {
        print('Failed to save device token: ${response.body}');
      }
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened from notification');
    });
  }

  Future<void> saveAfterLogin(Map<String, dynamic> responseData) async {
    await saveAccessToken(responseData['access_token']);
    await saveRefreshToken(responseData['refresh_token']);
    await saveLogin();
    await setupFCM(responseData['access_token']);
  }

  Future<void> callLoginAPI(String phoneNumber, String password) async {
    debugPrint('DDDDDDDDDD $phoneNumber');
    debugPrint('DDDDDDDDDD $password');
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
        }),
      );

      final responseData = jsonDecode(response.body);
      debugPrint("⚠️ Error message from API: $responseData");
      if (response.statusCode == 200) {
        await saveAfterLogin(responseData);

        List<String> roles = List<String>.from(responseData['roles']);
        if (roles.contains('patient')) {
          showSuccessDialog(
              context, Dashboard(), "Xác nhận thành công", "Tới trang chủ");
          resetProvider();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: RichText(
                text: TextSpan(
                  text: 'Chưa có tài khoản. ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Đăng ký',
                      style: TextStyle(
                        color: Color(0xFF119CF0),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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

  Future<void> verifyOTP(String phoneNumber, String password) async {
    String otpCode = ref.read(otpProvider) ?? "";

    debugPrint("⚠️ Error message from API: $otpCode");
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/otp/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "otp": otpCode,
        }),
      );
      final responseData = jsonDecode(response.body);

      debugPrint("⚠️ Error message from API: $responseData");
      if (response.statusCode == 200) {
        if (widget.source == "register") {
          await callRegisterAPI(phoneNumber, password);
        } else if (widget.source == "forgot") {
          await navigateToForgotPass();
        } else {
          await callLoginAPI(phoneNumber, password);
        }
      } else {
        throw Exception(responseData["message"] ?? "Xác nhận OTP thất bại");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi OTP: ${e.toString()}")),
      );
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String phoneNumber = ref.watch(phoneNumberProvider);
    String password = ref.watch(passwordProvider);

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
                            horizontal: screenWidth * 0.02),
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
                        onTap: () => resendOtp(phoneNumber),
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
                action: () => verifyOTP(phoneNumber, password),
              )
            ],
          ),
        ),
      ),
    );
  }
}
