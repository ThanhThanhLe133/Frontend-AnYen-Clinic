import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/message/message_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dialog/InputPrescription.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/menu_doctor.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardDoctor extends ConsumerStatefulWidget {
  const DashboardDoctor({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<DashboardDoctor> {
  bool isOnline = true;
  Map<String, dynamic> doctor = {};

  Future<void> changeStatus(bool value) async {
    final response = await makeRequest(
      url: '$apiUrl/auth/change-active-status',
      method: 'PATCH',
    );
    if (response.statusCode == 200) {
      setState(() {
        isOnline = value;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Trạng thái đã được cập nhật!")));
    } else {
      throw Exception('Không thể thay đổi trạng thái');
    }
  }

  Future<void> fetchProfile() async {
    final response = await makeRequest(url: '$apiUrl/get/user', method: 'GET');
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        doctor = data['data'];
        isOnline = doctor['is_active'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          setState(() {});
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Nhấn back lần nữa để thoát")));
          SystemNavigator.pop();
        }
      },
      child:
          doctor.isEmpty
              ? Center(
                child: SpinKitWaveSpinner(color: Colors.blue, size: 75.0),
              )
              : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào",
                            style: TextStyle(
                              color: Color(0xFF9BA5AC),
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            doctor['name'],
                            style: TextStyle(
                              color: Color(0xFF119CF0),
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Row(
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: isOnline ? Colors.green : Color(0xFF40494F),
                            size: screenWidth * 0.04,
                          ),
                          Text(
                            isOnline ? "Trực tuyến" : "Ngoại tuyến",
                            style: TextStyle(
                              color:
                                  isOnline
                                      ? Colors.green
                                      : Color(
                                        0xFF40494F,
                                      ), // Đổi màu dựa trên isOnline
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            child: Center(
                              child: Transform.scale(
                                scale: screenWidth / 600,
                                child: Switch(
                                  value: isOnline,
                                  onChanged: (value) async {
                                    setState(() {
                                      isOnline = value;
                                    });
                                    await changeStatus(value);
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                ),
                floatingActionButton: MenuDoctor(),
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Center(child: RadialBarChart(screenWidth: screenWidth)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tổng số ca tư vấn trong tháng:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                                color: Color(0xFF949FA6),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              "15",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF119CF0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.05),
                        Container(
                          width: screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFFD9D9D9),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ListTile(
                                leading: null,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Lịch hẹn đang kết nối: ",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Color(0xFF40494F),
                                      ),
                                    ),
                                    Text(
                                      "02 ",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        color: Color(0xFF119CF0),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 10,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF9BA5AC),
                                      size: screenWidth * 0.08,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppointmentScreen(),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: null,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tin nhắn chưa kết thúc: ",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Color(0xFF40494F),
                                      ),
                                    ),
                                    Text(
                                      "02 ",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        color: Color(0xFF119CF0),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 10,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF9BA5AC),
                                      size: screenWidth * 0.08,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessageScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
