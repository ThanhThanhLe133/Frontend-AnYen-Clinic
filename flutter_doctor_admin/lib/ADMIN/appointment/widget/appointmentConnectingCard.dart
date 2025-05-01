import 'dart:convert';
import 'dart:math';

import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/details_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/CancelAppointmentDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/ChangeConsultationDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/EditDateAppointmentDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/PaymentHistory.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppointmentConnectingCard extends ConsumerStatefulWidget {
  const AppointmentConnectingCard({
    super.key,
    required this.isOnline,
    required this.date,
    required this.time,
    required this.question,
    required this.doctor_id,
    required this.total_paid,
    required this.appointment_id,
    required this.patient_id,
    required this.status,
  });
  final bool isOnline;
  final String date;
  final String time;
  final String question;
  final String doctor_id;
  final String appointment_id;
  final String total_paid;
  final String patient_id;
  final String status;
  @override
  ConsumerState<AppointmentConnectingCard> createState() =>
      AppointmentConnectingCardState();
}

class AppointmentConnectingCardState
    extends ConsumerState<AppointmentConnectingCard> {
  Map<String, dynamic> doctorProfile = {};
  Map<String, dynamic> patientProfile = {};
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
    // ref.read(doctorIdProvider.notifier).state = widget.doctor_id;
    fetchDoctor();
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
      child:
          doctorProfile.isEmpty || patientProfile.isEmpty
              ? Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white, // Màu trắng
                    size: 30.0, // Kích thước của ba vòng tròn
                  ),
                ),
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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

                        Text(
                          doctorProfile['name'],
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
                        Row(
                          children: [
                            Icon(
                              widget.isOnline
                                  ? Icons.chat_rounded
                                  : Icons.people_outline_rounded,
                              color:
                                  widget.isOnline
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
                                color:
                                    widget.isOnline
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
                          Container(
                            width: screenWidth * 0.2,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.status == "Pending"
                                      ? Color(0xFF119CF0)
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              widget.status == "Pending"
                                  ? "Chưa xác nhận"
                                  : "Chưa thanh toán",
                              style: TextStyle(
                                fontSize: screenWidth * 0.022,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          MoreOptionsMenu(
                            options: [
                              "Xem câu hỏi",
                              "Thông tin bệnh nhân",
                              "Thông tin bác sĩ",
                              "Huỷ lịch hẹn",
                              "Sửa lịch hẹn",
                              "Thay đổi hình thức",
                              "Xem lịch sử thanh toán",
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
                                case "Thông tin bác sĩ":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DetailsDoctorScreen(
                                            doctorId: widget.doctor_id,
                                          ),
                                    ),
                                  );
                                  break;
                                case "Thông tin bệnh nhân":
                                  showPatientDetailScreen(
                                    context,
                                    widget.patient_id,
                                  );
                                  break;
                                case "Huỷ lịch hẹn":
                                  if (widget.status == "Unpaid") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cuộc hẹn chưa được thanh toán. Không thể huỷ!",
                                        ),
                                      ),
                                    );
                                  } else {
                                    showCancelAppointmentDialog(
                                      context,
                                      widget.appointment_id,
                                    );
                                  }

                                  break;
                                case "Sửa lịch hẹn":
                                  showEditDateAppointmentDialog(
                                    context,
                                    widget.appointment_id,
                                    widget.date,
                                    widget.time,
                                  );
                                  break;
                                case "Thay đổi hình thức":
                                  showChangeConsultationDialog(
                                    context,
                                    widget.appointment_id,
                                    widget.isOnline,
                                  );
                                  break;
                                case "Xem lịch sử thanh toán":
                                  if (widget.status == "Unpaid") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cuộc hẹn chưa được thanh toán",
                                        ),
                                      ),
                                    );
                                  } else {
                                    showPaymentHistoryDialog(
                                      context,
                                      widget.appointment_id,
                                    );
                                    break;
                                  }

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
                                backgroundImage: NetworkImage(
                                  patientProfile['avatar_url'],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: screenWidth * 0.15,
                              child: CircleAvatar(
                                radius: screenWidth * 0.07,
                                backgroundImage: NetworkImage(
                                  doctorProfile['avatar_url'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                  screenHeight * 0.06,
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
                                  screenHeight * 0.06,
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
                      ),
                      SizedBox(height: screenWidth * 0.03),
                    ],
                  ),
                ],
              ),
    );
  }
}
