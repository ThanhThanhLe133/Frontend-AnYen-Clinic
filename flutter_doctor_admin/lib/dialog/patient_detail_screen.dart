import 'dart:convert';

import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/LabelMedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/MedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/infoWidget.dart';
import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  List<Map<String, dynamic>> healthRecords = [];

  Future<void> fetchProfile() async {
    String patientId = widget.patientId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-profile/?patientId=$patientId',
      method: 'GET',
    );

    if (response.statusCode != 200) {
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
    debugPrint("Fetch Profile - Status: ${response.statusCode}");
    debugPrint("Fetch Profile - Body: ${response.body}");

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);

      setState(() {
        healthRecords = List<Map<String, dynamic>>.from(data['data']);
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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: patientProfile.isEmpty
            ? Center(
                child: SpinKitWaveSpinner(color: Colors.blue, size: 75.0),
              )
            : Column(
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
                          info: patientProfile['fullname'] ?? 'Không có tên',
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
                          info: patientProfile['allergies'] ?? '',
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
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.9,
                          label: "Ngày đo",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.9,
                          label: "Tuổi",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.9,
                          label: "Chiều cao \n (cm)",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.9,
                          label: "Cân nặng \n (kg)",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.9,
                          label: "BMI",
                        ),
                      ],
                    ),
                  ),
                  healthRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 5),
                              Icon(
                                Icons.event_busy,
                                size: 20.0,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Chưa bản ghi ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          // Bọc ListView bằng Expanded
                          child: ListView.builder(
                            itemCount: healthRecords.length,
                            itemBuilder: (context, index) {
                              final record = healthRecords[index];
                              final double height =
                                  record['height']?.toDouble() ?? 0;
                              final double weight =
                                  record['weight']?.toDouble() ?? 0;
                              final String recordDate = record['record_date'];
                              return MedicalRecord(
                                screenWidth: screenWidth * 0.9,
                                screenHeight: screenHeight * 0.9,
                                dateRecord: formatDate(recordDate),
                                age: DateTime.now().year -
                                    DateTime.parse(
                                      patientProfile['date_of_birth'],
                                    ).year,
                                height: height,
                                weight: weight,
                              );
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
