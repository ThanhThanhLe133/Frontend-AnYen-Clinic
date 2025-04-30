import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/ReviewListMini.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/add_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/descriptionText.dart';
import 'package:ayclinic_doctor_admin/widget/infoTitle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'listReview_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/widget/reviewCard_widget.dart';
import 'package:ayclinic_doctor_admin/widget/consultationBottomBar.dart';
import 'package:ayclinic_doctor_admin/widget/sectionTitle.dart';

class DetailsDoctorScreen extends StatefulWidget {
  final String doctorId;
  const DetailsDoctorScreen({super.key, required this.doctorId});

  @override
  State<DetailsDoctorScreen> createState() => _DetailsDoctorScreenState();
}

class _DetailsDoctorScreenState extends State<DetailsDoctorScreen> {
  bool isOnline = true;
  Map<String, dynamic> doctorProfile = {};

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDoctor();
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
        leading: CustomBackButton(),
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
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body:
          doctorProfile.isEmpty
              ? Center(
                child: SpinKitWaveSpinner(color: Colors.blue, size: 75.0),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: screenWidth * 0.03,
                          height: screenWidth * 0.03,
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                doctorProfile['isActive']
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                        ),
                        Text(
                          doctorProfile['isActive']
                              ? 'Đang online'
                              : 'Đang offline',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color:
                                doctorProfile['isActive']
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: screenWidth * 0.18,
                      backgroundImage: NetworkImage(
                        doctorProfile['avatar_url'],
                      ),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Chuyên khoa: ${doctorProfile["specialization"]}',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          doctorProfile['workplace'],
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          softWrap: true,
                          maxLines: null,
                          doctorProfile['infoStatus'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
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
                            color: Colors.black.withOpacity(
                              0.1,
                            ), // Bóng đậm hơn một chút
                            blurRadius: 7, // Mở rộng bóng ra xung quanh
                            spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                            offset: Offset(
                              0,
                              0,
                            ), // Không dịch chuyển, bóng tỏa đều
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
                            screenWidth: screenWidth,
                          ),
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
                            screenWidth: screenWidth,
                          ),
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
                            screenWidth: screenWidth,
                          ),
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
                          screenWidth: screenWidth,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            bottom: screenHeight * 0.01,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ListReviewDoctorScreen(
                                        doctorId: widget.doctorId,
                                      ),
                                ),
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
                    ReviewListMini(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      doctorId: widget.doctorId,
                    ),

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
      bottomNavigationBar: ConsultationBottomBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        content: "Chi phí tư vấn",
        totalMoney: '${doctorProfile['price']}',
        nameButton: "SỬA THÔNG TIN",
        nextScreen: AddDoctorScreen(doctorId: widget.doctorId),
      ),
    );
  }
}
