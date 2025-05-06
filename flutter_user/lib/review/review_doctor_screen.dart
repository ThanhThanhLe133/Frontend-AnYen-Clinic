import 'dart:convert';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/normalButton.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ReviewDoctorScreen extends StatefulWidget {
  const ReviewDoctorScreen(
      {super.key,
      required this.reviewId,
      required this.appointmentId,
      required this.doctorId});
  final String reviewId;
  final String appointmentId;
  final String doctorId;

  @override
  State<ReviewDoctorScreen> createState() => _ReviewDoctorScreenState();
}

class _ReviewDoctorScreenState extends State<ReviewDoctorScreen> {
  Map<String, dynamic> doctorProfile = {};
  Map<String, dynamic> review = {};
  TextEditingController controller = TextEditingController();
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
        controller.text = review['comment'];
      });
    }
  }

  Future<void> createReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
        url: '$apiUrl/review/create-review',
        method: 'POST',
        body: {
          "appointment_id": widget.appointmentId,
          "comment": controller.text.trim(),
          "rating": _getStringForRating(selectedIndex)
        });

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tạo dữ liệu.")));
    } else {
      showSuccessDialog(context, AppointmentScreen(), "Tạo đánh giá thành công",
          "Tới lịch hẹn");
    }
  }

  Future<void> editReview() async {
    final response = await makeRequest(
        url: '$apiUrl/review/edit-review',
        method: 'PATCH',
        body: {
          "appointment_id": widget.appointmentId,
          "comment": controller.text.trim(),
          "rating": _getStringForRating(selectedIndex)
        });

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tạo dữ liệu.")));
    } else {
      showSuccessDialog(context, AppointmentScreen(), "Sửa đánh giá thành công",
          "Tới lịch hẹn");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchDoctor();
      if (widget.reviewId != "") {
        await fectchReview();
      } else {
        controller.text = "";
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.02),
                      child: Text(
                        doctorProfile['infoStatus'],
                        softWrap: true,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Vui lòng dành ít phút cho chúng tôi biết cảm nhận của bạn sau cuộc tư vấn',
                      softWrap: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Color(0xFF949FA6),
                        height: 1.2,
                      ),
                    ),
                    SatisfactionWidget(
                      screenWidth: screenWidth,
                      rating:
                          review.isNotEmpty ? review['rating'] : 'Undefault',
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Chia sẻ thêm với mọi người cảm nhận của bạn",
                      maxLines: null,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Color(0xFF40494F)),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      controller: controller,
                      style: TextStyle(fontSize: screenWidth * 0.04),
                      maxLines: null,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                        hintText:
                            "Chia sẻ cảm nhận của bạn về buổi tư vấn cùng bác sĩ.\n",
                        hintStyle: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Color(0xFFD9D9D9),
                            fontWeight: FontWeight.w400),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.03,
                            horizontal: screenWidth * 0.02),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.2),
                    normalButton(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        label: widget.reviewId != ""
                            ? "Sửa đánh giá"
                            : "Gửi đánh giá",
                        action:
                            widget.reviewId != "" ? editReview : createReview,
                        nextScreen: LoginScreen())
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
  const SatisfactionWidget(
      {super.key, required this.screenWidth, required this.rating});
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
          vertical: widget.screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(options.length, (index) {
          bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                height: widget.screenWidth * 0.2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? options[index]['color'] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 5)
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
                          color: isSelected
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
