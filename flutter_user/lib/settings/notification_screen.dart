import 'dart:convert';
import 'dart:math';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/BuildToggleOption.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isDiaries = true;
  bool isAppointments = true;
  bool isMessages = true;
  bool isPayments = true;
  Map<String, dynamic> notiSetting = {};

  Future<void> changeNotiSetting(String type, bool value) async {
    final response = await makeRequest(
        url: '$apiUrl/notification/settings',
        method: 'PUT',
        body: {"notification_type": type, "is_enabled": value});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cài đặt đã được cập nhật!")));
    } else {
      throw Exception('Không thể thay đổi cài đặt');
    }
  }

  Future<void> fetchSettingNoti() async {
    final response =
        await makeRequest(url: '$apiUrl/notification/settings', method: 'GET');
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      final settings = data['data'] as List<dynamic>;

      setState(() {
        notiSetting = {
          for (var setting in settings) setting['type']: setting['is_enabled']
        };
        isDiaries = notiSetting['diaries'];
        isAppointments = notiSetting['appointments'];
        isMessages = notiSetting['messages'];
        isPayments = notiSetting['payments'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSettingNoti();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

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
          "Cài đặt thông báo",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color(0xFFD9D9D9),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  BuildToggleOption(
                    screenWidth: screenWidth,
                    icon: Icons.article,
                    title: "Nhật ký",
                    value: isDiaries,
                    onChanged: (value) async {
                      setState(() => isDiaries = value);
                      await changeNotiSetting("diaries", value);
                    },
                  ),
                  BuildToggleOption(
                    screenWidth: screenWidth,
                    icon: Icons.people_alt_rounded,
                    title: "Lịch hẹn",
                    value: isAppointments,
                    onChanged: (value) async {
                      setState(() => isAppointments = value);
                      await changeNotiSetting("appointments", value);
                    },
                  ),
                  BuildToggleOption(
                    screenWidth: screenWidth,
                    icon: Icons.notifications,
                    title: "Tin nhắn",
                    value: isMessages,
                    onChanged: (value) async {
                      setState(() => isMessages = value);
                      await changeNotiSetting("messages", value);
                    },
                  ),
                  BuildToggleOption(
                    screenWidth: screenWidth,
                    icon: Icons.payment,
                    title: "Thanh toán",
                    value: isPayments,
                    onChanged: (value) async {
                      setState(() => isPayments = value);
                      await changeNotiSetting("payments", value);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
