import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:flutter/material.dart';

showPrescriptionDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PrescriptionDialog(appointment_id: appointmentId);
    },
  );
}

class PrescriptionDialog extends StatefulWidget {
  final String appointment_id;
  const PrescriptionDialog({super.key, required this.appointment_id});

  @override
  State<PrescriptionDialog> createState() => _PrescriptionDialogState();
}

class _PrescriptionDialogState extends State<PrescriptionDialog> {
  List<Map<String, dynamic>> prescriptions = [];
  Future<void> fetchPrescription() async {
    String appointmentId = widget.appointment_id;
    final response = await makeRequest(
      url: '$apiUrl/get/get-prescription/?appointment_id=$appointmentId',
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
        prescriptions = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPrescription();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: prescriptions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 30.0, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "Không có đơn thuốc",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Đơn thuốc",
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ...prescriptions.map(
                    (medicine) => _buildMedicineItem(medicine, screenWidth),
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMedicineItem(Map<String, dynamic> medicine, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "• ${medicine['name_amount']}",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "  ${medicine['dosage']}",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
