import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final String authorName = "Bác sĩ An Yên"; // Gán mặc định hoặc lấy từ user
  final String currentTime = DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now());

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      final newPost = {
        'title': _titleController.text,
        'author': authorName,
        'postedTime': currentTime,
        'content': _contentController.text,
      };

      print('📤 New Post Submitted: $newPost');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài viết đã được tạo thành công!')),
      );

      Navigator.pop(context);
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
          "Tạo bài viết mới",
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
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề bài viết'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Author display
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: Colors.grey[700]),
                  SizedBox(width: 6),
                  Text(
                    authorName,
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              // Time display
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.grey[700]),
                  SizedBox(width: 6),
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Content input
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'Nội dung bài viết',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đăng bài viết',
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
