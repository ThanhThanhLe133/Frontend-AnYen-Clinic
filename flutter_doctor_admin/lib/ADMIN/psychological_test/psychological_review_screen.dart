import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PsychologicalTestScreen extends StatefulWidget {
  final String title;
  final String testId;

  const PsychologicalTestScreen(
      {super.key, this.title = "Bài kiểm tra trầm cảm", required this.testId});

  @override
  _PsychologicalTestScreenState createState() =>
      _PsychologicalTestScreenState();
}

class _PsychologicalTestScreenState extends State<PsychologicalTestScreen> {
  int currentQuestionIndex = 0;
  List<dynamic> questions = [];
  late String testId;

  Future<void> fetchQuestions() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/test/$testId', // URL trả về JSON như bạn gửi
      method: 'GET',
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải câu hỏi.")),
      );
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        questions = data; // Gán thẳng danh sách
      });
      print(response.body);
    }
  }

  // Hàm xử lý chuyển câu hỏi tiếp theo
  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  // Hàm xử lý quay lại câu hỏi trước
  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    testId = widget.testId; // Gán giá trị testId từ widget cha
    fetchQuestions(); // Gọi hàm tải câu hỏi
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLastQuestion = currentQuestionIndex == questions.length - 1;
    bool canGoBack = currentQuestionIndex > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black54),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: questions.isEmpty
          ? Center(
              child: SpinKitWaveSpinner(
                color: const Color.fromARGB(255, 72, 166, 243),
                size: 75.0,
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hãy đọc kỹ từng nhóm câu và chọn một câu mô tả đúng nhất về cảm xúc của bạn trong hai tuần qua',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: canGoBack ? previousQuestion : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              canGoBack ? Colors.black54 : Colors.grey[300],
                          side: BorderSide(
                            color: canGoBack ? Colors.grey : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Trước'),
                      ),
                      Text(
                        '${currentQuestionIndex + 1}/${questions.length}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (isLastQuestion) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Hoàn thành'),
                                  content: Text(
                                    'Bạn đã review xong bài trắc nghiệm tâm lý này.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Đóng dialog
                                        Navigator.of(
                                          context,
                                        ).pop(); // Quay lại màn hình trước (nếu muốn)
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            nextQuestion();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isLastQuestion ? Colors.green : Colors.black54,
                          side: BorderSide(
                            color: isLastQuestion ? Colors.green : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(isLastQuestion ? 'Hoàn thành' : 'Sau'),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 15.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      questions[currentQuestionIndex]['question_text'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Danh sách các đáp án
                  Column(
                    children: List.generate(
                      questions[currentQuestionIndex]['answers'].length,
                      (index) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            questions[currentQuestionIndex]['answers'][index]
                                ['answer_text'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.043,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Không hiển thị các câu trả lời nữa
                ],
              ),
            ),
    );
  }
}
