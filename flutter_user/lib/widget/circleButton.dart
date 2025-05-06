import 'package:flutter/material.dart';

class circleButton extends StatelessWidget {
  const circleButton({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.screenHeight,
    this.action,
    this.nextScreen,
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.02, vertical: screenWidth * 0.01),
      ),
      child: Text(label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.04,
          )),
    );
  }
}
