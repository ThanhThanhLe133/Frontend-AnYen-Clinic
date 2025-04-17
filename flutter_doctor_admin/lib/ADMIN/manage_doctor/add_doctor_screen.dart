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

    final body = {
      "phone": phoneController.text.trim(),
      "fullName": nameController.text.trim(),
      "gender": genderController.text.trim(),
      "specialization": specializationController.text.trim(),
      "workplace": workplaceController.text.trim(),
      "yearExperience": yearExperienceController.text.trim(),
      "workExperience": workExperienceController.text.trim(),
      "infoStatus": infoStatusController.text.trim(),
      "educationHistory": educationHistoryController.text.trim(),
      "medicalLicense": medicalLicenseController.text.trim(),
      "price": priceController.text.trim(),
    };

    final Response response;
    var userId = widget.doctorId;
    if (userId != null) {
      response = await makeRequest(
        url: '$apiUrl/admin/edit-doctor/?userId=$userId',
        method: 'POST',
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
    final userId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/admin/upload-avatar-doctor/?userId=$userId',
      method: 'POST',
      file: imageFile,
      fileFieldName: 'avatar',
    );
    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lưu thành công!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi thay đổi avatar!")));
    }
  }

  Future<void> fetchDoctor(String id) async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/get-doctor/?userId=$id',
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
          phoneController.text = doctorProfile['phone_number'];
          nameController.text = doctorProfile['name'];
          genderController.text = doctorProfile['gender'];
          specializationController.text = doctorProfile['specialization'];
          workplaceController.text = doctorProfile['workplace '];
          yearExperienceController.text = doctorProfile['year_experience '];
          workExperienceController.text = doctorProfile['work_experience '];
          infoStatusController.text = doctorProfile['info_status '];
          educationHistoryController.text = doctorProfile['education_history '];
          medicalLicenseController.text = doctorProfile['medical_license '];
          priceController.text = doctorProfile['price'];
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
              fillColor: Colors.white,
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
          "Thêm mới bác sĩ",
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
                          ? NetworkImage(doctorProfile['avatar_url'])
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
                  bottom: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () async {
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
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
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
