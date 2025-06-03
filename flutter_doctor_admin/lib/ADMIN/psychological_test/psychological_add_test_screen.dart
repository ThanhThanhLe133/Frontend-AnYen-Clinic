import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/psychological_test/psychological_add_questions_screen.dart';
import 'dart:convert';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';

class PsychologicalAddTestScreen extends StatefulWidget {
  const PsychologicalAddTestScreen({super.key});

  @override
  State<PsychologicalAddTestScreen> createState() =>
      _PsychologicalAddTestScreenState();
}

class _PsychologicalAddTestScreenState
    extends State<PsychologicalAddTestScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<dynamic> newTest = [];

  Future<String?> createTest(String name) async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/test',
        method: 'POST', // sửa từ DELETE sang POST
        body: {"name": name},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final testId = data['newQuestionSet']['test_id'];
        return testId;
      } else {
        throw Exception('Lỗi khi tạo bài kiểm tra.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo bài kiểm tra.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
          "Thêm bài kiểm tra",
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
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên bài kiểm tra',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Nhập tên bài kiểm tra',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
            SizedBox(height: 25),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final description = "";

                  if (title.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Thiếu thông tin'),
                        content: Text(
                          'Vui lòng nhập đầy đủ tên và mô tả bài kiểm tra.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  final testId = await createTest(title);

                  if (testId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PsychologicalAddQuestionsScreen(testId: testId),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Thêm câu hỏi',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
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
