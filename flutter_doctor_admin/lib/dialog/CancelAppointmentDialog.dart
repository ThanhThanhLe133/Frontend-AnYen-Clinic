import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showCancelAppointmentDialog(BuildContext context, String appointmentId) {
  double screenWidth = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CancelAppointmentDialog(appointment_id: appointmentId);
    },
  );
}

class CancelAppointmentDialog extends StatefulWidget {
  final String appointment_id;
  const CancelAppointmentDialog({super.key, required this.appointment_id});

  @override
  _CancelAppointmentDialogState createState() =>
      _CancelAppointmentDialogState();
}

class _CancelAppointmentDialogState extends State<CancelAppointmentDialog> {
  final TextEditingController _cancelReasonController = TextEditingController();
  Future<void> cancelAppointment() async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/edit-appointment',
        method: 'PATCH',
        body: {
          "status": "Canceled",
          "cancel_reason": _cancelReasonController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AppointmentScreen(),
          "Thay đổi thành công",
          "QUay lại",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi sửa lịch hẹn")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.04,
      ),
      title: Center(
        child: Text(
          "Huỷ lịch hẹn",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
            SizedBox(height: screenWidth * 0.05),
            TextField(
              controller: _cancelReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Nhập lý do huỷ cuộc hẹn...",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ), // màu viền mặc định
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "BỎ QUA",
                  isPrimary: false,
                  screenWidth: screenWidth,
                ),
                CustomButton(
                  text: "CẬP NHẬT",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed: () {
                    cancelAppointment();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
