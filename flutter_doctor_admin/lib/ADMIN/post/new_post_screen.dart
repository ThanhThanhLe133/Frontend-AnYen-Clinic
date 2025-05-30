import 'package:ayclinic_doctor_admin/DOCTOR/post/list_post_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessScreen.dart';
import 'package:ayclinic_doctor_admin/dialog/showSuccess.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key, this.title, this.content, this.postId});
  final String? title;
  final String? content;
  final String? postId;
  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> submitPost() async {
    final content = contentController.text.trim();
    final title = titleController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ tiêu đề và nội dung.")),
      );
      return;
    }

    final response = await makeRequest(
        url: '$apiUrl/doctor/create-post',
        method: 'POST',
        body: {"title": title, "content": content});

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tạo dữ liệu.")));
    } else {
      showSuccessDialog(
          context, ListPostScreen(), "Thành công", "Tới danh sách bài viết");
    }
  }

  Future<void> savePost() async {
    final content = contentController.text.trim();
    final title = titleController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ tiêu đề và nội dung.")),
      );
      return;
    }

    final response = await makeRequest(
        url: '$apiUrl/doctor/edit-post',
        method: 'POST',
        body: {"title": title, "content": content});

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tạo dữ liệu.")));
    } else {
      showSuccessDialog(context, ListPostScreen(), "Sửa thành công",
          "Tới danh sách bài viết");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.title != null && widget.content != null) {
      titleController.text = widget.title!;
      contentController.text = widget.content!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          widget.title != null ? "Sửa bài viết" : "Tạo bài viết mới",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.06,
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
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề bài viết'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Content input
              TextFormField(
                controller: contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'Nội dung bài viết',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập nội dung'
                    : null,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.postId == null ? submitPost : savePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lưu bài viết',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
