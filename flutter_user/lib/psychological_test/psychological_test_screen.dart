import 'package:flutter/material.dart';
import 'psychological_test_home_screen.dart';

class PsychologicalTestScreen extends StatefulWidget {
  final String title; // <-- Giữ lại để có thể tùy chỉnh tiêu đề nếu cần

  // Sửa lại title mặc định hoặc truyền từ bên ngoài khi gọi Widget này
  const PsychologicalTestScreen(
      {super.key, this.title = "Bài kiểm tra trầm cảm"});

  @override
  _PsychologicalTestScreenState createState() =>
      _PsychologicalTestScreenState();
}

class _PsychologicalTestScreenState extends State<PsychologicalTestScreen> {
  int currentQuestionIndex = 0; // Bắt đầu từ câu hỏi đầu tiên (index 0)
  int selectedAnswerIndex = -1; // Chưa chọn câu trả lời nào

  // ***** THÊM DỮ LIỆU CÂU HỎI ĐỂ ĐỦ 6 CÂU *****
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Tâm trạng buồn bã',
      'answers': [
        'Tôi không cảm thấy buồn',
        'Thỉnh thoảng tôi cảm thấy buồn',
        'Tôi thường xuyên buồn và khó thoát khỏi cảm giác đó',
        'Tôi luôn buồn bã và không thể chịu đựng nổi',
      ],
    },
    {
      'question': 'Cảm giác bi quan',
      'answers': [
        'Tôi không hề bi quan về tương lai',
        'Tôi cảm thấy bi quan về tương lai hơn trước đây',
        'Tôi không trông đợi điều gì tốt đẹp sẽ đến với mình',
        'Tôi cảm thấy tương lai vô vọng và mọi thứ sẽ không thể cải thiện',
      ],
    },
    {
      'question': 'Cảm giác thất bại',
      'answers': [
        'Tôi không cảm thấy mình là người thất bại',
        'Tôi đã thất bại nhiều hơn những người khác',
        'Nhìn lại cuộc đời, tôi thấy mình có quá nhiều thất bại',
        'Tôi cảm thấy mình là một người hoàn toàn thất bại',
      ],
    },
    {
      'question': 'Mất hứng thú',
      'answers': [
        'Tôi vẫn có được sự thích thú như trước đây',
        'Tôi không còn thích thú mọi thứ như trước đây',
        'Tôi không còn thấy thích thú với bất cứ điều gì nữa',
        'Tôi hoàn toàn không hài lòng và chán nản với mọi thứ',
      ],
    },
    {
      'question': 'Cảm giác tội lỗi',
      'answers': [
        'Tôi không cảm thấy có lỗi đặc biệt',
        'Tôi cảm thấy có lỗi về nhiều điều tôi đã làm hoặc lẽ ra nên làm',
        'Tôi cảm thấy khá tội lỗi trong phần lớn thời gian',
        'Tôi cảm thấy cực kỳ tội lỗi mọi lúc',
      ],
    },
    {
      'question': 'Ý nghĩ tự tử',
      'answers': [
        'Tôi không có bất kỳ ý nghĩ nào về việc tự làm hại bản thân',
        'Tôi có những ý nghĩ về việc tự làm hại bản thân, nhưng tôi sẽ không thực hiện chúng',
        'Tôi muốn tự tử',
        'Tôi sẽ tự tử nếu có cơ hội',
      ],
    },
    // Đảm bảo có đủ 6 câu hỏi
  ];

  // Hàm cập nhật câu trả lời
  void onAnswerSelected(int index) {
    setState(() {
      selectedAnswerIndex = index;
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
  void completeTest() {
    if (selectedAnswerIndex == -1)
      return; // Chưa chọn câu trả lời cuối thì chưa hoàn thành
    // Có thể lưu kết quả hoặc làm gì đó khi hoàn thành bài kiểm tra
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hoàn thành bài kiểm tra",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.blue)),
          backgroundColor: Colors.white,
          content: Text(
            "Bạn đã hoàn thành bài kiểm tra tâm lý.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PsychologicalTestHomeScreen()),
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
    if (selectedAnswerIndex == -1) {
      // Optional: Hiển thị thông báo yêu cầu chọn câu trả lời
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLastQuestion = currentQuestionIndex == questions.length - 1;
    bool canGoBack = currentQuestionIndex > 0;
    bool canGoForward = selectedAnswerIndex != -1; // Có thể đi tiếp nếu đã chọn

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
                questions[currentQuestionIndex]['question'],
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
                        questions[currentQuestionIndex]['answers'][index],
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
