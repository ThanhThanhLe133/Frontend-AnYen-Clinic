import 'package:flutter/material.dart';

Widget buildQuestionBubble(double screenWidth) {
  return Padding(
    padding: EdgeInsets.only(left: 64),
    child: Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'abcxyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz',
        style: TextStyle(fontSize: 13),
      ),
    ),
  );
}
