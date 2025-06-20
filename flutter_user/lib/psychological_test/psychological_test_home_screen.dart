import 'dart:convert';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/psychological_test/psychological_test_result_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/QuestionCardInList.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:flutter/material.dart';
import 'psychological_test_screen.dart';

class PsychologicalTestHomeScreen extends StatefulWidget {
  const PsychologicalTestHomeScreen({super.key});

  @override
  State<PsychologicalTestHomeScreen> createState() =>
      _QuestionListScreenState();
}

class _QuestionListScreenState extends State<PsychologicalTestHomeScreen> {
  List<dynamic> questionSets = [];
  List<dynamic> questionSetAnswered = [];

  Future<void> fetchQuestions() async {
    final response = await makeRequest(
      url: '$apiUrl/patient/test',
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
        SnackBar(content: Text("Không thể tải danh sách trắc nghiệm chưa làm")),
      );
    }

    final responseAnswered = await makeRequest(
      url: '$apiUrl/patient/test/results', // Đúng URL API bạn có
      method: 'GET',
    );
    if (responseAnswered.statusCode == 200) {
      final data = jsonDecode(responseAnswered.body);
      print(responseAnswered.body);
      setState(() {
        questionSetAnswered = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách trắc nghiệm đã làm")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchQuestions();
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
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: Menu(),
      // body: Padding(
      //   padding: EdgeInsets.symmetric(
      //       horizontal: screenWidth * 0.05, vertical: screenWidth * 0.05),
      //   child: ListView.builder(
      //     itemCount: questionSets.length,
      //     itemBuilder: (context, index) {
      //       final question = questionSets[index];
      //       return QuestionCardInList(
      //         screenWidth: screenWidth,
      //         screenHeight: screenHeight,
      //         title: question['test_name'] ?? 'Không có tiêu đề',
      //         testId: question['test_id'].toString(),
      //         isComplete:
      //             false, // nếu chưa có backend check, tạm thời cho false
      //         questionCount: '${question['total_questions']} câu hỏi',
      //         buttonText: 'LÀM',
      //         description: '',
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) {
      //                 // Kiểm tra dữ liệu từ question và đảm bảo rằng test_id tồn tại
      //                 final String testId = question['test_id'] != null
      //                     ? question['test_id'].toString()
      //                     : '';
      //
      //                 // Kiểm tra xem testId có hợp lệ không
      //                 if (testId.isEmpty) {
      //                   // Nếu testId không hợp lệ, hiển thị thông báo lỗi hoặc xử lý thêm
      //                   return Scaffold(
      //                     body: Center(child: Text('Lỗi: testId không hợp lệ')),
      //                   );
      //                 }
      //
      //                 return PsychologicalTestScreen(
      //                   title: question['test_name'] ??
      //                       'Bài kiểm tra', // Sử dụng test_name hoặc mặc định
      //                   testId: testId, // Truyền testId hợp lệ
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //       );
      //     },
      //   ),
      // ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: ListView(
          children: [
            const Text("📝 Bài kiểm tra chưa làm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            questionSets.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Chưa có bài kiểm tra nào.',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: questionSets.length,
                    itemBuilder: (context, index) {
                      final question = questionSets[index];
                      return QuestionCardInList(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: question['test_name'] ?? 'Không có tiêu đề',
                        testId: question['test_id'].toString(),
                        isComplete: false,
                        questionCount: '${question['total_questions']} câu hỏi',
                        buttonText: 'LÀM',
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
                      );
                    },
                  ),
            const SizedBox(height: 20),
            const Text("✅ Bài kiểm tra đã hoàn thành",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            questionSetAnswered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Chưa làm bài kiểm tra nào.',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: questionSetAnswered.length,
                    itemBuilder: (context, index) {
                      final question = questionSetAnswered[index];
                      return QuestionCardInList(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: question['test_name'] ?? 'Không có tiêu đề',
                        testId: question['test_id'].toString(),
                        isComplete: true,
                        questionCount: '${question['total_questions']} câu hỏi',
                        buttonText: 'XEM LẠI',
                        description: 'Đã hoàn thành',
                        onPressed: () {
                          final testId = question['test_id']?.toString() ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PsychologicalTestResultScreen(
                                title: question['test_name'] ?? 'Bài kiểm tra',
                                testId: testId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
