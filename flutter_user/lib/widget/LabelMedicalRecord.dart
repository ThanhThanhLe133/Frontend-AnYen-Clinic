import 'package:flutter/material.dart';

class LabelMedicalRecord extends StatelessWidget {
  const LabelMedicalRecord({
    super.key,
    required this.screenWidth,
    required this.label,
  });

  final double screenWidth;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth * 0.16,
      child: Text(
        label,
        style:
            TextStyle(fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
