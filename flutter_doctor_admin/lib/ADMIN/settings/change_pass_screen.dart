import 'dart:convert';

import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildPasswordField.dart';
import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({super.key});

  @override
  _ChangePassScreenState createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final retypePassController = TextEditingController();
  Future<void> createNewPass() async {
    String oldPassword = oldPassController.text.trim();
    if (oldPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập mật khẩu cũ")));
      return;
    }
    String newPassword = newPassController.text.trim();
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập mật khẩu mới")));
      return;
    }
    String retypePassword = retypePassController.text.trim();
    if (retypePassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập mật khẩu xác nhận")),
      );
      return;
    }
    if (newPassword != retypePassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mật khẩu xác nhận không khớp")));
      return;
    }
    final response = await makeRequest(
      url: '$apiUrl/auth/reset-pass',
      method: 'POST',
      body: {"oldPassword": oldPassword, "newPassword": newPassword},
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      showSuccessDialog(
        context,
        LoginScreen(),
        "Tạo mật khẩu mới thành công",
        "Đăng nhập",
      );
    } else {
      throw Exception(responseData["message"] ?? "Lỗi đổi mật khẩu");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

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
          "Đổi mật khẩu",
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
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              PasswordField(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                hintText: "Nhập mật khẩu cũ",
                controller: oldPassController,
              ),
              SizedBox(height: screenHeight * 0.05),
              PasswordField(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                hintText: "Nhập mật khẩu",
                controller: newPassController,
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
                label: "Đổi mật khẩu",
                nextScreen: LoginScreen(),
                action: () => createNewPass(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
