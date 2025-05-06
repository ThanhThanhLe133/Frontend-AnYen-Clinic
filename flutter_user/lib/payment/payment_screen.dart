import 'dart:async';
import 'dart:convert';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/payment/PaymentOptionWidget.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/DoctorCard.dart';
import 'package:anyen_clinic/widget/consultationBottomBar.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  const PaymentScreen({super.key, required this.doctorId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic> doctorProfile = {};
  final TextEditingController questionController = TextEditingController();
  late List<DateTime> dates;
  late int selectedDateIndex;
  late int selectedTimeIndex;
  late DateTime selectedDate = DateTime.now();

  int total_price = 0;

  String selectedConsult = "Online";
  String selectedPayment = "MoMo";
  DateTime initialDate = DateTime.now();
  final List<String> times = [
    "9:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00"
  ];
  late String selectedHour = times[0];
  StreamSubscription? _linkSub;
  final AppLinks _appLinks = AppLinks();
  late ScrollController _scrollController;

  void _generateInitialDates() {
    dates = List.generate(7, (index) => initialDate.add(Duration(days: index)));
  }

  void _loadMoreDates() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        DateTime lastDate = dates.last;
        for (int i = 1; i <= 7; i++) {
          dates.add(lastDate.add(Duration(days: i)));
        }
      });
    }
  }

  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Mở trong trình duyệt ngoài
    } else {
      throw 'Không thể mở URL: $url';
    }
  }

  Future<void> createPayment() async {
    final parts = selectedHour.split(':');
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final appointmentTime = combinedDateTime.toIso8601String();
    debugPrint(appointmentTime);

    try {
      final response = await makeRequest(
          url: '$apiUrl/payment/create-payment-momo',
          method: 'POST',
          body: {
            "doctor_id": widget.doctorId,
            "appointment_time": appointmentTime,
            "question": questionController.text.trim(),
            "appointment_type": selectedConsult,
            "total_price": total_price,
          });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['payUrl'] != null) {
        final payUrl = data['payUrl'];
        openUrl(payUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi tạo thanh toán")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: $e")),
      );
    }
  }

  Future<void> checkPayment(String orderId) async {
    try {
      final response = await makeRequest(
          url: '$apiUrl/payment/check-payment-status',
          method: 'POST',
          body: {"orderId": orderId});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['err'] == 0) {
        showSuccessDialog(context, AppointmentScreen(), "Thanh toán thành công",
            "Tới lịch hẹn");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Không thành công")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi: $e")),
      );
    }
  }

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
        total_price = doctorProfile['price'];
      });
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    _linkSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchDoctor();
    _scrollController = ScrollController()..addListener(_loadMoreDates);
    _generateInitialDates();

    selectedDateIndex = 0;
    selectedTimeIndex = times.indexOf(selectedHour);

    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'myapp') {
        final orderId = uri.queryParameters['orderId'];
        if (orderId != null) {
          checkPayment(orderId); // Gọi check trạng thái từ backend
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Thanh toán",
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
                color: Colors.blue,
                size: 75.0,
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.question_mark,
                          size: screenWidth * 0.05,
                          color: Colors.blue,
                        ),
                        Text(
                          "Câu hỏi sẽ được gửi đến",
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF40494F)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    DoctorCard(
                      doctorName: doctorProfile['name'],
                      specialty: doctorProfile['specialization'],
                      imageUrl: doctorProfile['avatar_url'],
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenWidth * 0.02),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hình thức thanh toán",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PaymentOptionWidget(
                                  text: "Momo",
                                  value: "MoMo",
                                  selectedPayment: selectedPayment,
                                  isMoMo: true,
                                  onTap: () {
                                    setState(() {
                                      selectedPayment = "MoMo";
                                    });
                                  },
                                  screenWidth: screenWidth),
                              PaymentOptionWidget(
                                  text: "Chuyển khoản ngân hàng",
                                  isMoMo: false,
                                  value: "Banking",
                                  selectedPayment: selectedPayment,
                                  onTap: () {
                                    setState(() {
                                      selectedPayment = "Banking";
                                    });
                                  },
                                  screenWidth: screenWidth),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.02),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hình thức tư vấn",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: _buildOption(Icons.chat_rounded,
                                    "Online", selectedConsult, () {
                                  setState(() {
                                    selectedConsult = "Online";
                                  });
                                }, screenWidth),
                              ),
                              SizedBox(
                                child: _buildOption(Icons.people_alt_rounded,
                                    "Offline", selectedConsult, () {
                                  setState(() {
                                    selectedConsult = "Offline";
                                  });
                                }, screenWidth),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.02),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Đặt lịch tư vấn",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Scrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Row(
                                children: List.generate(dates.length, (index) {
                                  DateTime date = dates[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDateIndex = index;
                                        selectedDate = date;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02),
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenWidth * 0.01,
                                          horizontal: screenWidth * 0.02),
                                      decoration: BoxDecoration(
                                        color: selectedDateIndex == index
                                            ? Colors.blue[50]
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            date.weekday == 1
                                                ? "CN"
                                                : "T${date.weekday}",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: screenWidth * 0.02),
                                          Text(
                                            "${date.day}/${date.month}", // Ngày/Tháng
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Divider(height: 1),
                          SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: List.generate(times.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTimeIndex = index;
                                      selectedHour = times[index];
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenWidth * 0.02,
                                        horizontal: screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: selectedTimeIndex == index
                                          ? Colors.blue[50]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      times[index],
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    QuestionField(
                      screenWidth: screenWidth,
                      controller: questionController,
                    ),
                    Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.02),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chi tiết thanh toán",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "1 lượt tư vấn",
                                style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Color(0xFFDB5B8B)),
                              ),
                              Text(formatCurrency(total_price.toString()),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: ConsultationBottomBar(
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        content: "Tổng tiền",
        totalMoney: total_price.toString(),
        nameButton: "THANH TOÁN",
        action: createPayment,
      ),
    );
  }
}

class QuestionField extends StatelessWidget {
  const QuestionField(
      {super.key, required this.screenWidth, required this.controller});

  final double screenWidth;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Bóng đậm hơn một chút
            blurRadius: 7, // Mở rộng bóng ra xung quanh
            spreadRadius: 1, // Kéo dài bóng theo mọi hướng
            offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liên hệ tư vấn",
            style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Color(0xFF40494F)),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            style: TextStyle(fontSize: screenWidth * 0.04),
            maxLines: null,
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              hintText: "Nhập câu hỏi và triệu chứng bạn muốn tư vấn.\n",
              hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Color(0xFFD9D9D9),
                  fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.03, horizontal: screenWidth * 0.02),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

Widget _buildOption(IconData icon, String text, String selectedConsult,
    VoidCallback onTap, double screenWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: screenWidth / 500,
          child: Radio<String>(
            value: text, // Giá trị của option này
            groupValue: selectedConsult, // Giá trị được chọn
            onChanged: (_) => onTap(), // Khi chọn thì gọi onTap
            activeColor: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Icon(
          icon,
          color: Colors.blue,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(text,
            maxLines: null,
            softWrap: true,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            )),
      ],
    ),
  );
}
