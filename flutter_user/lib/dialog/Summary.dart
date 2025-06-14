import 'dart:convert';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showSummaryDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SummaryDialog(appointment_id: appointmentId);
    },
  );
}

class SummaryDialog extends StatefulWidget {
  final String appointment_id;
  const SummaryDialog({super.key, required this.appointment_id});

  @override
  State<SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<SummaryDialog> {
  Map<String, dynamic> summary = {};
  Future<void> fetchSummary() async {
    String appointmentId = widget.appointment_id;
    final response = await makeRequest(
      url: '$apiUrl/patient/get-appointment/?appointment_id=$appointmentId',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        summary = data['appointment'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

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
                summary['description'],
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
