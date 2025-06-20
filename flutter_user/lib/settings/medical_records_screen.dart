import 'dart:async';
import 'dart:convert';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/settings/account_screen.dart';
import 'package:anyen_clinic/settings/edit_account_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/MedicalRecord.dart';
import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:anyen_clinic/widget/dateTimePicker.dart';
import 'package:anyen_clinic/widget/infoWidget.dart';
import 'package:anyen_clinic/widget/labelMedicalRecord.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  Map<String, dynamic> patientProfile = {};
  List<Map<String, dynamic>> healthRecords = [];
  final TextEditingController controllerDateTime = TextEditingController();
  final TextEditingController controllerHeight = TextEditingController();
  final TextEditingController controllerWeight = TextEditingController();

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
      setState(() {
        patientProfile = data['data'];
      });
    }
  }

  Future<void> fetchHealthRecord() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-health-records/?patientId=',
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
      setState(() {
        healthRecords = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  Future<void> deleteHealthRecord(String id) async {
    final body = {"id": id};
    final response = await makeRequest(
        url: '$apiUrl/patient/health-records', method: 'DELETE', body: body);
    if (response.statusCode == 200) {
      showSuccessDialog(
          context, MedicalRecordsScreen(), "Xoá thành công", "OK");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thất bại: ${response.body}")),
      );
    }
  }

  void _showHealthDialog(
      BuildContext context,
      TextEditingController controllerDateTime,
      TextEditingController controllerHeight,
      TextEditingController controllerWeight) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    controllerDateTime.text = "";

    Future<void> saveHealthRecord() async {
      final heightText = controllerHeight.text.trim();
      final weightText = controllerWeight.text.trim();

      if (heightText.isEmpty || weightText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vui lòng nhập đầy đủ các trường bắt buộc")),
        );
        return;
      }

      // if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(heightText) ||
      //     !RegExp(r'^-?\d+(\.\d+)?$').hasMatch(weightText)) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Chiều cao và cân nặng phải là số hợp lệ")),
      //   );
      //   return;
      // }

      final height = double.tryParse(controllerHeight.text);
      final weight = double.tryParse(controllerWeight.text);

      final dateText = controllerDateTime.text.trim().isEmpty
          ? DateFormat('dd/MM/yyyy').format(DateTime.now())
          : controllerDateTime.text.trim();

      final selectedDate = DateFormat('dd/MM/yyyy').parse(dateText);

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final body = {
        "recordDate": formattedDate,
        "height": height,
        "weight": weight,
      };

      final response = await makeRequest(
        url: '$apiUrl/patient/health-records',
        method: 'POST',
        body: body,
      );

      if (response.statusCode == 200) {
        showSuccessDialog(
            context, MedicalRecordsScreen(), "Lưu thành công", "OK");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lưu thất bại: ${response.body}")),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(10),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close, color: Colors.grey, size: 24),
                  ),
                ),
                Text(
                  "Chỉ số sức khoẻ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFD9D9D9)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Ngày đo:",
                              style: TextStyle(fontSize: screenWidth * 0.04)),
                          SizedBox(width: 10),
                          Expanded(
                            child: DatePickerField(
                              width: screenWidth * 0.85,
                              initialDate: controllerDateTime.text.isNotEmpty
                                  ? DateFormat('dd/MM/yyyy')
                                      .parse(controllerDateTime.text)
                                  : DateTime.now(),
                              onDateSelected: (selectedDate) {
                                controllerDateTime.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Chiều cao:",
                              style: TextStyle(fontSize: screenWidth * 0.04)),
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: TextField(
                              controller: controllerHeight,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF3EFEF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text("cm",
                              style: TextStyle(fontSize: screenWidth * 0.04)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cân nặng:",
                              style: TextStyle(fontSize: screenWidth * 0.04)),
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: TextField(
                              controller: controllerWeight,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF3EFEF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text("kg",
                              style: TextStyle(fontSize: screenWidth * 0.04)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                    text: "OK",
                    isPrimary: true,
                    screenWidth: screenWidth,
                    onPressed: () async {
                      await saveHealthRecord();
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controllerDateTime.dispose();
    controllerHeight.dispose();
    controllerWeight.dispose();
    super.dispose();
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
              MaterialPageRoute(builder: (context) => AccountScreen()),
            );
          },
        ),
        title: Text(
          "Hồ sơ y tế",
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
              child: SpinKitWaveSpinner(
                color: Colors.blue,
                size: 75.0,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.03),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditAccountScreen()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Sửa',
                            style: TextStyle(
                              color: Color(0xFF119CF0),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFFD9D9D9),
                      width: 1,
                    ),
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
                        info:
                            patientProfile['gender'] == "female" ? "Nữ" : "Nam",
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
                          screenWidth: screenWidth),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            bottom: screenHeight * 0.01),
                        child: GestureDetector(
                          onTap: () => _showHealthDialog(
                              context,
                              controllerDateTime,
                              controllerHeight,
                              controllerWeight),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Thêm',
                                style: TextStyle(
                                  color: Color(0xFF119CF0),
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  constraints: BoxConstraints(
                      minHeight: screenHeight * 0.15, maxHeight: 500),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LabelMedicalRecord(
                        screenWidth: screenWidth,
                        label: "Ngày đo",
                      ),
                      LabelMedicalRecord(
                        screenWidth: screenWidth,
                        label: "Tuổi",
                      ),
                      LabelMedicalRecord(
                        screenWidth: screenWidth,
                        label: "Chiều cao \n (cm)",
                      ),
                      LabelMedicalRecord(
                        screenWidth: screenWidth,
                        label: "Cân nặng \n (kg)",
                      ),
                      LabelMedicalRecord(
                        screenWidth: screenWidth,
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
                            final String recordId = record['id'].toString();
                            return Dismissible(
                              key: Key(recordId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.white,
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                Completer<bool> completer = Completer<bool>();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      "Xác nhận",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "Bạn có chắc muốn xóa bản ghi sức khoẻ này không?",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          completer.complete(false);
                                        },
                                        child: Text(
                                          "Huỷ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          completer.complete(true);
                                        },
                                        child: Text(
                                          "Xoá",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return await completer.future;
                              },
                              onDismissed: (direction) {
                                deleteHealthRecord(record['id']);
                              },
                              child: MedicalRecord(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                dateRecord: formatDate(recordDate),
                                age: DateTime.now().year -
                                    DateTime.parse(
                                      patientProfile['date_of_birth'],
                                    ).year,
                                height: height,
                                weight: weight,
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
