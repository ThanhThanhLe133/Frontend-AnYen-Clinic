import 'package:flutter/material.dart';
import 'psychological_test_home_screen.dart';

class ViewAnswersScreen extends StatefulWidget {
  final String title; // Tiêu đề màn hình

  const ViewAnswersScreen(
      {super.key, this.title = "Kết quả bài kiểm tra trầm cảm"});

  @override
  _ViewAnswersScreenState createState() => _ViewAnswersScreenState();
}

class _ViewAnswersScreenState extends State<ViewAnswersScreen> {
  int currentQuestionIndex = 0; // Bắt đầu từ câu hỏi đầu tiên (index 0)

  // Dữ liệu câu hỏi và câu trả lời mẫu
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Tâm trạng buồn bã',
      'answers': [
        'Tôi không cảm thấy buồn',
        'Thỉnh thoảng tôi cảm thấy buồn',
        'Tôi thường xuyên buồn và khó thoát khỏi cảm giác đó',
        'Tôi luôn buồn bã và không thể chịu đựng nổi',
      ],
      'selectedAnswerIndex': 2, // Người dùng đã chọn câu trả lời thứ 3
    },
    {
      'question': 'Cảm giác bi quan',
      'answers': [
        'Tôi không hề bi quan về tương lai',
        'Tôi cảm thấy bi quan về tương lai hơn trước đây',
        'Tôi không trông đợi điều gì tốt đẹp sẽ đến với mình',
        'Tôi cảm thấy tương lai vô vọng và mọi thứ sẽ không thể cải thiện',
      ],
      'selectedAnswerIndex': 1, // Người dùng đã chọn câu trả lời thứ 2
    },
    {
      'question': 'Cảm giác thất bại',
      'answers': [
        'Tôi không cảm thấy mình là người thất bại',
        'Tôi đã thất bại nhiều hơn những người khác',
        'Nhìn lại cuộc đời, tôi thấy mình có quá nhiều thất bại',
        'Tôi cảm thấy mình là một người hoàn toàn thất bại',
      ],
      'selectedAnswerIndex': 3, // Người dùng đã chọn câu trả lời thứ 4
    },
    {
      'question': 'Mất hứng thú',
      'answers': [
        'Tôi vẫn có được sự thích thú như trước đây',
        'Tôi không còn thích thú mọi thứ như trước đây',
        'Tôi không còn thấy thích thú với bất cứ điều gì nữa',
        'Tôi hoàn toàn không hài lòng và chán nản với mọi thứ',
      ],
      'selectedAnswerIndex': 0, // Người dùng đã chọn câu trả lời thứ 1
    },
    {
      'question': 'Cảm giác tội lỗi',
      'answers': [
        'Tôi không cảm thấy có lỗi đặc biệt',
        'Tôi cảm thấy có lỗi về nhiều điều tôi đã làm hoặc lẽ ra nên làm',
        'Tôi cảm thấy khá tội lỗi trong phần lớn thời gian',
        'Tôi cảm thấy cực kỳ tội lỗi mọi lúc',
      ],
      'selectedAnswerIndex': 2, // Người dùng đã chọn câu trả lời thứ 3
    },
    {
      'question': 'Ý nghĩ tự tử',
      'answers': [
        'Tôi không có bất kỳ ý nghĩ nào về việc tự làm hại bản thân',
        'Tôi có những ý nghĩ về việc tự làm hại bản thân, nhưng tôi sẽ không thực hiện chúng',
        'Tôi muốn tự tử',
        'Tôi sẽ tự tử nếu có cơ hội',
      ],
      'selectedAnswerIndex': 0, // Người dùng đã chọn câu trả lời thứ 1
    },
  ];

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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Kết quả bài kiểm tra của bệnh nhân',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Thanh điều hướng Trước/Sau và Tiến độ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: currentQuestionIndex > 0
                      ? previousQuestion
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        currentQuestionIndex > 0 ? Colors.black54 : Colors.grey[300],
                    side: BorderSide(
                        color: currentQuestionIndex > 0
                            ? Colors.grey
                            : Colors.grey[300]!),
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
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? nextQuestion
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: currentQuestionIndex < questions.length - 1
                        ? Colors.black54
                        : Colors.grey[300],
                    side: BorderSide(
                      color: currentQuestionIndex < questions.length - 1
                          ? Colors.grey
                          : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Sau'),
                ),
              ],
            ),
            SizedBox(height: 25),

            // Container chứa câu hỏi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 30.0, horizontal: 15.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                questions[currentQuestionIndex]['question'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Các câu trả lời
            Expanded(
              child: ListView.builder(
                itemCount: questions[currentQuestionIndex]['answers'].length,
                itemBuilder: (context, index) {
                  bool isSelected =
                      questions[currentQuestionIndex]['selectedAnswerIndex'] ==
                          index;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 15.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF007AFF).withOpacity(0.3)
                          : Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF007AFF)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      questions[currentQuestionIndex]['answers'][index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: isSelected ? Colors.black : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
