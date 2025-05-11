import 'dart:convert';

import 'package:anyen_clinic/appointment/changeDoctor/details_doctor_change.dart';
import 'package:anyen_clinic/doctor/widget/buttonReview_widget.dart';
import 'package:anyen_clinic/doctor/widget/infoTitle_widget.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/review/ReviewList.dart';
import 'package:anyen_clinic/storage.dart';

import 'package:anyen_clinic/widget/sectionTitle.dart' show sectionTitle;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListReviewDoctorScreen extends StatefulWidget {
  final String doctorId;
  const ListReviewDoctorScreen({super.key, required this.doctorId});

  @override
  State<ListReviewDoctorScreen> createState() => _ListReviewDoctorScreenState();
}

class _ListReviewDoctorScreenState extends State<ListReviewDoctorScreen> {
  Map<String, dynamic> doctorProfile = {};
  List<Map<String, dynamic>> reviews = [];
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

  Future<void> fetchReview() async {
    String doctorId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-reviews/?doctorId=$doctorId',
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
        reviews = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDoctor();
      await fetchReview();
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
          "Đánh giá",
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
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.01),
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
                          backgroundImage:
                              NetworkImage(doctorProfile['avatar_url']),
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
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Chuyên khoa: ${doctorProfile["specialization"]}',
                                softWrap: true,
                                maxLines: null,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey),
                              ),
                              Text(
                                doctorProfile['workplace'],
                                softWrap: true,
                                maxLines: null,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey),
                              ),
                              Text(
                                doctorProfile['infoStatus'],
                                softWrap: true,
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
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
                        infoTitle(
                            title: "Lượt tư vấn",
                            value: '${doctorProfile['appointment_count']}+',
                            icon: Icons.people,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth),
                        Container(
                          width: 1,
                          height: screenHeight * 0.06,
                          color: Colors.black.withOpacity(0.25),
                        ),
                        infoTitle(
                            title: "Kinh nghiệm",
                            value: '${doctorProfile['yearExperience']} năm',
                            icon: Icons.history,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth),
                        Container(
                          width: 1,
                          height: screenHeight * 0.06,
                          color: Colors.black.withOpacity(0.25),
                        ),
                        infoTitle(
                            title: 'Hài lòng',
                            value: '${doctorProfile['averageSatisfaction']}%',
                            icon: Icons.thumb_up,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tỷ lệ hài lòng: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04)),
                      Text('${doctorProfile['averageSatisfaction']}%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.055,
                              color: Colors.blue)),
                      Text(' /${doctorProfile['totalReviews']} lượt đánh giá',
                          style: TextStyle(fontSize: screenWidth * 0.04)),
                    ],
                  ),
                  sectionTitle(
                      title: 'Mức độ hài lòng',
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                  ratingWidget(
                    screenWidth: screenWidth,
                    label: "Rất hài lòng",
                    percentage: calculateVeryPleasedPercentage(reviews),
                  ),
                  ratingWidget(
                    screenWidth: screenWidth,
                    label: "Hài lòng",
                    percentage: calculatePleasedPercentage(reviews),
                  ),
                  ratingWidget(
                    screenWidth: screenWidth,
                    label: "Bình thường",
                    percentage: calculateNormalPercentage(reviews),
                  ),
                  ratingWidget(
                    screenWidth: screenWidth,
                    label: "Không hài lòng",
                    percentage: calculateUnpleasedPercentage(reviews),
                  ),
                  sectionTitle(
                      title: 'Bình luận của khách hàng',
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ButtonReview(
                          label: "Hữu ích",
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                      SizedBox(width: screenWidth * 0.05),
                      ButtonReview(
                          label: "Mới nhất",
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                    ],
                  ),
                  ReviewList(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      doctorId: widget.doctorId),
                ],
              ),
            ),
    );
  }
}

class ratingWidget extends StatelessWidget {
  const ratingWidget(
      {super.key,
      required this.screenWidth,
      required this.label,
      required this.percentage});

  final double screenWidth;
  final String label;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Padding(
        padding: EdgeInsets.only(bottom: screenWidth * 0.01),
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.3,
              child: Text(
                label,
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            SizedBox(
              width: screenWidth * 0.3,
              child: Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.05),
            SizedBox(
              width: screenWidth * 0.1,
              child: Text(
                '$percentage%',
                style: TextStyle(fontSize: screenWidth * 0.035),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
