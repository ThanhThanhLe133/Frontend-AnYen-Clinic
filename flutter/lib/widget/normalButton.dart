import 'package:flutter/material.dart';

class normalButton extends StatelessWidget {
  const normalButton({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.label,
    this.nextScreen,
    this.action,
  });

  final double screenWidth;
  final double screenHeight;
  final String label;
  final Widget? nextScreen;
  final Function? action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        action?.call();
        if (nextScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen!),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF119CF0),
        foregroundColor: Colors.white,
        minimumSize: Size(screenWidth * 0.9, screenHeight * 0.08),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Bo góc
        ),
        textStyle: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter-Medium'),
      ),
      child: Text(label),
    );
  }
}
