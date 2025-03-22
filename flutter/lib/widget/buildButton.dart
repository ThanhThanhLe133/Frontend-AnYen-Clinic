import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final double screenWidth;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.screenWidth,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: isPrimary ? null : const BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
        ),
      ),
    );
  }
}
