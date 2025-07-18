import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/message/message_screen.dart';
import 'package:ayclinic_doctor_admin/Provider/historyConsultProvider.dart';
import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DashboardAdmin extends ConsumerStatefulWidget {
  const DashboardAdmin({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<DashboardAdmin> {
  bool isOnline = true;
  Map<String, dynamic> admin = {};
  DateTime? _lastBackPressed;
  List<Map<String, dynamic>> appointments = [];
  late int totalAppointmentsThisMonth = 0;
  late int connectingAppointment = 0;
  late int connectingMessage = 0;
  late int onlineAppointment = 0;
  late int offlineAppointment = 0;

  Future<void> fetchAppointment() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/get-all-appointments',
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
        appointments =
            List<Map<String, dynamic>>.from(data['data']).where((appointment) {
          return appointment['status'] != 'Canceled' &&
              appointment['status'] != 'Unpaid';
        }).toList();

        final now = DateTime.now();

        //tổng số ca tư vấn trong tháng
        final currentMonthAppointments = appointments.where((appointment) {
          final time = appointment['appointment_time'];
          if (time is DateTime) {
            return time.month == now.month && time.year == now.year;
          }
          return false;
        }).toList();

        totalAppointmentsThisMonth = currentMonthAppointments.length;
        //số ca tư vấn online
        onlineAppointment = appointments
            .where((appointment) => appointment['appointment_type'] == "Online")
            .toList()
            .length;

        //số ca tư vấn offline
        onlineAppointment = appointments
            .where(
                (appointment) => appointment['appointment_type'] == "Offline")
            .toList()
            .length;
        //số ca tư vấn đang kết nối
        final currentConnectingAppointments = appointments.where((appointment) {
          return appointment['status'] == 'Pending' ||
              appointment['status'] == 'Unpaid';
        }).toList();

        connectingAppointment = currentConnectingAppointments.length;

        //số tin nhắn đang chờ
      });
      ref.read(onlineAppointmentProvider.notifier).setValue(onlineAppointment);
      ref
          .read(offlineAppointmentProvider.notifier)
          .setValue(offlineAppointment);
    }
  }

  Future<void> changeStatus(bool value) async {
    final response = await makeRequest(
      url: '$apiUrl/auth/change-active-status',
      method: 'PATCH',
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Trạng thái đã được cập nhật!")));
    } else {
      throw Exception('Không thể thay đổi trạng thái');
    }
  }

  Future<void> fetchProfile() async {
    final response = await makeRequest(url: '$apiUrl/get/user', method: 'GET');
    final responseData = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseData['mes'])));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        admin = data['data'];
        isOnline = admin['is_active'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
      fetchAppointment();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > Duration(seconds: 5)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nhấn back lần nữa để trở về đăng nhập")),
          );
          return false; // CHẶN pop
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return false; // Trả false để không pop tiếp Dashboard
      },
      child: admin.isEmpty
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
                          admin['name'],
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
                            color: isOnline
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
                                inactiveThumbColor: Colors.grey,
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
              floatingActionButton: MenuAdmin(),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: RadialBarChart(
                          screenWidth: screenWidth,
                          year: DateTime.now().year,
                          month: DateTime.now().month,
                          onlineAppointment: onlineAppointment,
                          offlineAppointment: offlineAppointment,
                        ),
                      ),
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
                            totalAppointmentsThisMonth.toString(),
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
                                    '$connectingAppointment',
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
