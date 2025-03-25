import 'package:flutter/material.dart';

class outlineButton extends StatelessWidget {
  const outlineButton({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.label,
    required this.nextScreen,
    this.action,
  });

  final double screenWidth;
  final double screenHeight;
  final String label;
  final Widget nextScreen;
  final Function? action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        action?.call();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF119CF0),
        minimumSize: Size(screenWidth * 0.9, screenHeight * 0.08),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        side: BorderSide(color: Color(0xFF119CF0), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Bo góc
        ),
        textStyle: TextStyle(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter-Medium'),
      ),
      child: Text(label),
    );
  }
}
