import 'dart:convert';
import 'dart:math';

import 'package:anyen_clinic/appointment/details_doctor.dart';
import 'package:anyen_clinic/appointment/changeDoctor/DialogToChangeDoctor.dart';
import 'package:anyen_clinic/dialog/ChangeConsultationDialog.dart';
import 'package:anyen_clinic/dialog/EditDateAppointmentDialog.dart';
import 'package:anyen_clinic/dialog/PaymentHistory.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentConnectingCard extends ConsumerStatefulWidget {
  const AppointmentConnectingCard(
      {super.key,
      required this.question,
      required this.doctor_id,
      required this.total_paid,
      required this.appointment_id,
      required this.isOnline,
      required this.date,
      required this.time});
  final bool isOnline;
  final String date;
  final String time;
  final String doctor_id;
  final String appointment_id;
  final String total_paid;
  final String question;

  @override
  ConsumerState<AppointmentConnectingCard> createState() =>
      AppointmentConnectingCardState();
}

class AppointmentConnectingCardState
    extends ConsumerState<AppointmentConnectingCard> {
  Map<String, dynamic> doctorProfile = {};
  Future<void> fetchDoctor() async {
    String doctorId = widget.doctor_id;
    final response = await makeRequest(
      url: '$apiUrl/get/get-doctor/?userId=$doctorId',
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
        doctorProfile = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(doctorIdProvider.notifier).state = widget.doctor_id;
    fetchDoctor();
  }

  @override
  Widget build(BuildContext context) {
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
                  doctorProfile['name'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40494F),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  doctorProfile['specialization'],
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
                        Icon(Icons.timer,
                            color: Colors.black, size: screenWidth * 0.05),
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
                Row(
                  children: [
                    Icon(
                        widget.isOnline
                            ? Icons.chat_rounded
                            : Icons.people_outline_rounded,
                        color:
                            widget.isOnline ? Colors.blue : Color(0xFFDB5B8B),
                        size: screenWidth * 0.05),
                    const SizedBox(width: 6),
                    Text(
                      widget.isOnline ? "Tư vấn online" : "Tư vấn trực tiếp",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color:
                            widget.isOnline ? Colors.blue : Color(0xFFDB5B8B),
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
                      "Xem câu hỏi",
                      "Sửa lịch hẹn",
                      "Thay đổi bác sĩ",
                      "Thay đổi hình thức Tư vấn",
                      "Thông tin bác sĩ",
                      "Lịch sử thanh toán",
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case "Xem câu hỏi":
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Câu hỏi'),
                                  backgroundColor: Colors.white,
                                  content: Text(widget.question),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Đóng'),
                                    ),
                                  ],
                                );
                              });
                        case "Sửa lịch hẹn":
                          showEditDateAppointmentDialog(
                            context,
                            widget.appointment_id,
                            widget.date,
                            widget.time,
                          );
                          break;
                        case "Thay đổi hình thức Tư vấn":
                          showChangeConsultationDialog(
                              context, widget.appointment_id, widget.isOnline);
                          break;
                        case "Thay đổi bác sĩ":
                          showOptionDialogToChangeDoctor(
                              context,
                              widget.appointment_id,
                              widget.doctor_id,
                              widget.total_paid,
                              "Thay đổi bác sĩ",
                              "Bạn có chắc chắn muốn thay đổi bác sĩ tư vấn?",
                              "HUỶ",
                              "ĐỒNG Ý");
                          break;
                        case "Thông tin bác sĩ":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorDetail(doctorId: widget.doctor_id),
                            ),
                          );
                          break;
                        case "Lịch sử thanh toán":
                          showPaymentHistoryDialog(
                            context,
                            widget.appointment_id,
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
                    backgroundImage: doctorProfile['avatar_url'],
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
                    screenWidth * 0.15,
                    screenHeight * 0.08,
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
