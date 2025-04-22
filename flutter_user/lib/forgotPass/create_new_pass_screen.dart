import 'dart:convert';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildPasswordField.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CreateNewPassScreen extends ConsumerStatefulWidget {
  const CreateNewPassScreen({super.key});

  @override
  _CreateNewPassScreenState createState() => _CreateNewPassScreenState();
}

class _CreateNewPassScreenState extends ConsumerState<CreateNewPassScreen> {
  final passController = TextEditingController();
  final retypePassController = TextEditingController();
  Future<void> createNewPass(String phoneNumber) async {
    String password = passController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập mật khẩu")),
      );
      return;
    }
    String retypePassword = retypePassController.text.trim();
    if (retypePassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập mật khẩu xác nhận")),
      );
      return;
    }
    if (password != retypePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/forgot-pass'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"phone_number": phoneNumber, "password": password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
            context, LoginScreen(), "Tạo mật khẩu mới thành công", "Đăng nhập");
        ref.read(phoneNumberProvider.notifier).state = '';
        ref.read(passwordProvider.notifier).state = '';
      } else {
        throw Exception(responseData["message"] ?? "Lỗi tạo mật khẩu mới");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tạo mật khẩu mới: ${e.toString()}")),
      );
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
    passController.dispose();
    retypePassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    String phoneNumber = ref.watch(phoneNumberProvider);

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
          "Tạo mật khẩu mới",
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
              "Tạo mật khẩu mới để đăng nhập:",
              style: TextStyle(
                  fontSize: screenWidth * 0.045, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.1),
            PasswordField(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              hintText: "Nhập mật khẩu",
              controller: passController,
            ),
            SizedBox(height: screenHeight * 0.05),
            PasswordField(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              hintText: "Xác thực mật khẩu",
              controller: retypePassController,
            ),
            SizedBox(height: screenHeight * 0.2),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Tạo mật khẩu mới",
              nextScreen: LoginScreen(),
              action: () => createNewPass(phoneNumber),
            )
          ],
        ),
      ),
    );
  }
}
