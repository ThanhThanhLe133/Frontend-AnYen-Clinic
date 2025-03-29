import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String hintText;

  const PasswordField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.hintText,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.screenWidth * 0.9,
      height: widget.screenHeight * 0.2,
      child: TextField(
        obscureText: obscurePassword,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: widget.screenWidth * 0.05,
            color: const Color(0xFF9AA5AC),
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF9AA5AC), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: togglePasswordVisibility,
          ),
        ),
        style: TextStyle(
          fontSize: widget.screenWidth * 0.045,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
