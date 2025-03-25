import 'package:anyen_clinic/register/register_screen.dart';
import 'package:anyen_clinic/widget/buildPasswordField.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              height: screenHeight * 0.1,
            ),
            Text(
              'Đăng nhập',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF119CF0),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.1,
              width: screenWidth * 0.8,
            ),
            // inputPhoneNumber(
            //     screenWidth: screenWidth, screenHeight: screenHeight),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            PasswordField(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              hintText: "Nhập mật khẩu",
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Quên mật khẩu',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter-Medium',
                      color: Color(0xFF119CF0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Đăng nhập",
              nextScreen: LoginScreen(), //tạm thời
              action: null,
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.01),
                  child: Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter-Medium',
                      color: Color(0xFF9AA5AC),
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Đăng ký',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Inter-Medium',
                      color: Color(0xFF119CF0),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Chuyển màn hình sang LoginScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
