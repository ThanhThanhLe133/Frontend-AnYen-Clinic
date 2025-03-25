import 'package:flutter/material.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
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
            // inputPhoneNumber(
            //     screenWidth: screenWidth, screenHeight: screenHeight),
            SizedBox(height: screenHeight * 0.05),
            // normalButton(
            //   screenWidth: screenWidth,
            //   screenHeight: screenHeight,
            //   label: "Gửi mã xác thực",
            //   nextScreen: OTPVerificationScreen(), //tạm thời
            //   action: null,
            // )
          ],
        ),
      ),
    );
  }
}
