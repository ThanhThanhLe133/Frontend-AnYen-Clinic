import 'package:flutter/material.dart';

class MedicalRecord extends StatelessWidget {
  const MedicalRecord({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.dateRecord,
    required this.age,
    required this.height,
    required this.weight,
  });

  final double screenWidth;
  final double screenHeight;
  final String dateRecord;
  final int age;
  final double height;
  final double weight;

  @override
  Widget build(BuildContext context) {
    double bmi = 0;
    if (height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }
    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(screenWidth * 0.05),
      constraints:
          BoxConstraints(minHeight: screenHeight * 0.15, maxHeight: 500),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.17,
            child: Text(
              dateRecord.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Color(0xFF40494F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              age.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Color(0xFF40494F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              height.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Color(0xFF40494F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              weight.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Color(0xFF40494F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              bmi.toStringAsFixed(2),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Color(0xFF40494F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
