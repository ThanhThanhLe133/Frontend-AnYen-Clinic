import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/dashboard_admin/dashboard.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ReviewDoctorScreen extends StatefulWidget {
  const ReviewDoctorScreen({
    super.key,
    required this.reviewId,
    required this.appointmentId,
    required this.doctorId,
  });
  final String reviewId;
  final String appointmentId;
  final String doctorId;

  @override
  State<ReviewDoctorScreen> createState() => _ReviewDoctorScreenState();
}

class _ReviewDoctorScreenState extends State<ReviewDoctorScreen> {
  Map<String, dynamic> doctorProfile = {};
  Map<String, dynamic> review = {};
  Future<void> fetchDoctor() async {
    String doctorId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-doctor/?userId=$doctorId',
      method: 'GET',
    );
    if (response.statusCode != 200) {
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

  Future<void> fectchReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
      url: '$apiUrl/review/get-review/?review_id=$reviewId',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        review = data['data'];
      });
    }
  }

  Future<void> hideReview() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/hide-review',
      method: 'PATCH',
      body: {"appointment_id": widget.appointmentId},
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tạo dữ liệu.")));
    } else {
      showSuccessDialog(
        context,
        AppointmentScreen(),
        "Ẩn đánh giá thành công",
        "Tới lịch hẹn",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDoctor();
      await fectchReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Đánh giá bác sĩ",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body:
          doctorProfile.isEmpty
              ? Center(
                child: SpinKitWaveSpinner(
                  color: Colors.blue, // Bạn đổi màu tùy ý
                  size: 75.0, // Size cũng chỉnh theo ý
                ),
              )
              : Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.11,
                              backgroundImage: NetworkImage(
                                doctorProfile['avatar_url'],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctorProfile['name'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Chuyên khoa: ${doctorProfile["specialization"]}',
                                    softWrap: true,
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    doctorProfile['workplace'],
                                    softWrap: true,
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Text(
                          doctorProfile['infoStatus'],
                          softWrap: true,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SatisfactionWidget(
                        screenWidth: screenWidth,
                        rating:
                            review.isNotEmpty ? review['rating'] : 'Undefault',
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: TextEditingController(
                          text: review['comment'] ?? '',
                        ),
                        readOnly: true,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        maxLines: null,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Color(0xFFD9D9D9),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.03,
                            horizontal: screenWidth * 0.02,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.2),
                      normalButton(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        label: "Ẩn đánh giá",
                        action: hideReview,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

int selectedIndex = 0;
int _getIndexForRating(String rating) {
  switch (rating) {
    case 'Very pleased':
      return 0;
    case 'Pleased':
      return 1;
    case 'Normal':
      return 2;
    case 'Unpleased':
      return 3;
    default:
      return 0;
  }
}

String _getStringForRating(int index) {
  switch (index) {
    case 0:
      return 'Very pleased';
    case 1:
      return 'Pleased';
    case 2:
      return 'Normal';
    case 3:
      return 'Unpleased';
    default:
      return 'Very pleased';
  }
}

class SatisfactionWidget extends StatefulWidget {
  const SatisfactionWidget({
    super.key,
    required this.screenWidth,
    required this.rating,
  });
  final double screenWidth;
  final String rating;
  @override
  State<SatisfactionWidget> createState() => _SatisfactionWidgetState();
}

class _SatisfactionWidgetState extends State<SatisfactionWidget> {
  final List<Map<String, dynamic>> options = [
    {"label": "Rất hài lòng", "emoji": "😍", "color": Colors.blue},
    {"label": "Hài lòng", "emoji": "😊", "color": Colors.blue},
    {"label": "Bình thường", "emoji": "😐", "color": Colors.blue},
    {"label": "Không hài lòng", "emoji": "☹️", "color": Colors.blue},
  ];
  @override
  void initState() {
    super.initState();

    selectedIndex = _getIndexForRating(widget.rating);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(options.length, (index) {
          bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: widget.screenWidth * 0.2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? options[index]['color'] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: widget.screenWidth * 0.1,
                      child: Text(
                        options[index]['label'],
                        style: TextStyle(
                          fontSize: widget.screenWidth * 0.03,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color.fromARGB(221, 19, 4, 4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: widget.screenWidth * 0.08,
                      child: Text(
                        options[index]['emoji'] ?? '❓',
                        style: TextStyle(fontSize: widget.screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
