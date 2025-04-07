import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'package:ayclinic_doctor_admin/ADMIN/settings/about_us_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/settings/change_pass_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/settings/notification_screen.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/SettingsMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  await Future.delayed(Duration(seconds: 1));
  return {'anonymous_name': null};
});

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    final patientData = ref.watch(patientDataProvider);
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
      floatingActionButton: MenuAdmin(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: patientData.when(
            data: (patient) {
              return Column(
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
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: screenWidth * 0.1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient?['full_name'] ?? 'Không có tên',
                                  softWrap: true,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.055,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  patient?['phone_number'] ?? '0123456789',
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
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
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
                        onPressed: () {},
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
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Lỗi: $err")),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                "Tên ẩn danh được dùng để hiển thị khi bạn đánh giá bác sĩ hoặc khi bác sĩ liên lạc, thay vì tên thật.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "An Yên luôn cam kết bảo mật thông tin để bạn có trải nghiệm sử dụng thoải mái, an toàn nhất trên hệ thống.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Tôi đã hiểu",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
