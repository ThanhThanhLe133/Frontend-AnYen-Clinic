import 'dart:convert';

import 'package:anyen_clinic/doctor/listReview_doctor_screen.dart';
import 'package:anyen_clinic/review/ReviewList.dart';
import 'package:anyen_clinic/review/reviewCard_widget.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/descriptionText.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorDetail extends StatefulWidget {
  final String doctorId;
  const DoctorDetail({super.key, required this.doctorId});

  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> {
  Map<String, dynamic> doctorProfile = {};

  Future<void> fetchDoctor() async {
    String doctorId = widget.doctorId;
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
    fetchDoctor();
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
          "Thông tin bác sĩ",
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
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: doctorProfile.isEmpty
          ? Center(
              child: SpinKitWaveSpinner(
                color: Colors.blue, // Bạn đổi màu tùy ý
                size: 75.0, // Size cũng chỉnh theo ý
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.18,
                    backgroundImage: NetworkImage(doctorProfile['avatar_url']),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        doctorProfile['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Chuyên khoa: ${doctorProfile["specialization"]}',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: null,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04, color: Colors.grey),
                      ),
                      Text(
                        doctorProfile['workplace'],
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: null,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04, color: Colors.grey),
                      ),
                      Text(
                        softWrap: true,
                        maxLines: null,
                        doctorProfile['infoStatus'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    margin: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.1), // Bóng đậm hơn một chút
                          blurRadius: 7, // Mở rộng bóng ra xung quanh
                          spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                          offset:
                              Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoTile(
                            'Lượt tư vấn',
                            '${doctorProfile['appointment_count']}+',
                            Icons.people,
                            screenHeight,
                            screenWidth),
                        Container(
                          width: 1,
                          height: screenHeight * 0.07,
                          color: Colors.black.withOpacity(0.25),
                        ),
                        _infoTile(
                            'Kinh nghiệm',
                            '${doctorProfile['yearExperience']} năm',
                            Icons.history,
                            screenHeight,
                            screenWidth),
                        Container(
                          width: 1,
                          height: screenHeight * 0.07,
                          color: Colors.black.withOpacity(0.25),
                        ),
                        _infoTile('Hài lòng', '100%', Icons.thumb_up,
                            screenHeight, screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      sectionTitle(
                          title: 'Đánh giá của khách hàng',
                          screenHeight: screenHeight,
                          screenWidth: screenWidth),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            bottom: screenHeight * 0.01),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListReviewDoctorScreen(
                                        doctorId: widget.doctorId,
                                      )),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Xem thêm',
                                style: TextStyle(
                                  color: Color(0xFF119CF0),
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ReviewList(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      doctorId: widget.doctorId),
                  sectionTitle(
                    title: 'Quá trình công tác',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  descriptionText(
                    doctorProfile['workExperience'],
                    screenHeight,
                    screenWidth,
                  ),
                  sectionTitle(
                    title: 'Quá trình học tập',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  descriptionText(
                    doctorProfile['educationHistory'],
                    screenHeight,
                    screenWidth,
                  ),
                  sectionTitle(
                    title: 'Chứng chỉ hành nghề',
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                  descriptionText(
                    doctorProfile['medicalLicense'],
                    screenHeight,
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon,
      double screenHeight, double screenWidth) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: screenWidth * 0.035, color: Color(0xFF40494F)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenWidth * 0.05, color: Colors.blue),
            SizedBox(width: screenWidth * 0.02),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
