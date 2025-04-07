import 'dart:math';

import 'package:ayclinic_doctor_admin/dialog/PatientInfo.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentConnectedCard extends ConsumerWidget {
  const AppointmentConnectedCard({
    super.key,
    required this.isOnline,
    required this.date,
    this.status,
    required this.time,
    required this.question,
  });
  final bool isOnline;
  final String date;
  final String time;
  final String? status;
  final String question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
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

                Text(
                  "BS.CKI Macus Horizon",
                  maxLines: null,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40494F),
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
                SizedBox(height: screenWidth * 0.05),
                Row(
                  children: [
                    Icon(
                      isOnline
                          ? Icons.chat_rounded
                          : Icons.people_outline_rounded,
                      color: isOnline ? Colors.blue : Color(0xFFDB5B8B),
                      size: screenWidth * 0.05,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "Tư vấn online" : "Tư vấn trực tiếp",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color: isOnline ? Colors.blue : Color(0xFFDB5B8B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ảnhvà nút liên hệ
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  status != null && status!.isNotEmpty
                      ? Container(
                        width: screenWidth * 0.2,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenWidth * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color:
                              status == "Đã hoàn thành"
                                  ? Color(0xFF19EA31)
                                  : status == "Đã huỷ"
                                  ? Color(0xFF9BA5AC)
                                  : Color(0xFF119CF0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          status!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.02,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : SizedBox(),
                  MoreOptionsMenu(
                    options: [
                      "Thông tin bệnh nhân",
                      "Thông tin bác sĩ",
                      "Huỷ lịch hẹn",
                      "Sửa lịch hẹn",
                      "Thay đổi hình thức",
                      "Đổi trạng thái",
                      "Xem lịch sử thanh toán",
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
              Row(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: screenWidth * 0.15,
                      child: CircleAvatar(
                        radius: screenWidth * 0.07,
                        backgroundImage: AssetImage("assets/images/user.png"),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: screenWidth * 0.15,
                      child: CircleAvatar(
                        radius: screenWidth * 0.07,
                        backgroundImage: AssetImage("assets/images/doctor.png"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    status == "Đã huỷ"
                        ? Text(
                          "Lý do: Bác sĩ bận",
                          maxLines: null,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFF0000),
                          ),
                        )
                        : Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFECF8FF), //
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), //
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                fixedSize: Size(screenWidth * 0.05, 16),
                                minimumSize: Size(
                                  screenWidth * 0.15,
                                  screenHeight * 0.08,
                                ),
                              ),
                              child: Text(
                                "Liên hệ KH",
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: min(screenWidth * 0.035, 16),
                                  color: const Color(0xFF40494F),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFECF8FF), //
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), //
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                fixedSize: Size(screenWidth * 0.05, 16),
                                minimumSize: Size(
                                  screenWidth * 0.15,
                                  screenHeight * 0.08,
                                ),
                              ),
                              child: Text(
                                "Liên hệ bác sĩ",
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: min(screenWidth * 0.035, 16),
                                  color: const Color(0xFF40494F),
                                ),
                              ),
                            ),
                          ],
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
