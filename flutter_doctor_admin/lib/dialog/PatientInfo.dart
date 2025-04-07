import 'package:ayclinic_doctor_admin/widget/LabelMedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/MedicalRecord.dart';
import 'package:ayclinic_doctor_admin/widget/infoWidget.dart';
import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart';
import 'package:flutter/material.dart';

void showPatientInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PatientInfoDialog();
    },
  );
}

class PatientInfoDialog extends StatelessWidget {
  const PatientInfoDialog({super.key});

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
              Center(
                child: Text(
                  "Thông tin bệnh nhân",
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    height: screenHeight * 0.25,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  SizedBox(height: screenWidth * 0.05),
                  sectionTitle(
                    title: 'Chỉ số sức khoẻ',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth * 0.8,
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
                          screenWidth: screenWidth * 0.8,
                          label: "Ngày đo",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.8,
                          label: "Tuổi",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.8,
                          label: "Chiều cao \n (cm)",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.8,
                          label: "Cân nặng \n (kg)",
                        ),
                        LabelMedicalRecord(
                          screenWidth: screenWidth * 0.8,
                          label: "BMI",
                        ),
                      ],
                    ),
                  ),
                  MedicalRecord(
                    screenWidth: screenWidth * 0.8,
                    screenHeight: screenHeight,
                    dateRecord: "05/03/2025",
                    age: 22,
                    height: 125,
                    weight: 60,
                    bmi: 30,
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
