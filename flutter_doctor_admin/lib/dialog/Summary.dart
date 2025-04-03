import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showSummaryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SummaryDialog();
    },
  );
}

class SummaryDialog extends StatelessWidget {
  const SummaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Tổng kết",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            Center(
              child: Text(
                "bệnh nhân abccsjjjjjjjjjjjjjjjjjjjjjj",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(height: 1),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "ĐÓNG",
                  isPrimary: false,
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
