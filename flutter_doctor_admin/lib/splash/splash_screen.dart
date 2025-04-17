import 'dart:async';

import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/dashboard_admin/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.6,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            Text(
              'An Yên',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF1CB6E5),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              'Nơi cảm xúc được lắng nghe',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Color(0xFFDE8C88),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }
}
