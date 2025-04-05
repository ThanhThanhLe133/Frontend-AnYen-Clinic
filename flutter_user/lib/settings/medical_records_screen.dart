import 'package:anyen_clinic/settings/edit_account_screen.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/MedicalRecord.dart';
import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:anyen_clinic/widget/dateTimePicker.dart';
import 'package:anyen_clinic/widget/infoWidget.dart';
import 'package:anyen_clinic/widget/labelMedicalRecord.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
// import 'package:an_yen_clinic/gen/assets.gen.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
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
              // constraints:
              //     BoxConstraints(minHeight: screenHeight * 0.4, maxHeight: 500),
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
                    info: "Lê Thị Thanh Thanh",
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Giới tính",
                    info: "Nữ",
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Ngày sinh",
                    info: "13/03/2005",
                  ),
                  infoWidget(
                    screenWidth: screenWidth,
                    label: "Tiền sử bệnh",
                    info: "ssssssssssssssssssssssssssss",
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
                      screenWidth: screenWidth),
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.02, bottom: screenHeight * 0.01),
                    child: GestureDetector(
                      onTap: () => _showHealthDialog(context),
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
              // constraints: BoxConstraints(
              //     minHeight: screenHeight * 0.15, maxHeight: 500),
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
            MedicalRecord(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              dateRecord: "05/03/2025",
              age: 22,
              height: 125,
              weight: 60,
              bmi: 30,
            ),
          ],
        ),
      ),
    );
  }
}

void _showHealthDialog(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

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
                            initialDate: DateTime.now(),
                            onDateSelected: (selectedDate) {
                              print(
                                  "Ngày được chọn: ${selectedDate.toString()}");
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
              )
            ],
          ),
        ),
      );
    },
  );
}
