import 'package:anyen_clinic/dialog/PaymentHistory.dart';
import 'package:anyen_clinic/dialog/Prescription.dart';
import 'package:anyen_clinic/dialog/UpdateInfoDialog.dart';
import 'package:anyen_clinic/review/review_doctor_screen.dart';
import 'package:anyen_clinic/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';

class MessageConnectedCard extends StatelessWidget {
  const MessageConnectedCard(
      {super.key,
      required this.isOnline,
      required this.date,
      this.status,
      required this.time});
  final bool isOnline;
  final String date;
  final String time;
  final String? status;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.03,
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      constraints: BoxConstraints(
        minWidth: screenWidth * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BS.CKI Macus Horizon",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40494F),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  "Tâm lý - Nội tổng quát",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: Colors.black, size: screenWidth * 0.05),
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
                        Icon(Icons.timer,
                            color: Colors.black, size: screenWidth * 0.05),
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
                        size: screenWidth * 0.05),
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

          // Ảnh bác sĩ và nút liên hệ
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  status != null && status!.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewDoctorScreen()),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.18,
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01,
                                vertical: screenWidth * 0.01),
                            decoration: BoxDecoration(
                              color: status == "Đã đánh giá"
                                  ? Color(0xFFD9D9D9)
                                  : Color(0xFFDB5B8B),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              status!,
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  MoreOptionsMenu(
                    options: [
                      "Xem đơn thuốc",
                      "Thông tin bác sĩ",
                      "Lịch sử thanh toán",
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case "Xem đơn thuốc":
                          showPrescriptionDialog(
                            context,
                            [
                              {"name": "Paracetamol", "dosage": "Sáng 1v"},
                              {"name": "Amoxicillin", "dosage": "Sáng 1v"},
                              {"name": "Vitamin C", "dosage": "Sáng 1v"},
                            ],
                          );
                          break;
                        case "Thông tin bác sĩ":
                          break;
                        case "Lịch sử thanh toán":
                          showPaymentHistoryDialog(
                            context,
                            "MOMO",
                            true,
                            -99000,
                            DateTime(2025, 2, 23, 14, 58),
                          );
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
                    backgroundImage: AssetImage("assets/images/doctor.png"),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  fixedSize: Size(screenWidth * 0.05, 16),
                  minimumSize: Size(
                    screenWidth * 0.2,
                    screenHeight * 0.06,
                  ),
                ),
                child: Text(
                  "ĐẶT LẠI",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
