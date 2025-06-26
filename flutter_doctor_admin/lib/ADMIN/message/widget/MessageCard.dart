import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/details_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    super.key,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.time,
    required this.conversationId,
    required this.name,
    required this.avatarUrl,
    required this.isPatient,
    required this.unreadMessages,
    this.onPopBack,
  });
  final String date;
  final String time;
  final String patientId;
  final String doctorId;
  final String conversationId;
  final String name;
  final String avatarUrl;
  final bool isPatient;
  final int unreadMessages;
  final VoidCallback? onPopBack;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late bool isPatient;

  @override
  void initState() {
    super.initState();
    isPatient = widget.isPatient;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: widget.conversationId,
                name: widget.name,
                avatarUrl: widget.avatarUrl,
              ),
            )).then((_) {
          if (widget.onPopBack != null) {
            widget.onPopBack!();
          }
        });
      },
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.name ?? "",
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
                            widget.date,
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
                            widget.time,
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
                  widget.unreadMessages > 0
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${widget.unreadMessages} tin nhắn chưa đọc",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: MoreOptionsMenu(
                    options: [
                      isPatient ? "Thông tin bệnh nhân" : "Thông tin bác sĩ",
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case "Thông tin bác sĩ":
                          isPatient
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Không có thông tin bác sĩ."),
                                  ),
                                )
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsDoctorScreen(
                                      doctorId: widget.doctorId,
                                    ),
                                  ),
                                );
                          break;
                        case "Thông tin bệnh nhân":
                          isPatient
                              ? showPatientDetailScreen(
                                  context,
                                  widget.patientId,
                                )
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Không có thông tin bệnh nhân."),
                                  ),
                                );
                          break;
                      }
                    },
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundImage: NetworkImage(
                    widget.avatarUrl,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
