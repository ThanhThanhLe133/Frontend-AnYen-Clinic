import 'package:flutter/material.dart';

void showSuccessDialog(
    BuildContext context, Widget? nextScreen, String text, String label) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  Future.delayed(Duration(seconds: 2), () {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Đóng dialog
      if (nextScreen != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      }
    }
  });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: screenWidth * 0.2, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                text,
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
                  if (nextScreen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => nextScreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF119CF0),
                  foregroundColor: Colors.white,
                  minimumSize: Size(screenWidth * 0.9, screenHeight * 0.08),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Bo góc
                  ),
                  textStyle: TextStyle(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter-Medium'),
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
