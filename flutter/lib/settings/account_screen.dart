import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anyen_clinic/patient_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    final patientData = ref.watch(patientProvider);

    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    String? savedText;
    bool isEditing = false;

    patientData.when(
      data: (patient) {
        savedText = patient?['anonymous_name'] as String?;
        controller.text = savedText ?? ''; // Cập nhật giá trị vào TextField
      },
      loading: () => {},
      error: (error, stackTrace) => {},
    );

    void onEditingComplete() {
      setState(() {
        savedText = controller.text;
        isEditing = false;
      });
      focusNode.unfocus();
    }

    void onCancelEdit() {
      setState(() {
        controller.text = savedText ?? '';
        isEditing = false;
      });
      focusNode.unfocus();
    }

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
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: patientData.when(
          data: (patient) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  constraints: BoxConstraints(
                      minHeight: screenHeight * 0.3,
                      minWidth: screenWidth * 0.9),
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
                                child: Icon(Icons.person,
                                    color: Colors.white,
                                    size: screenWidth * 0.1),
                              ),
                              Positioned(
                                bottom: -10,
                                right: 2,
                                child: Container(
                                  width: screenWidth * 0.06,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.add,
                                        color: Colors.white,
                                        size: screenWidth * 0.05),
                                    onPressed: () {
                                      // Xử lý khi nhấn nút Add
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
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
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                patient?['phone_number'] ?? '0123456789',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Tên ẩn danh",
                            style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: screenHeight * 0.03),
                          IconButton(
                            icon: Icon(
                              Icons.info,
                              color: Colors.blue,
                              size: screenWidth * 0.06,
                            ),
                            onPressed: () {
                              _showInfoDialog(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1),
                          ),
                          hintText: "Nhập tên ẩn danh của bạn",
                          hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03,
                              horizontal: screenWidth * 0.02),
                          suffixIcon: isEditing
                              ? IconButton(
                                  icon: Icon(Icons.cancel,
                                      size: screenWidth * 0.05,
                                      color: Colors.red),
                                  onPressed: onCancelEdit,
                                )
                              : Icon(Icons.arrow_forward_ios,
                                  size: screenWidth * 0.05),
                        ),
                        onTap: () {
                          if (!isEditing) {
                            setState(() {
                              isEditing = true;
                            });
                            focusNode.requestFocus();
                          }
                          focusNode.requestFocus();
                        },
                        onEditingComplete: onEditingComplete,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: sectionTitle(
                      title: 'Tài khoản của bạn',
                      screenHeight: screenHeight,
                      screenWidth: screenWidth),
                ),
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
                      SettingsMenu(
                        label: "Hồ sơ y tế",
                        icon: Icons.article,
                        iconColor: Colors.blue,
                        action: () => print("Hồ sơ y tế"),
                      ),
                      SettingsMenu(
                        label: "Đổi mật khẩu",
                        icon: Icons.lock,
                        iconColor: Colors.blueAccent,
                        action: () => print("Đổi mật khẩu"),
                      ),
                      SettingsMenu(
                        label: "Cài đặt thông báo",
                        icon: Icons.notifications,
                        iconColor: Colors.amber,
                        action: () => print("Cài đặt thông báo"),
                      ),
                      SettingsMenu(
                        label: "Về chúng tôi",
                        icon: Icons.groups,
                        iconColor: Colors.green,
                        action: () => print("Về chúng tôi"),
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
                SizedBox(
                  height: screenHeight * 0.02,
                ),
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
                  child: Text("Tôi đã hiểu",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsMenu extends StatelessWidget {
  final String label;
  final VoidCallback action;
  final IconData icon;
  final Color iconColor;

  const SettingsMenu({
    super.key,
    required this.label,
    required this.action,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: screenWidth * 0.07),
      title: Text(
        label,
        style:
            TextStyle(fontSize: screenWidth * 0.045, color: Color(0xFF40494F)),
      ),
      trailing: SizedBox(
        width: 40,
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.chevron_right,
            color: Color(0xFF9BA5AC),
            size: screenWidth * 0.08,
          ),
        ),
      ),
      onTap: action,
    );
  }
}
