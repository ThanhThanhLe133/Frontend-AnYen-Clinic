import 'dart:convert';
import 'dart:math';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_time_patterns.dart';

class AppointmentConnectingCard extends ConsumerStatefulWidget {
  const AppointmentConnectingCard({
    super.key,
    required this.isOnline,
    required this.date,
    required this.time,
    required this.question,
    required this.appointment_id,
    required this.patient_id,
  });
  final bool isOnline;
  final String date;
  final String time;
  final String question;
  final String appointment_id;
  final String patient_id;
  @override
  ConsumerState<AppointmentConnectingCard> createState() =>
      AppointmentConnectingCardState();
}

class AppointmentConnectingCardState
    extends ConsumerState<AppointmentConnectingCard> {
  Map<String, dynamic> patientProfile = {};
  Future<void> confirmAppointment() async {
    String appointmentId = widget.appointment_id;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lỗi lưu dữ liệu $appointmentId.')));
    final response = await makeRequest(
      url: '$apiUrl/doctor/confirm-appointment',
      method: 'PATCH',
      body: {"appointment_id": appointmentId},
    );
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi lưu dữ liệu.")));
      Navigator.pop(context);
    } else {
      showSuccessDialog(
        context,
        AppointmentScreen(isConnecting: true),
        "Xác nhận thành công",
        "Tới lịch hẹn",
      );
    }
  }

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

  @override
  void initState() {
    super.initState();
    fetchPatient();
  }

  @override
  Widget build(BuildContext context) {
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
      child: patientProfile.isEmpty
          ? Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Center(
                child: SpinKitThreeBounce(color: Colors.white, size: 30.0),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thông tin bệnh nhân
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

                // Ảnh bác sĩ và nút liên hệ
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MoreOptionsMenu(
                          options: ["Thông tin bệnh nhân", "Xem câu hỏi"],
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
                                  context,
                                  widget.patient_id,
                                );
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
                          backgroundImage: NetworkImage(
                            patientProfile['avatar_url'],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => showOptionDialog(
                              context,
                              "Xác nhận lịch hẹn",
                              "Bạn muốn xác nhận thực hiện ca tư vấn này?",
                              "HUỶ",
                              "ĐỒNG Ý",
                              confirmAppointment,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF119CF0), //
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5), //
                              ),

                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              fixedSize: Size(screenWidth * 0.05, 16),
                              minimumSize: Size(
                                screenWidth * 0.18,
                                screenHeight * 0.05,
                              ),
                            ),
                            child: Text(
                              "Xác nhận",
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: min(screenWidth * 0.035, 16),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          ElevatedButton(
                            onPressed: () => sendMessageToAdmin(context),
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
                                screenWidth * 0.2,
                                screenHeight * 0.05,
                              ),
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
                    ),
                    SizedBox(height: screenWidth * 0.03),
                  ],
                ),
              ],
            ),
    );
  }
}
