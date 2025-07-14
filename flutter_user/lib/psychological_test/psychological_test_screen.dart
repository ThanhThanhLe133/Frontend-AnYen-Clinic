import 'dart:convert';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:flutter/material.dart';
import 'psychological_test_home_screen.dart';

class PsychologicalTestScreen extends StatefulWidget {
  final String title; // <-- Giữ lại để có thể tùy chỉnh tiêu đề nếu cần
  final String testId;
  const PsychologicalTestScreen(
      {super.key, this.title = "Bài kiểm tra", required this.testId});

  @override
  _PsychologicalTestScreenState createState() =>
      _PsychologicalTestScreenState();
}

class _PsychologicalTestScreenState extends State<PsychologicalTestScreen> {
  int currentQuestionIndex = 0; // Bắt đầu từ câu hỏi đầu tiên (index 0)
  int selectedAnswerIndex = -1; // Chưa chọn câu trả lời nào
  List<dynamic> questions = [];
  List<Map<String, String>> selectedAnswers = [];
  late String testId;

  Future<void> fetchQuestions() async {
    final response = await makeRequest(
      url: '$apiUrl/patient/test/$testId',
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
    }
  }

  // Hàm cập nhật câu trả lời
  void onAnswerSelected(int index) {
    setState(() {
      selectedAnswerIndex = index;

      String questionId = questions[currentQuestionIndex]['question_id'];
      String answerId =
          questions[currentQuestionIndex]['answers'][index]['answer_id'];

      // Cập nhật hoặc thêm vào selectedAnswers
      int existingIndex = selectedAnswers
          .indexWhere((item) => item['question_id'] == questionId);
      if (existingIndex != -1) {
        selectedAnswers[existingIndex]['answer_id'] = answerId;
      } else {
        selectedAnswers.add({
          'question_id': questionId,
          'answer_id': answerId,
        });
      }
    });
  }

  // Hàm xử lý chuyển câu hỏi tiếp theo
  void nextQuestion() {
    if (selectedAnswerIndex != -1 &&
        currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = -1; // Đặt lại câu trả lời khi chuyển câu hỏi mới
      });
    }
  }

  // Hàm xử lý quay lại câu hỏi trước
  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        // Có thể muốn khôi phục câu trả lời đã chọn trước đó nếu lưu trữ,
        // nhưng hiện tại reset lại giống nextQuestion
        selectedAnswerIndex = -1;
      });
    }
  }

  // Hàm xử lý hoàn thành
  Future<void> completeTest() async {
    if (selectedAnswerIndex == -1) return;

    try {
      final response = await makeRequest(
        url: '$apiUrl/patient/test/submit-answers',
        method: 'POST',
        body: {
          'test_id': testId,
          'answers': selectedAnswers,
        },
      );

      if (response.statusCode == 201) {
        // Thành công
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hoàn thành bài kiểm tra"),
              content: Text("Bạn đã hoàn thành bài kiểm tra tâm lý."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PsychologicalTestHomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Lỗi khi gửi câu trả lời');
      }
    } catch (e) {
      print("Lỗi gửi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi bài kiểm tra.')),
      );
    }
  }

  void _handleNextOrComplete() {
    if (selectedAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn một câu trả lời.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (currentQuestionIndex < questions.length - 1) {
      nextQuestion();
    } else {
      completeTest();
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
    bool canGoForward = selectedAnswerIndex != -1; // Có thể đi tiếp nếu đã chọn

    if (questions.isEmpty) {
      return Scaffold(
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
            maxLines: null,
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // Bỏ bottom border
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          widget.title, // Sử dụng title được truyền vào hoặc mặc định
          style: TextStyle(
            color: Color(0xFF007AFF), // Màu xanh dương giống ảnh
            fontSize: screenWidth * 0.055, // Cỡ chữ title điều chỉnh
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Nền AppBar trắng
        // Bỏ bottom border
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 15.0), // Padding tổng thể
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa các thành phần con
          children: [
            // Hướng dẫn
            Text(
              'Hãy đọc kỹ từng nhóm câu và chọn một câu mô tả đúng nhất về cảm xúc của bạn trong hai tuần qua',
              textAlign: TextAlign.center, // Căn giữa text hướng dẫn
              style: TextStyle(
                fontSize: screenWidth * 0.04, // Cỡ chữ hướng dẫn
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Thanh điều hướng Trước/Sau và Tiến độ
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Phân bố đều không gian
              children: [
                // Nút Trước
                OutlinedButton(
                  onPressed: canGoBack
                      ? previousQuestion
                      : null, // Disable nếu là câu đầu
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        canGoBack ? Colors.black54 : Colors.grey[300],
                    side: BorderSide(
                        color: canGoBack
                            ? Colors.grey
                            : Colors.grey[300]!), // Màu viền
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Bo góc nhẹ
                    ),
                  ),
                  child: Text('Trước'),
                ),

                // Tiến độ
                Text(
                  '${currentQuestionIndex + 1}/${questions.length}', // Hiển thị tiến độ dạng x/y
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Nút Sau (hoạt động giống FAB)
                OutlinedButton(
                  onPressed: _handleNextOrComplete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isLastQuestion && canGoForward
                        ? Colors.green
                        : canGoForward
                            ? Colors.black54
                            : Colors.grey[300],
                    side: BorderSide(
                      color: isLastQuestion && canGoForward
                          ? Colors.green
                          : canGoForward
                              ? Colors.grey
                              : Colors.grey[300]!,
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

            // Container chứa câu hỏi
            Container(
              width: double.infinity, // Chiếm hết chiều ngang
              padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 15.0), // Padding bên trong container
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5), // Viền đen
                borderRadius: BorderRadius.circular(15.0), // Bo góc nhiều hơn
              ),
              child: Text(
                questions[currentQuestionIndex]['question_text'],
                textAlign: TextAlign.center, // Căn giữa text câu hỏi
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Cỡ chữ câu hỏi
                  fontWeight: FontWeight.w600, // Hơi đậm hơn
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Các câu trả lời (dùng Container thay vì RadioListTile)
            Expanded(
              // Sử dụng Expanded để các câu trả lời chiếm không gian còn lại
              child: ListView.builder(
                // Dùng ListView để có thể scroll nếu không đủ chỗ
                itemCount: questions[currentQuestionIndex]['answers'].length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedAnswerIndex == index;
                  String answerText = questions[currentQuestionIndex]['answers']
                      [index]['answer_text'];
                  return GestureDetector(
                    onTap: () => onAnswerSelected(index),
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 15.0), // Khoảng cách giữa các câu trả lời
                      padding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                          horizontal: 15.0), // Padding bên trong
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF007AFF).withOpacity(0.3)
                            : Color(0xFFE0F2FE), // Màu nền khác nhau khi chọn
                        borderRadius:
                            BorderRadius.circular(12.0), // Bo góc câu trả lời
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF007AFF)
                              : Colors.transparent, // Viền xanh khi được chọn
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        answerText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Cỡ chữ câu trả lời
                          color: isSelected
                              ? Colors.black
                              : Colors.black87, // Màu chữ khi chọn
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Spacer(), // Bỏ Spacer và các nút cũ ở dưới
          ],
        ),
      ),
      // Floating Action Button ở góc dưới phải
    );
  }
}
