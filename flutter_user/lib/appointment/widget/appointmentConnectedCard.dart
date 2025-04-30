import 'dart:convert';
import 'dart:math';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/appointment/details_doctor.dart';
import 'package:anyen_clinic/dialog/ChangeConsultationDialog.dart';
import 'package:anyen_clinic/dialog/PaymentHistory.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/doctor/details_doctor_screen.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/review/review_doctor_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/buildMoreOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppointmentConnectedCard extends ConsumerStatefulWidget {
  const AppointmentConnectedCard(
      {super.key,
      required this.review_id,
      required this.question,
      required this.doctor_id,
      required this.appointment_id,
      required this.isOnline,
      required this.date,
      required this.status,
      required this.time});
  final bool isOnline;
  final String review_id;
  final String date;
  final String time;
  final String status;
  final String doctor_id;
  final String appointment_id;
  final String question;
  @override
  ConsumerState<AppointmentConnectedCard> createState() =>
      AppointmentConnectedCardState();
}

class AppointmentConnectedCardState
    extends ConsumerState<AppointmentConnectedCard> {
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

  Future<void> hideAppointment() async {
    String appointmentId = widget.appointment_id;
    final response = await makeRequest(
        url: '$apiUrl/hide-appointment',
        method: 'PATCH',
        body: {"appointment_id": appointmentId});
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi thay đổi dữ liệu.")));
      Navigator.pop(context);
    } else {
      showSuccessDialog(
          context, AppointmentScreen(), "Ẩn thành công", "Quay lại");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctor();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return doctorProfile.isEmpty
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
                        doctorProfile["specialization"],
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
                                  color: Colors.black,
                                  size: screenWidth * 0.05),
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
                                  color: Colors.black,
                                  size: screenWidth * 0.05),
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
                              size: screenWidth * 0.05),
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
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenWidth * 0.01),
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
                            "Thay đổi hình thức Tư vấn",
                            "Thông tin bác sĩ",
                            "Lịch sử thanh toán",
                            "Ẩn lịch hẹn"
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
                                    });
                                break;
                              case "Thay đổi hình thức Tư vấn":
                                if (widget.status == "Completed") {
                                  showOptionDialog(
                                      context,
                                      "Lỗi",
                                      "Cuộc hẹn đã hoàn thành. Không thể thay đổi.",
                                      "HUỶ",
                                      "OK", () {
                                    Navigator.of(context).pop();
                                  });
                                } else {
                                  showChangeConsultationDialog(context,
                                      widget.appointment_id, widget.isOnline);
                                }

                                break;
                              case "Thông tin bác sĩ":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorDetailScreen(
                                        doctorId: widget.doctor_id),
                                  ),
                                );
                                break;
                              case "Lịch sử thanh toán":
                                showPaymentHistoryDialog(
                                  context,
                                  widget.appointment_id,
                                );

                                break;
                              case "Ẩn lịch hẹn":
                                showOptionDialog(
                                    context,
                                    "Xác nhận",
                                    "Bạn có chắc muốn ẩn lịch hẹn này không?",
                                    "Huỷ",
                                    "Ẩn",
                                    hideAppointment);
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
                              NetworkImage(doctorProfile['avatar_url']),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Row(
                      children: [
                        widget.status == "Completed"
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReviewDoctorScreen(
                                                reviewId: widget.review_id,
                                                appointmentId:
                                                    widget.appointment_id,
                                                doctorId: widget.doctor_id)),
                                  );
                                },
                                child: Container(
                                  width: screenWidth * 0.2,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.01,
                                      vertical: screenWidth * 0.01),
                                  decoration: BoxDecoration(
                                    color: widget.review_id != ""
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
                        SizedBox(width: screenWidth * 0.05),
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
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
