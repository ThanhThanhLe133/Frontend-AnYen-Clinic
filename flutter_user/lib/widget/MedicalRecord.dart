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
    required this.bmi,
  });

  final double screenWidth;
  final double screenHeight;
  final String dateRecord;
  final int age;
  final double height;
  final double weight;
  final double bmi;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenWidth * 0.02),
      // constraints:
      //     BoxConstraints(minHeight: screenHeight * 0.15, maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              dateRecord.toString(),
              style: TextStyle(
                  fontSize: screenWidth * 0.03, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              age.toString(),
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              height.toString(),
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              weight.toString(),
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.16,
            child: Text(
              bmi.toString(),
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
