import 'dart:convert';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:flutter/material.dart';
import 'psychological_test_home_screen.dart';

class PsychologicalTestResultScreen extends StatefulWidget {
  final String title; // <-- Giữ lại để có thể tùy chỉnh tiêu đề nếu cần
  final String testId;
  const PsychologicalTestResultScreen(
      {super.key, this.title = "Bài kiểm tra", required this.testId});

  @override
  _PsychologicalTestResultScreenState createState() =>
      _PsychologicalTestResultScreenState();
}

class _PsychologicalTestResultScreenState
    extends State<PsychologicalTestResultScreen> {
  int currentQuestionIndex = 0; // Bắt đầu từ câu hỏi đầu tiên (index 0)
  List<dynamic> questions = [];
  List<Map<String, String>> selectedAnswers = [];
  late String testId;

  Future<void> fetchQuestions() async {
    final response = await makeRequest(
      url:
          '$apiUrl/patient/test/results/${testId}', // URL trả về JSON như bạn gửi
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
  // void onAnswerSelected(int index) {
  //   setState(() {
  //     selectedAnswerIndex = index;
  //
  //     String questionId = questions[currentQuestionIndex]['question_id'];
  //     String answerId =
  //         questions[currentQuestionIndex]['answers'][index]['answer_id'];
  //
  //     // Cập nhật hoặc thêm vào selectedAnswers
  //     int existingIndex = selectedAnswers
  //         .indexWhere((item) => item['question_id'] == questionId);
  //     if (existingIndex != -1) {
  //       selectedAnswers[existingIndex]['answer_id'] = answerId;
  //     } else {
  //       selectedAnswers.add({
  //         'question_id': questionId,
  //         'answer_id': answerId,
  //       });
  //     }
  //   });
  // }

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
        // Có thể muốn khôi phục câu trả lời đã chọn trước đó nếu lưu trữ,
        // nhưng hiện tại reset lại giống nextQuestion
      });
    }
  }

  Future<void> completeTest() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Trở về trang chủ"),
          content: Text("Bạn đã xem lại hết bài kiểm tra tâm lý."),
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
  }

  // Hàm xử lý cho nút FAB hoặc nút "Sau" ở trên
  void _handleNextOrComplete() {
    // if (selectedAnswerIndex == -1) {
    //   // Optional: Hiển thị thông báo yêu cầu chọn câu trả lời
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Vui lòng chọn một câu trả lời.'),
    //       duration: Duration(seconds: 1),
    //     ),
    //   );
    //   return;
    // }
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
    bool canGoForward = currentQuestionIndex <=
        questions.length - 1; // Có thể đi tiếp nếu đã chọn

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0, // Bỏ shadow
          leading: IconButton(
            // Icon back nhỏ hơn một chút và màu khác
            icon: Icon(Icons.chevron_left,
                color: Colors.black54), // Màu icon giống ảnh hơn
            iconSize: screenWidth * 0.08, // Giữ kích thước tương đối
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng như ảnh
      appBar: AppBar(
        elevation: 0, // Bỏ shadow
        leading: IconButton(
          // Icon back nhỏ hơn một chút và màu khác
          icon: Icon(Icons.chevron_left,
              color: Colors.black54), // Màu icon giống ảnh hơn
          iconSize: screenWidth * 0.08, // Giữ kích thước tương đối
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
                  child: Text(isLastQuestion ? 'Trở về' : 'Sau'),
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
                questions[currentQuestionIndex]['question']['question_text'],
                textAlign: TextAlign.center, // Căn giữa text câu hỏi
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Cỡ chữ câu hỏi
                  fontWeight: FontWeight.w600, // Hơi đậm hơn
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF007AFF)
                    .withOpacity(0.3), // Hiển thị như là đã chọn
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Color(0xFF007AFF),
                  width: 1.5,
                ),
              ),
              child: Text(
                questions[currentQuestionIndex]['answer']['answer_text'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // // Các câu trả lời (dùng Container thay vì RadioListTile)
            // Expanded(
            //   // Sử dụng Expanded để các câu trả lời chiếm không gian còn lại
            //   child: ListView.builder(
            //     // Dùng ListView để có thể scroll nếu không đủ chỗ
            //     itemCount: questions[currentQuestionIndex]['answers'].length,
            //     itemBuilder: (context, index) {
            //       bool isSelected = false;
            //       String answerText = questions[currentQuestionIndex]['answers']
            //           [index]['answer_text'];
            //       return GestureDetector(
            //         child: Container(
            //           margin: const EdgeInsets.only(
            //               bottom: 15.0), // Khoảng cách giữa các câu trả lời
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 18.0,
            //               horizontal: 15.0), // Padding bên trong
            //           width: double.infinity,
            //           decoration: BoxDecoration(
            //             color: isSelected
            //                 ? Color(0xFF007AFF).withOpacity(0.3)
            //                 : Color(0xFFE0F2FE), // Màu nền khác nhau khi chọn
            //             borderRadius:
            //                 BorderRadius.circular(12.0), // Bo góc câu trả lời
            //             border: Border.all(
            //               color: isSelected
            //                   ? Color(0xFF007AFF)
            //                   : Colors.transparent, // Viền xanh khi được chọn
            //               width: 1.5,
            //             ),
            //           ),
            //           child: Text(
            //             answerText,
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               fontSize: screenWidth * 0.04, // Cỡ chữ câu trả lời
            //               color: isSelected
            //                   ? Colors.black
            //                   : Colors.black87, // Màu chữ khi chọn
            //               fontWeight:
            //                   isSelected ? FontWeight.w500 : FontWeight.normal,
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            // Spacer(), // Bỏ Spacer và các nút cũ ở dưới
          ],
        ),
      ),
      // Floating Action Button ở góc dưới phải
    );
  }
}
