import 'dart:convert';

import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/LabelMedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/MedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/infoWidget.dart';
import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart';
import 'package:flutter/material.dart';

void showPatientDetailScreen(BuildContext context, String patientId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PatientDetailScreen(patientId: patientId);
    },
  );
}

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Map<String, dynamic> patientProfile = {};
  Map<String, dynamic> healthRecords = {};

  Future<void> fetchProfile() async {
    String patientId = widget.patientId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-profile/?patientId=$patientId',
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
        patientProfile = data['data'];
      });
    }
  }

  Future<void> fetchHealthRecord() async {
    String patientId = widget.patientId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-health-records/?patientId=$patientId',
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
        healthRecords = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
      fetchHealthRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.02),
              height: screenHeight * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFD9D9D9), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Họ và tên",
                    info: patientProfile['full_name'] ?? 'Không có tên',
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Giới tính",
                    info: patientProfile['gender'] ?? 'Unknown',
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Ngày sinh",
                    info: formatDate(patientProfile['date_of_birth']),
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Tiền sử bệnh",
                    info: patientProfile['medical_history'] ?? '',
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Dị ứng",
                    info: "ssssssssssssssssssssssssssss",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  sectionTitle(
                    title: 'Chỉ số sức khoẻ',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.02),

              decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LabelMedicalRecord(
                    screenWidth: screenWidth,
                    label: "Ngày đo",
                  ),
                  LabelMedicalRecord(screenWidth: screenWidth, label: "Tuổi"),
                  LabelMedicalRecord(
                    screenWidth: screenWidth,
                    label: "Chiều cao \n (cm)",
                  ),
                  LabelMedicalRecord(
                    screenWidth: screenWidth,
                    label: "Cân nặng \n (kg)",
                  ),
                  LabelMedicalRecord(screenWidth: screenWidth, label: "BMI"),
                ],
              ),
            ),
            ListView.builder(
              itemCount: healthRecords.length,
              itemBuilder: (context, index) {
                final record = healthRecords[index];
                final double height = record['height']?.toDouble() ?? 0;
                final double weight = record['weight']?.toDouble() ?? 0;
                final String recordId = record['id'].toString();
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
