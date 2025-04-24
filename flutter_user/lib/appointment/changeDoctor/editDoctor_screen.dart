import 'dart:async';
import 'dart:convert';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/appointment/changeDoctor/changeDoctor_screen.dart';
import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/payment/PaymentOptionWidget.dart';
import 'package:anyen_clinic/provider/patient_provider.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/DoctorCard.dart';

class EditDoctorScreen extends ConsumerStatefulWidget {
  const EditDoctorScreen(
      {super.key, required this.doctorId, this.totalPaid, this.appointmentId});
  final String doctorId;
  final String? totalPaid;
  final String? appointmentId;
  @override
  ConsumerState<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends ConsumerState<EditDoctorScreen> {
  Map<String, dynamic> doctorProfile = {};
  late String totalPaid;
  late String appointmentId;
  double totalPrice = 0;
  StreamSubscription? _linkSub;
  final AppLinks _appLinks = AppLinks();

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

  Future<void> editPayment() async {
    if (ref.read(doctorIdProvider) == widget.doctorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không có thông tin thay đổi")),
      );
    }
    if (totalPrice == 0) {
      try {
        final response = await makeRequest(
            url: '$apiUrl/patient/edit-appointment',
            method: 'PATCH',
            body: {
              "appointment_id": appointmentId,
              "doctor_id": widget.doctorId,
            });

        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          showSuccessDialog(
              context, AppointmentScreen(), "Thay đổi thành công", "QUay lại");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['mes'] ?? "Lỗi sửa lịch hẹn")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xảy ra lỗi: $e")),
        );
      }
    } else {
      try {
        final response = await makeRequest(
            url: '$apiUrl/payment/create-payment-momo',
            method: 'PATCH',
            body: {
              "appointment_id": appointmentId,
              "doctor_id": widget.doctorId,
              "total_price": totalPrice,
            });

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['payUrl'] != null) {
          final payUrl = data['payUrl'];
          if (await canLaunchUrl(Uri.parse(payUrl))) {
            await launchUrl(Uri.parse(payUrl),
                mode: LaunchMode.externalApplication);
          } else {
            throw "Không thể mở đường dẫn thanh toán.";
          }
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

  @override
  void initState() {
    super.initState();
    fetchDoctor();
    if (widget.totalPaid != null) {
      ref.read(totalPaidProvider.notifier).state = widget.totalPaid!;
    }
    if (widget.appointmentId != null) {
      ref.read(paymentIdProvider.notifier).state = widget.appointmentId!;
    }
    appointmentId = ref.read(paymentIdProvider)!;
    totalPaid = ref.read(totalPaidProvider)!;
    totalPrice = doctorProfile['price'] - totalPaid;

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
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSelected = true;
    return StatefulBuilder(builder: (context, setState) {
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
            "Sửa bác sĩ",
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
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bác sĩ tư vấn hiện tại",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    DoctorCard(
                      doctorName: doctorProfile['name'],
                      specialty: doctorProfile['specialization'],
                      imageUrl: doctorProfile['avatar_url'],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeDoctorScreen(
                                    doctorId: widget.doctorId)),
                          );
                        },
                        child: Text(
                          'Đổi bác sĩ',
                          style: TextStyle(
                            color: Color(0xFF119CF0),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Phí tư vấn",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40494F))),
                    Text(
                      "${doctorProfile['price']} đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đã thanh toán",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF40494F))),
                    Text(
                      "${widget.totalPaid} đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Thanh toán thêm",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40494F))),
                    Text(
                      "${doctorProfile['price'] - totalPaid} đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
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
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hình thức thanh toán",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PaymentOptionWidget(
                            text: "Momo",
                            isMoMo: true,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                        PaymentOptionWidget(
                            text: "Chuyển khoản ngân hàng",
                            isMoMo: false,
                            isSelected: !isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: editPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenWidth * 0.02),
                ),
                child: Text("CẬP NHẬT",
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.04)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
