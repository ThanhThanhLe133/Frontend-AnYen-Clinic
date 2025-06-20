import 'dart:convert';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/SuccessScreen.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/settings/account_screen.dart';
import 'package:anyen_clinic/settings/medical_records_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/dateTimePicker.dart';
import 'package:anyen_clinic/widget/genderDropDown.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key});

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenSate();
}

class _EditAccountScreenSate extends ConsumerState<EditAccountScreen> {
  Map<String, dynamic> patientProfile = {};
  late DateTime? dob;
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDob = TextEditingController();
  final TextEditingController controllerGender = TextEditingController();
  final TextEditingController controllerMedicalHistory =
      TextEditingController();
  final TextEditingController controllerAllergies = TextEditingController();

  Future<void> onSaveProfile() async {
    final controllers = [
      controllerName,
      controllerGender,
      controllerMedicalHistory,
      controllerAllergies,
    ];

    bool hasEmpty = controllers.any((c) => c.text.trim().isEmpty);
    if (hasEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Vui lòng nhập đầy đủ thông tin ${{controllerDob.text}}")),
      );
      return;
    } else if (controllerDob.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập ngày sinh")),
      );
      return;
    }

    DateTime? selectedDate;
    selectedDate = DateFormat('dd/MM/yyyy').parse(controllerDob.text);

    final formattedDate = selectedDate.toIso8601String();

    final body = {
      "fullName": controllerName.text,
      "dateOfBirth": formattedDate,
      "gender": controllerGender.text.trim() == "Nữ" ? "female" : "male",
      "medicalHistory": controllerMedicalHistory.text,
      "allergies": controllerAllergies.text,
    };

    final response = await makeRequest(
      url: '$apiUrl/patient/edit-profile',
      method: 'PATCH',
      body: body,
    );

    if (response.statusCode == 200) {
      showSuccess(context, MedicalRecordsScreen(), "Quay lại");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thất bại: ${response.body}")),
      );
    }
  }

  Future<void> fetchProfile() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-profile/?patientId=',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu.")),
      );
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      patientProfile = data['data'];
      setState(() {
        controllerName.text = patientProfile['fullname'];
        controllerGender.text =
            patientProfile['gender'] == "female" ? "Nữ" : "Nam";

        controllerMedicalHistory.text = patientProfile['medical_history'];
        controllerAllergies.text = patientProfile['allergies'];
        controllerDob.text = formatDate(patientProfile['date_of_birth']);
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
  void dispose() {
    controllerName.dispose();
    controllerDob.dispose();
    controllerGender.dispose();
    controllerMedicalHistory.dispose();
    controllerAllergies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: 40,
          onPressed: () async {
            ref.read(menuOpenProvider.notifier).state = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MedicalRecordsScreen()),
            );
          },
        ),
        title: Text(
          "Sửa hồ sơ",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: patientProfile.isEmpty
          ? Center(
              child: SpinKitWaveSpinner(color: Colors.blue, size: 75.0),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Họ và tên ",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "*",
                          style: TextStyle(
                              fontSize: screenWidth * 0.035, color: Colors.red),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    TextField(
                      controller: controllerName,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFF3EFEF),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                        hintText: "",
                        hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.03,
                            horizontal: screenWidth * 0.02),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Ngày sinh ",
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.035),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.red),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenWidth * 0.03,
                            ),
                            DatePickerField(
                              width: screenWidth,
                              initialDate: controllerDob.text.isNotEmpty
                                  ? DateFormat('MM/dd/yyyy')
                                      .parse(controllerDob.text)
                                  : DateTime.now(),
                              onDateSelected: (selectedDate) {
                                controllerDob.text = DateFormat('MM/dd/yyyy')
                                    .format(selectedDate);
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Giới tính ",
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.035),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.red),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenWidth * 0.03,
                            ),
                            GenderDropdown(
                              controller: controllerGender,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Tiền sử bệnh ",
                        style: TextStyle(fontSize: screenWidth * 0.035),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    TextField(
                      controller: controllerMedicalHistory,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                      maxLines: null,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFF3EFEF),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                        hintText: "",
                        hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.03,
                            horizontal: screenWidth * 0.02),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Dị ứng ",
                        style: TextStyle(fontSize: screenWidth * 0.035),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    TextField(
                      controller: controllerAllergies,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                      maxLines: null,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFF3EFEF),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                        hintText: "",
                        hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.03,
                            horizontal: screenWidth * 0.02),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.2,
                    ),
                    normalButton(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      label: "Lưu",
                      action: onSaveProfile,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
