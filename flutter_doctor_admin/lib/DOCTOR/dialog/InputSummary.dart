import 'dart:convert';

import 'package:ayclinic_doctor_admin/DOCTOR/dialog/InputPrescription.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showInputSummaryDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return InputSummaryDialog(appointment_id: appointmentId);
    },
  );
}

class InputSummaryDialog extends StatefulWidget {
  const InputSummaryDialog({super.key, required this.appointment_id});
  final String appointment_id;

  @override
  State<InputSummaryDialog> createState() => _InputSummaryDialogState();
}

class _InputSummaryDialogState extends State<InputSummaryDialog> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController noteAdminController = TextEditingController();

  Future<void> completeAppointment() async {
    String description = descriptionController.text.trim();
    String noteForAdmin = noteAdminController.text.trim();
    try {
      final response = await makeRequest(
        url: '$apiUrl/doctor/confirm-appointment',
        method: 'PATCH',
        body: {
          "appointment_id": widget.appointment_id,
          "description": description,
          "note_for_admin": noteForAdmin,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cuộc hẹn đã được kết thúc")));
        showInputPrescriptionDialog(context, widget.appointment_id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi kết thúc lịch hẹn")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    noteAdminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Text(
                      "Nhập tổng kết",
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenWidth * 0.05),
              _buildLabel("Tổng kết"),
              SizedBox(height: screenWidth * 0.03),
              _buildTextField(50, 5, descriptionController),
              SizedBox(height: screenWidth * 0.03),

              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Ghi chú cho CSKH (nếu có)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              _buildTextField(20, 2, noteAdminController),
              SizedBox(height: screenWidth * 0.05),
              Center(
                child: CustomButton(
                  text: "Kết thúc tư vấn",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed:
                      () => showOptionDialog(
                        context,
                        "Xác nhận kết thúc",
                        "Bạn muốn xác nhận kết thúc ca tư vấn này?",
                        "HUỶ",
                        "ĐỒNG Ý",
                        () {
                          completeAppointment();
                        },
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàm tạo tiêu đề có dấu *
Widget _buildLabel(String text) {
  return Row(
    children: [
      Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ),
      Text(
        "*",
        style: TextStyle(fontSize: 16, color: Colors.red),
        textAlign: TextAlign.left,
      ),
    ],
  );
}

/// Hàm tạo ô nhập thông tin
Widget _buildTextField(
  double minHeight,
  int maxLines,
  TextEditingController controller,
) {
  return TextField(
    controller: controller,
    style: TextStyle(fontSize: 14),
    decoration: InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Color(0xFFF3EFEF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.blue, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      constraints: BoxConstraints(minHeight: minHeight),
    ),
    maxLines: maxLines,
  );
}
