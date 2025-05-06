import 'dart:convert';

import 'package:ayclinic_doctor_admin/DOCTOR/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showInputPrescriptionDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return InputPrescriptionDialog(appointment_id: appointmentId);
    },
  );
}

class InputPrescriptionDialog extends StatefulWidget {
  const InputPrescriptionDialog({super.key, required this.appointment_id});
  final String appointment_id;
  @override
  State<InputPrescriptionDialog> createState() =>
      _InputPrescriptionDialogState();
}

class _InputPrescriptionDialogState extends State<InputPrescriptionDialog> {
  List<Map<String, TextEditingController>> controllers = [
    {'name_amount': TextEditingController(), 'dosage': TextEditingController()},
  ];

  void _addTextField() {
    setState(() {
      controllers.add({
        'name_amount': TextEditingController(),
        'dosage': TextEditingController(),
      });
    });
  }

  Future<void> savePrescription() async {
    try {
      List<Map<String, String>> details =
          controllers.map((controllerMap) {
            return {
              "name_amount": controllerMap['name_amount']!.text,
              "dosage": controllerMap['dosage']!.text,
            };
          }).toList();
      final response = await makeRequest(
        url: '$apiUrl/doctor/create-prescription',
        method: 'POST',
        body: {"appointment_id": widget.appointment_id, "details": details},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AppointmentScreen(),
          "Lưu thành công",
          "Quay lại",
        );
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
    for (var controllerMap in controllers) {
      controllerMap['name_amount']?.dispose();
      controllerMap['dosage']?.dispose();
    }
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
                      "Nhập đơn thuốc",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tên, Số lượng",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Liều dùng",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              ...controllers.map(
                (controller) => _buildTextField(controller, screenWidth),
              ),
              SizedBox(height: screenWidth * 0.05),
              Divider(height: 1),
              SizedBox(height: screenWidth * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: "Thêm mới",
                    isPrimary: false,
                    screenWidth: screenWidth,
                    onPressed: _addTextField,
                  ),
                  CustomButton(
                    text: "Lưu",
                    isPrimary: true,
                    screenWidth: screenWidth,
                    onPressed: savePrescription,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàm tạo ô nhập thông tin
Widget _buildTextField(
  Map<String, TextEditingController> controllerMap,
  double screenWidth,
) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: screenWidth * 0.4,
          child: TextField(
            controller: controllerMap['name_amount'],
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
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenWidth * 0.2,
          child: TextField(
            controller: controllerMap['dosage'],
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
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
