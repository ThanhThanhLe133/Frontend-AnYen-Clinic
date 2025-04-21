import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/patient/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/widget/PatientCardInList.dart';
import 'package:flutter/material.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Map<String, dynamic>> patients = [];
  Future<void> fetchProfile() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/get-all-patients',
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
        patients = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Danh sách bệnh nhân",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return GestureDetector(
            onTap: () {
              showPatientDetailScreen(context, patient['patient_id']!);
            },
            child: PatientCardInList(
              screenWidth: MediaQuery.of(context).size.width,
              screenHeight: MediaQuery.of(context).size.height,
              name: patient['full_name']!,
              gender: patient['gender']!,
              age:
                  (DateTime.now().year -
                          DateTime.parse(patient['date_of_birth']).year)
                      .toString(),
              imageUrl: patient['avatar_url']!,
              reviewCount: "0", // Truyền số lượt đánh giá
              visitCount: patient['appointment_count']!, // Truyền số lượt khám
            ),
          );
        },
      ),
    );
  }
}
