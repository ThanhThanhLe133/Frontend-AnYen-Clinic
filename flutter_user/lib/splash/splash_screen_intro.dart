import 'dart:async';

import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/register/register_screen.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:anyen_clinic/widget/outlineButton.dart';
import 'package:flutter/material.dart';
// import 'package:an_yen_clinic/gen/assets.gen.dart';

class SplashScreenIntro extends StatefulWidget {
  const SplashScreenIntro({super.key});

  @override
  State<SplashScreenIntro> createState() => _SplashScreenIntroState();
}

class _SplashScreenIntroState extends State<SplashScreenIntro> {
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
              height: screenHeight * 0.4,
            ),
            //logo
            SizedBox(
              width: screenWidth * 0.5,
              height: screenHeight * 0.5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Text(
              'Hãy bắt đầu hành trình chữa lành cùng',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Color(0xFFDE8C88),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'An Yên',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF1CB6E5),
              ),
            ),
            SizedBox(height: screenHeight * 0.2),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Đăng nhập",
              nextScreen: LoginScreen(),
              action: null,
            ),
            SizedBox(height: screenHeight * 0.08),
            outlineButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Đăng ký",
              nextScreen: RegisterScreen(),
              action: null,
            ),
          ],
        ),
      ),
    );
  }
}
