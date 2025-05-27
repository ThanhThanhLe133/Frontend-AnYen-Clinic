import 'dart:convert';
import 'dart:math';

import 'package:ayclinic_doctor_admin/DOCTOR/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dialog/InputPrescription.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dialog/InputSummary.dart';
import 'package:ayclinic_doctor_admin/dialog/Prescription.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/Summary_doctor.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppointmentConnectedCard extends ConsumerStatefulWidget {
  const AppointmentConnectedCard({
    super.key,
    required this.isOnline,
    required this.date,
    this.status,
    required this.time,
    required this.question,
    required this.appointment_id,
    required this.patient_id,
  });
  final bool isOnline;
  final String date;
  final String time;
  final String? status;
  final String question;
  final String appointment_id;
  final String patient_id;
  @override
  ConsumerState<AppointmentConnectedCard> createState() =>
      AppointmentConnectedCardState();
}

class AppointmentConnectedCardState
    extends ConsumerState<AppointmentConnectedCard> {
  Map<String, dynamic> patientProfile = {};

  Future<void> fetchPatient() async {
    String patientId = widget.patient_id;
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-profile/?patientId=$patientId',
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
        patientProfile = data['data'];
      });
    }
  }

  bool isAppointmentTimeReached(String date, String time) {
    try {
      final partsDate = date.split('/'); // ["dd", "MM", "yyyy"]
      final day = int.parse(partsDate[0]);
      final month = int.parse(partsDate[1]);
      final year = int.parse(partsDate[2]);
      final partsTime = time.split(':'); // ["HH", "mm"]
      final hour = int.parse(partsTime[0]);
      final minute = int.parse(partsTime[1]);

      final appointmentDateTime = DateTime(year, month, day, hour, minute);
      final now = DateTime.now();

      return now.isAtSameMomentAs(appointmentDateTime) ||
          now.isAfter(appointmentDateTime);
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatient();
  }

  Future<String> getConversationIdByAppointmentId(String appointmentId) async {
    final response = await makeRequest(
      url: '$apiUrl/chat/appointment/$appointmentId/conversation-id',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['conversationId'];
    } else {
      // Handle error
      print('Failed to fetch conversation ID: ${response.statusCode}');
      throw Exception('Failed to fetch conversation ID');
    }
  }

  Future<void> sendMessageToAdmin() async {
    final response = await makeRequest(
      url: '$apiUrl/chat/create-conversation',
      method: 'POST',
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['mes'])));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(conversationId: responseData['data']['id'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return patientProfile.isEmpty
        ? Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Center(
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 30.0,
              ),
            ),
          )
        : GestureDetector(
            onTap: () async {
              //cuộc hẹn kết thúc -> vào xem tin nhắn
              if (widget.status == "Completed") {
                final conversationId = await getConversationIdByAppointmentId(
                    widget.appointment_id);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(conversationId: conversationId)));

                //cuộc hẹn được xác nhận rồi + tới giờ hẹn
              } else if (widget.status == "Confirmed") {
                if (isAppointmentTimeReached(widget.date, widget.time)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(
                              appointmentId: widget.appointment_id)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Chưa đến giờ hẹn. Vui lòng đợi đến ${widget.time} ${widget.date}')),
                  );
                }
              }
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
                  // Thông tin bác sĩ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patientProfile['fullname']},  ${(DateTime.now().year - DateTime.parse(patientProfile['date_of_birth']).year)} tuổi',
                          maxLines: null,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40494F),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Text(
                          "Câu hỏi: ${widget.question.length > 10 ? '${widget.question.substring(0, 10)}...' : widget.question}",
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
                        Row(
                          children: [
                            Icon(
                              widget.isOnline
                                  ? Icons.chat_rounded
                                  : Icons.people_outline_rounded,
                              color: widget.isOnline
                                  ? Colors.blue
                                  : Color(0xFFDB5B8B),
                              size: screenWidth * 0.05,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isOnline
                                  ? "Tư vấn online"
                                  : "Tư vấn trực tiếp",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                                color: widget.isOnline
                                    ? Colors.blue
                                    : Color(0xFFDB5B8B),
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
                          Container(
                            width: screenWidth * 0.2,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: widget.status == "Completed"
                                  ? Color(0xFF19EA31)
                                  : widget.status == "Canceled"
                                      ? Color(0xFF9BA5AC)
                                      : Color(0xFF119CF0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              widget.status == "Completed"
                                  ? "Đã hoàn thành"
                                  : widget.status == "Canceled"
                                      ? "Đã huỷ"
                                      : "Sắp tới",
                              style: TextStyle(
                                fontSize: screenWidth * 0.02,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          MoreOptionsMenu(
                            options: [
                              "Xem câu hỏi",
                              "Thông tin bệnh nhân",
                              "Kết thúc tư vấn",
                              "Xem đơn thuốc",
                              "Xem tổng kết",
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case "Xem câu hỏi":
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Câu hỏi",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        content: Text(
                                          widget.question,
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "ĐÓNG",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  break;
                                case "Thông tin bệnh nhân":
                                  showPatientDetailScreen(
                                      context, widget.patient_id);
                                  break;
                                case "Kết thúc tư vấn":
                                  if (widget.status != "Confirmed") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cuộc hẹn đã hoàn thành/đã bị huỷ!",
                                        ),
                                      ),
                                    );
                                  } else {
                                    showInputSummaryDialog(
                                      context,
                                      widget.appointment_id,
                                    );
                                  }
                                  //cuộc hẹn online phải kết thúc trong tin nhắn
                                  break;
                                case "Xem đơn thuốc":
                                  if (widget.status != "Completed") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Cuộc hẹn chưa hoàn thành"),
                                      ),
                                    );
                                  } else {
                                    showPrescriptionDialog(
                                      context,
                                      widget.appointment_id,
                                    );
                                  }
                                  break;
                                case "Xem tổng kết":
                                  if (widget.status != "Completed") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Cuộc hẹn chưa hoàn thành"),
                                      ),
                                    );
                                  } else {
                                    showSummaryDoctorDialog(
                                      context,
                                      widget.appointment_id,
                                    );
                                  }
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
                                NetworkImage(patientProfile['avatar_url']),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      ElevatedButton(
                        onPressed: sendMessageToAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECF8FF), //
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), //
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          fixedSize: Size(screenWidth * 0.05, 16),
                          minimumSize:
                              Size(screenWidth * 0.18, screenHeight * 0.05),
                        ),
                        child: Text(
                          "Liên hệ QTV",
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
          );
  }
}
