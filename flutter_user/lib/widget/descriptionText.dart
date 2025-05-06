import 'package:flutter/material.dart';

Widget descriptionText(String text, double screenHeight, double screenWidth) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Text(text,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: screenWidth * 0.04, color: Color(0xFF40494F))),
    ),
  );
}
