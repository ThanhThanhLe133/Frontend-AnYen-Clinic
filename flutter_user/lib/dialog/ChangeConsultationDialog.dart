import 'dart:convert';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showChangeConsultationDialog(
    BuildContext context, String appointmentId, bool isOnline) {
  double screenWidth = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EditConsultationDialog(
        appointment_id: appointmentId,
        isOnline: isOnline,
      );
    },
  );
}

class EditConsultationDialog extends StatefulWidget {
  final String appointment_id;
  final bool isOnline;
  const EditConsultationDialog({
    super.key,
    required this.appointment_id,
    required this.isOnline,
  });

  @override
  _EditConsultationDialogState createState() => _EditConsultationDialogState();
}

class _EditConsultationDialogState extends State<EditConsultationDialog> {
  late String selectedConsult;
  late bool isOnline;
  Future<void> editTimeAppointment() async {
    try {
      final response = await makeRequest(
          url: '$apiUrl/patient/edit-appointment',
          method: 'PATCH',
          body: {
            "appointment_id": widget.appointment_id,
            "appointment_type": selectedConsult,
          });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
            context, AppointmentScreen(), "Thay đổi thành công", "QUay lại");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi sửa lịch hẹn")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedConsult = widget.isOnline ? "Online" : "Trực tiếp";
    isOnline = widget.isOnline;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
      title: Center(
        child: Text(
          "Thay đổi hình thức tư vấn",
          style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.blue),
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child:
                      _buildOption(Icons.chat_rounded, "Online", isOnline, () {
                    setState(() {
                      isOnline = true;
                      selectedConsult = "Online";
                    });
                  }, screenWidth),
                ),
                SizedBox(
                  child: _buildOption(
                      Icons.people_alt_rounded, "Trực tiếp", !isOnline, () {
                    setState(() {
                      isOnline = false;
                      selectedConsult = "Offline";
                    });
                  }, screenWidth),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                    text: "BỎ QUA", isPrimary: false, screenWidth: screenWidth),
                CustomButton(
                  text: "CẬP NHẬT",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed: () {
                    print("Nút được nhấn!");
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

Widget _buildOption(IconData icon, String text, bool isSelected,
    VoidCallback onTap, double screenWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: screenWidth / 500,
          child: Radio(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
            activeColor: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Icon(
          icon,
          color: Colors.blue,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(text,
            maxLines: null,
            softWrap: true,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            )),
      ],
    ),
  );
}
