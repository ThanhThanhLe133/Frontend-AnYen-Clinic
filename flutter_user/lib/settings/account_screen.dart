import 'dart:convert';
import 'dart:io';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/settings/about_us_screen.dart';
import 'package:anyen_clinic/settings/change_pass_screen.dart';
import 'package:anyen_clinic/settings/medical_records_screen.dart';
import 'package:anyen_clinic/settings/notification_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/SettingsMenu.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final savedTextProvider = StateProvider<String?>((ref) => null);
final isEditingProvider = StateProvider<bool>((ref) => false);

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  Map<String, dynamic> patientProfile = {};

  void onEditingComplete() {
    ref.read(savedTextProvider.notifier).state = controller.text;
    ref.read(isEditingProvider.notifier).state = false;
    focusNode.unfocus();
  }

  void onSave() {
    final anonymousName = controller.text;
    showOptionDialog(context, "Lưu tên ẩn danh",
        "Bạn có chắc chắn muốn lưu tên ẩn danh này?", "HUỶ", "Đồng ý", () {
      saveAnonymousName(anonymousName);
    });

    ref.read(isEditingProvider.notifier).state = false;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    } else {
      print('No image selected');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final response = await makeRequest(
      url: '$apiUrl/patient/upload/avatar',
      method: 'POST',
      file: imageFile,
      fileFieldName: 'avatar',
    );
    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thành công!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );
    } else {
      if (!mounted) return;
      debugPrint("⚠️ Error message from API: $response");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thay đổi avatar!")),
      );
    }
  }

  Future<void> saveAnonymousName(String anonymousName) async {
    final response = await makeRequest(
        url: '$apiUrl/patient/edit-anonymousName',
        method: 'PATCH',
        body: {
          "anonymousName": anonymousName,
        });
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ref.read(savedTextProvider.notifier).state = anonymousName;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thành công!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );
    } else {
      throw Exception(responseData["message"] ?? "Lỗi đổi mật khẩu");
    }
  }

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
          context, LoginScreen(), "Đăng xuất thành công", "Đăng nhập");
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng xuất thất bại")),
      );
    }
  }

  Future<void> fetchProfile() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-patient-profile/',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu.")),
      );
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        patientProfile = data['data'];
        final anonymousName = patientProfile['anonymous_name'];
        if (anonymousName != null && anonymousName.toString().isNotEmpty) {
          controller.text = anonymousName;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fetchProfile();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    final savedText = ref.watch(savedTextProvider);
    final isEditing = ref.watch(isEditingProvider);
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
      floatingActionButton: Menu(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: patientProfile.isEmpty
            ? Center(
                child: SpinKitWaveSpinner(
                  color: Colors.blue,
                  size: 75.0,
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
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
                                    backgroundColor: Colors.blue[300],
                                    backgroundImage:
                                        (patientProfile['avatar_url'] != null &&
                                                patientProfile['avatar_url']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                patientProfile['avatar_url'])
                                            : null,
                                    child:
                                        (patientProfile['avatar_url'] == null ||
                                                patientProfile['avatar_url']
                                                    .toString()
                                                    .isEmpty)
                                            ? Icon(Icons.person,
                                                color: Colors.white,
                                                size: screenWidth * 0.1)
                                            : null,
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
                                        onPressed: () async {
                                          PermissionStatus statusCamera =
                                              await Permission.camera.request();
                                          if (statusCamera.isGranted) {
                                            await _pickAndUploadImage();
                                          } else if (statusCamera
                                              .isPermanentlyDenied) {
                                            showOptionDialog(
                                              context,
                                              "Cần quyền truy cập Camera",
                                              "Vui lòng cấp quyền camera trong cài đặt để sử dụng tính năng này.",
                                              "HỦY",
                                              "CÀI ĐẶT",
                                              () {
                                                openAppSettings();
                                              },
                                            );
                                          } else {
                                            showOptionDialog(
                                              context,
                                              "An yên muốn truy cập camera",
                                              "Cho phép truy cập camera để chụp hình toa thuốc",
                                              "TỪ CHỐI",
                                              "OK",
                                              () async {
                                                await _pickAndUploadImage();
                                              },
                                            );
                                          }
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
                                    (patientProfile['fullname'] != null &&
                                            patientProfile['fullname']
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                        ? patientProfile['fullname']
                                        : 'Không có tên',
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.055,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    (patientProfile['phone_number'] != null)
                                        ? patientProfile['phone_number']
                                        : '',
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
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 1),
                              ),
                              hintText:
                                  (patientProfile['anonymous_name'] == null ||
                                          patientProfile['anonymous_name']
                                              .toString()
                                              .isEmpty)
                                      ? 'Nhập tên ẩn danh của bạn'
                                      : null,
                              hintStyle:
                                  TextStyle(fontSize: screenWidth * 0.04),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.03,
                                  horizontal: screenWidth * 0.02),
                              suffixIcon: isEditing
                                  ? IconButton(
                                      icon: Icon(Icons.save,
                                          size: screenWidth * 0.05,
                                          color: Colors.green),
                                      onPressed: onSave,
                                    )
                                  : Icon(Icons.arrow_forward_ios,
                                      size: screenWidth * 0.05),
                            ),
                            onTap: () {
                              if (!isEditing) {
                                ref.read(isEditingProvider.notifier).state =
                                    true;

                                final newText = patientProfile['anonymous_name']
                                        ?.toString() ??
                                    '';
                                ref.read(savedTextProvider.notifier).state =
                                    newText;
                                controller.text = newText;
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
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MedicalRecordsScreen())),
                          ),
                          SettingsMenu(
                            label: "Đổi mật khẩu",
                            icon: Icons.lock,
                            iconColor: Colors.blueAccent,
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePassScreen())),
                          ),
                          SettingsMenu(
                            label: "Cài đặt thông báo",
                            icon: Icons.notifications,
                            iconColor: Colors.amber,
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationScreen())),
                          ),
                          SettingsMenu(
                            label: "Về chúng tôi",
                            icon: Icons.groups,
                            iconColor: Colors.green,
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutUsScreen())),
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
                          onPressed: () => showOptionDialog(
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
