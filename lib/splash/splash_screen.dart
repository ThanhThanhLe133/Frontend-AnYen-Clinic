import 'package:flutter/material.dart';
// import 'package:an_yen_clinic/gen/assets.gen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
              height: screenHeight * 0.5,
            ),
            //logo
            SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.6,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
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

            // Slogan
            Text(
              'Nơi cảm xúc được lắng nghe',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Color(0xFFDE8C88),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
