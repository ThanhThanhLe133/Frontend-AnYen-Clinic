import 'dart:math';

import 'package:anyen_clinic/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageConnectingCard extends ConsumerWidget {
  const MessageConnectingCard(
      {super.key,
      required this.isOnline,
      required this.date,
      required this.time});
  final bool isOnline;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.03,
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
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
          // Thông tin bác sĩ
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
                children: [
                  MoreOptionsMenu(
                    options: [
                      "Thông tin bác sĩ",
                      "Lịch sử thanh toán",
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case "Thông tin bác sĩ":
                          break;
                        // case "Lịch sử thanh toán":
                        //   showPaymentHistoryDialog(
                        //     context,
                        //     "MOMO",
                        //     true,
                        //     -99000,
                        //     DateTime(2025, 2, 23, 14, 58),
                        //   );
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFECF8FF), //
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), //
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  fixedSize: Size(screenWidth * 0.05, 16),
                  minimumSize: Size(
                    screenWidth * 0.2,
                    screenHeight * 0.1,
                  ),
                ),
                child: Text(
                  "Liên hệ CSKH",
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: min(screenWidth * 0.035, 16),
                    color: const Color(0xFF40494F),
                  ),
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
