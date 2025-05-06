import 'dart:convert';

import 'package:ayclinic_doctor_admin/DOCTOR/settings/about_us_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/settings/change_pass_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/settings/notification_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/SettingsMenu.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/menu_doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Map<String, dynamic> doctor = {};
  Future<void> callLogoutAPI() async {
    final response = await makeRequest(
      url: '$apiUrl/auth/logout',
      method: 'POST',
    );

    if (response.statusCode == 200) {
      await deleteAccessToken();
      await deleteRefreshToken();
      await deleteLogin();
      if (!mounted) return;
      showSuccessDialog(
        context,
        LoginScreen(),
        "Đăng xuất thành công",
        "Đăng nhập",
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng xuất thất bại")));
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
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Tài khoản",
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
      floatingActionButton: MenuDoctor(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.05),
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.3,
                minWidth: screenWidth * 0.9,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFECF8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.1,
                            backgroundColor: Colors.blue[300],
                            backgroundImage:
                                (doctor['avatar_url'] != null &&
                                        doctor['avatar_url']
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(doctor['avatar_url'])
                                    : null,
                            child:
                                (doctor['avatar_url'] == null ||
                                        doctor['avatar_url'].toString().isEmpty)
                                    ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: screenWidth * 0.1,
                                    )
                                    : null,
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'] ?? 'Không có tên',
                            softWrap: true,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor['phone_number'] ?? '0123456789',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),

            Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFD9D9D9), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsMenu(
                    label: "Đổi mật khẩu",
                    icon: Icons.lock,
                    iconColor: Colors.blueAccent,
                    action:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePassScreen(),
                          ),
                        ),
                  ),
                  SettingsMenu(
                    label: "Cài đặt thông báo",
                    icon: Icons.notifications,
                    iconColor: Colors.amber,
                    action:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(),
                          ),
                        ),
                  ),
                  SettingsMenu(
                    label: "Về chúng tôi",
                    icon: Icons.groups,
                    iconColor: Colors.green,
                    action:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.3,
              child: Image.asset("assets/images/logo.png", fit: BoxFit.contain),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'An Yên',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter-Medium',
                color: Color(0xFF1CB6E5),
              ),
            ),
            Text(
              'Nơi cảm xúc được lắng nghe',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Color(0xFFDE8C88),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.3),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: screenWidth * 0.5,
                height: screenWidth * 0.12,
                child: TextButton(
                  onPressed:
                      () => showOptionDialog(
                        context,
                        "Đăng xuất",
                        "Bạn có chắc chắn muốn đăng xuất",
                        "HUỶ",
                        "Đồng ý",
                        () {
                          callLogoutAPI();
                        },
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Color(0xFFF6616A),
                        size: screenWidth * 0.07,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'ĐĂNG XUẤT',
                        style: TextStyle(
                          color: Color(0xFFF6616A),
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
