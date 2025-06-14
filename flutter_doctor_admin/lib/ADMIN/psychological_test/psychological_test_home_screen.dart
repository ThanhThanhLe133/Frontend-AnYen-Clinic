import 'package:ayclinic_doctor_admin/widget/QuestionCardInList.dart';
import 'package:flutter/material.dart';
import 'psychological_review_screen.dart';
import 'psychological_add_test_screen.dart';
import 'dart:convert';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';

class PsychologicalTestHomeScreen extends StatefulWidget {
  const PsychologicalTestHomeScreen({super.key});

  @override
  State<PsychologicalTestHomeScreen> createState() =>
      _PsychologicalTestHomeScreenState();
}

class _PsychologicalTestHomeScreenState
    extends State<PsychologicalTestHomeScreen> {
  List<dynamic> questionSets = [];

  Future<void> fetchTest() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/test/all-test', // Đúng URL API bạn có
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      setState(() {
        questionSets = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách trắc nghiệm")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTest();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
          "Trắc nghiệm tâm lý",
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.05,
        ),
        child: ListView.builder(
          itemCount: questionSets.length,
          itemBuilder: (context, index) {
            final question = questionSets[index];
            // return QuestionCardInList(
            //   screenWidth: screenWidth,
            //   screenHeight: screenHeight,
            //   title: question['title'] ?? '',
            //   questionCount: question['questionCount'] ?? '',
            //   description: question['description'] ?? '',
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => PsychologicalTestScreen(
            //           title: question['title'] ?? '',
            //         ),
            //       ),
            //     );
            //   },
            // );
            return QuestionCardInList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: question['test_name'] ?? 'Không có tiêu đề',
              testId: question['test_id'].toString(),
              questionCount: '${question['total_questions']} câu hỏi',
              description: '',
              onPressed: () {
                final testId = question['test_id']?.toString() ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PsychologicalTestScreen(
                      title: question['test_name'] ?? 'Bài kiểm tra',
                      testId: testId,
                    ),
                  ),
                );
              },
              onDeleted: () => setState(() {
                questionSets.removeAt(index);
              }),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Floating Action Button Pressed");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PsychologicalAddTestScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(), // Đảm bảo hình tròn rõ ràng
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white, // Dấu + màu trắng
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
