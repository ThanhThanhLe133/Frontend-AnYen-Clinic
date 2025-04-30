import 'package:flutter/material.dart';

class infoTitle extends StatelessWidget {
  const infoTitle({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.screenHeight,
    required this.screenWidth,
  });

  final String title;
  final String value;
  final IconData icon;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Color(0xFF40494F),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenWidth * 0.05, color: Colors.blue),
            SizedBox(width: screenWidth * 0.02),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
