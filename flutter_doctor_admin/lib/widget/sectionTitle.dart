import 'package:flutter/material.dart';

class sectionTitle extends StatelessWidget {
  const sectionTitle({
    super.key,

    required this.title,
    required this.screenHeight,
    required this.screenWidth,
  });

  final String title;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.02,
        bottom: screenHeight * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40494F),
            ),
          ),
        ],
      ),
    );
  }
}
