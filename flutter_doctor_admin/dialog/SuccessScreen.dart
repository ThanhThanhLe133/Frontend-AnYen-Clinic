import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';

void showSuccessScreen(BuildContext context, Widget? nextScreen) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: screenWidth * 0.2,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                "Xác nhận thành công",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              normalButton(
                screenWidth: screenWidth * 0.8,
                screenHeight: screenHeight * 0.08,
                label: "Xác nhận",
                nextScreen: nextScreen,
              ),
            ],
          ),
        ),
      );
    },
  );
}
