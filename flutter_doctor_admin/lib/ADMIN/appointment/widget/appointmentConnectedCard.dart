import 'dart:convert';
import 'dart:math';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/details_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/patient_detail_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/review_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/CancelAppointmentDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/ChangeConsultationDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/EditDateAppointmentDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/PaymentHistory.dart';
import 'package:ayclinic_doctor_admin/dialog/Prescription.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/Summary_admin.dart';
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
    required this.review_id,
    required this.date,
    required this.time,
    required this.question,
    required this.doctor_id,
    required this.total_paid,
    required this.appointment_id,
    required this.patient_id,
    required this.cancel_reason,
    required this.status,
  });
  final String review_id;
  final bool isOnline;
  final String date;
  final String time;
  final String question;
  final String doctor_id;
  final String appointment_id;
  final String total_paid;
  final String patient_id;
  final String status;
  final String cancel_reason;
  @override
  ConsumerState<AppointmentConnectedCard> createState() =>
      AppointmentConnectedCardState();
}

class AppointmentConnectedCardState
    extends ConsumerState<AppointmentConnectedCard> {
  Map<String, dynamic> doctorProfile = {};
  Map<String, dynamic> patientProfile = {};
  Future<void> editAppointment() async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/edit-appointment',
        method: 'PATCH',
        body: {"appointment_id": widget.appointment_id, "status": "Pending"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AppointmentScreen(),
          "Thay đổi thành công",
          "QUay lại",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi sửa lịch hẹn")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

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
    return doctorProfile.isEmpty || patientProfile.isEmpty
        ? Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.02),
          child: Center(
            child: SpinKitThreeBounce(
              color: Colors.white, // Màu trắng
              size: 30.0, // Kích thước của ba vòng tròn
            ),
          ),
        )
        : Container(
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
                              widget.isOnline ? Colors.blue : Color(0xFFDB5B8B),
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
                    SizedBox(height: 10),
                    widget.status == "Completed"
                        ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReviewDoctorScreen(
                                      reviewId: widget.review_id,
                                      appointmentId: widget.appointment_id,
                                      doctorId: widget.doctor_id,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.2,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenWidth * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.review_id == ""
                                      ? Color(0xFFD9D9D9)
                                      : Color(0xFFDB5B8B),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              widget.review_id != ""
                                  ? "Đã đánh giá"
                                  : "Chưa đánh giá",
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),
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
                          color:
                              widget.status == "Completed"
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
                              : "Đã xác nhận",
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
                          "Đổi trạng thái",
                          "Xem lịch sử thanh toán",
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
                            case "Đổi trạng thái":
                              if (widget.status == "Confirmed") {
                                showOptionDialog(
                                  context,
                                  "Đổi trạng thái",
                                  "Bạn có chắc chắn muốn đổi trạng thái cuộc hẹn sang 'Chưa xác nhận'",
                                  "HUỶ",
                                  "Đồng Ý",
                                  () async {
                                    await editAppointment();
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Không thể thay đổi cuộc hẹn đã hoàn thành/huỷ!",
                                    ),
                                  ),
                                );
                              }
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
                            case "Xem đơn thuốc":
                              if (widget.status != "Completed") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Cuộc hẹn chưa hoàn thành!"),
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
                                    content: Text("Cuộc hẹn chưa hoàn thành!"),
                                  ),
                                );
                              } else {
                                showSummaryAdminDialog(
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
                  SizedBox(height: screenWidth * 0.03),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        widget.status == "Canceled"
                            ? Text(
                              'Lý do: ${widget.cancel_reason}',
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
