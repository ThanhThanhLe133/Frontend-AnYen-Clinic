import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/widget/buildPasswordField.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/material.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({super.key});

  @override
  _ChangePassScreenState createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  final passController = TextEditingController();
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
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              PasswordField(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                hintText: "Nhập mật khẩu cũ",
                controller: passController,
              ),
              SizedBox(height: screenHeight * 0.05),
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
                controller: passController,
              ),
              SizedBox(height: screenHeight * 0.2),
              normalButton(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                label: "Đổi mật khẩu",
                nextScreen: LoginScreen(),
                action: null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
