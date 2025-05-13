import 'package:flutter/material.dart';

void showSuccess(BuildContext rootContext, Widget? nextScreen, String label) {
  double screenWidth = MediaQuery.of(rootContext).size.width;
  double screenHeight = MediaQuery.of(rootContext).size.height;

  showDialog(
    context: rootContext,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
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
                "Thành công!",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (nextScreen != null) {
                    Navigator.pushReplacement(
                      rootContext,
                      MaterialPageRoute(builder: (context) => nextScreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF119CF0),
                  foregroundColor: Colors.white,
                  minimumSize: Size(screenWidth * 0.5, screenHeight * 0.08),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bo góc
                  ),
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter-Medium',
                  ),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      );
    },
  );
}
