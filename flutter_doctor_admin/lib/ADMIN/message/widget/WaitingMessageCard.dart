import 'dart:math';

import 'package:ayclinic_doctor_admin/dialog/PatientInfo.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnFinishMessageCard extends ConsumerWidget {
  const UnFinishMessageCard({
    super.key,
    required this.isPatient,
    required this.date,
    required this.time,
    required this.question,
  });
  final bool isPatient;
  final String date;
  final String time;
  final String question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
      constraints: BoxConstraints(minWidth: screenWidth * 0.9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thông tin bác sĩ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User1, 19 tuổi",
                  maxLines: null,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40494F),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  "Câu hỏi: ${question.length > 10 ? '${question.substring(0, 10)}...' : question}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.black,
                          size: screenWidth * 0.05,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Colors.black,
                          size: screenWidth * 0.05,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ảnh bác sĩ và nút liên hệ
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  MoreOptionsMenu(
                    options: [
                      isPatient ? "Thông tin bệnh nhân" : "Thông tin bác sĩ",
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case "Thông tin bệnh nhân":
                          showPatientInfoDialog(context);
                          break;

                        default:
                      }
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: screenWidth * 0.2,
                  child: CircleAvatar(
                    radius: screenWidth * 0.07,
                    backgroundImage:
                        isPatient
                            ? AssetImage("assets/images/user.png")
                            : AssetImage("assets/images/doctor.png"),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          () => showOptionDialog(
                            context,
                            "Xác nhận kết thúc",
                            "Bạn muốn xác nhận kết thúc ca tư vấn này?",
                            "HUỶ",
                            "ĐỒNG Ý",
                            null,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF119CF0), //
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), //
                        ),

                        padding: const EdgeInsets.symmetric(vertical: 8),
                        fixedSize: Size(screenWidth * 0.05, 16),
                        minimumSize: Size(
                          screenWidth * 0.2,
                          screenHeight * 0.06,
                        ),
                      ),
                      child: Text(
                        "Tham gia",
                        maxLines: null,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: min(screenWidth * 0.035, 16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.03),
            ],
          ),
        ],
      ),
    );
  }
}
