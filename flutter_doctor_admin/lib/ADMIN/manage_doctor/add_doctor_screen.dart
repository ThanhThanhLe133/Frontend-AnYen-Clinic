import 'dart:convert';
import 'dart:io';

import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/doctor_list_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/settings/account_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/genderDropDown.dart';

import 'package:ayclinic_doctor_admin/widget/normalButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/src/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDoctorScreen extends ConsumerStatefulWidget {
  final String? doctorId;
  const AddDoctorScreen({super.key, this.doctorId});

  @override
  ConsumerState<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends ConsumerState<AddDoctorScreen> {
  Map<String, dynamic> doctorProfile = {};
  late String avatar;
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController genderController = TextEditingController();

  final TextEditingController specializationController =
      TextEditingController();

  final TextEditingController workplaceController = TextEditingController();

  final TextEditingController yearExperienceController =
      TextEditingController();

  final TextEditingController workExperienceController =
      TextEditingController();

  final TextEditingController infoStatusController = TextEditingController();

  final TextEditingController educationHistoryController =
      TextEditingController();

  final TextEditingController medicalLicenseController =
      TextEditingController();

  final TextEditingController priceController = TextEditingController();

  Future<void> onSave() async {
    final controllers = [
      phoneController,
      nameController,
      genderController,
      specializationController,
      workplaceController,
      yearExperienceController,
      workExperienceController,
      infoStatusController,
      educationHistoryController,
      medicalLicenseController,
      priceController,
    ];

    bool hasEmpty = controllers.any(
      (controller) => controller.text.trim().isEmpty,
    );

    if (hasEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vui lòng nhập đầy đủ tất cả các trường thông tin"),
        ),
      );
      return;
    }
    final priceText = priceController.text.trim();
    final yearExpText = yearExperienceController.text.trim();
    if (int.tryParse(priceText) == null || int.tryParse(yearExpText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Giá tiền và số năm kinh nghiệm phải là số hợp lệ."),
        ),
      );
      return;
    }
    final price = int.parse(priceText);
    final yearExperience = int.parse(yearExpText);

    var userId = widget.doctorId;
    final body = {
      "userId": userId,
      "phone": phoneController.text.trim(),
      "name": nameController.text.trim(),
      "gender": genderController.text.trim() == "Nữ" ? "female" : "male",
      "specialization": specializationController.text.trim(),
      "workplace": workplaceController.text.trim(),
      "yearExperience": yearExperience,
      "workExperience": workExperienceController.text.trim(),
      "infoStatus": infoStatusController.text.trim(),
      "educationHistory": educationHistoryController.text.trim(),
      "medicalLicense": medicalLicenseController.text.trim(),
      "price": price,
    };

    final Response response;

    if (userId != null) {
      response = await makeRequest(
        url: '$apiUrl/admin/edit-doctor',
        method: 'PATCH',
        body: body,
      );
    } else {
      response = await makeRequest(
        url: '$apiUrl/admin/create-doctor',
        method: 'POST',
        body: body,
      );
    }
    if (response.statusCode == 200) {
      showSuccessDialog(
        context,
        DoctorListScreen(),
        "Lưu thành công",
        "Quay lại",
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lưu thất bại: ${response.body}")));
    }
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
    try {
      final userId = widget.doctorId;
      final response = await makeRequest(
        url: '$apiUrl/admin/upload-avatar-doctor',
        method: 'POST',
        body: {"userId": userId},
        file: imageFile,
        fileFieldName: 'avatar',
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          avatar = jsonDecode(response.body)['avatarUrl'];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lưu thành công!")));
      } else {
        print('xxxxxxxxxxxxxx ${response.statusCode}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi thay đổi avatar!")));
      }
    } catch (e) {
      debugPrint("Lỗi khi upload ảnh: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi không mong muốn.")));
    }
  }

  Future<void> fetchDoctor(String id) async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/get/get-doctor/?userId=$id',
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
        doctorProfile = data['data'];

        setState(() {
          avatar = doctorProfile['avatar_url'];
          phoneController.text = doctorProfile['phoneNumber'];
          nameController.text = doctorProfile['name'];
          genderController.text =
              doctorProfile['gender'] == "male" ? "Nam" : "Nữ";
          specializationController.text = doctorProfile['specialization'];
          workplaceController.text = doctorProfile['workplace'];
          yearExperienceController.text =
              doctorProfile['yearExperience'].toString();
          workExperienceController.text = doctorProfile['workExperience'];
          infoStatusController.text = doctorProfile['infoStatus'];
          educationHistoryController.text = doctorProfile['educationHistory'];
          medicalLicenseController.text = doctorProfile['medicalLicense'];
          priceController.text = doctorProfile['price'].toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.doctorId != null) {
        fetchDoctor(widget.doctorId!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    priceController.dispose();
    medicalLicenseController.dispose();
    educationHistoryController.dispose();
    infoStatusController.dispose();
    workExperienceController.dispose();
    yearExperienceController.dispose();
    workplaceController.dispose();
    workplaceController.dispose();
    specializationController.dispose();
    genderController.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget buildTextField(
      String label,
      TextEditingController controller, {
      bool isRequired = true,
      int maxLines = 1,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(color: Colors.black, fontSize: 14),
              children:
                  isRequired
                      ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                      : [],
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            maxLines: maxLines,
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

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
          widget.doctorId != null ? "Sửa bác sĩ" : "Thêm mới bác sĩ",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE0E0E0),
                  backgroundImage:
                      (doctorProfile['avatar_url'] != null &&
                              doctorProfile['avatar_url'].toString().isNotEmpty)
                          ? NetworkImage(avatar)
                          : null,
                  child:
                      (doctorProfile['avatar_url'] == null ||
                              doctorProfile['avatar_url'].toString().isEmpty)
                          ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: screenWidth * 0.1,
                          )
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                      onPressed: () async {
                        if (widget.doctorId != null) {
                          PermissionStatus statusCamera =
                              await Permission.camera.request();
                          if (statusCamera.isGranted) {
                            await _pickAndUploadImage();
                          } else if (statusCamera.isPermanentlyDenied) {
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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Vui lòng tạo bác sĩ trước"),
                              duration: Duration(seconds: 1),
                            ),
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
            const SizedBox(height: 20),
            buildTextField("Tên", nameController, isRequired: true),
            buildTextField("Số điện thoại", phoneController, isRequired: true),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    "Chuyên khoa",
                    specializationController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Giới tính',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      GenderDropdown(controller: genderController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildTextField(
              "Nơi công tác hiện tại",
              workplaceController,
              isRequired: true,
            ),
            buildTextField("Châm ngôn", infoStatusController, maxLines: 2),
            buildTextField(
              "Số năm kinh nghiệm",
              yearExperienceController,
              maxLines: 1,
            ),
            buildTextField(
              "Quá trình công tác",
              workExperienceController,
              maxLines: 2,
            ),
            buildTextField(
              "Quá trình học tập",
              educationHistoryController,
              maxLines: 2,
            ),
            buildTextField("Số chứng chỉ hành nghề", medicalLicenseController),
            buildTextField("Chi phí tư vấn", priceController, isRequired: true),
            const SizedBox(height: 16),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Lưu",
              action: () => onSave(),
            ),
          ],
        ),
      ),
    );
  }
}
