import 'package:flutter/material.dart';
import 'psychological_test_home_screen.dart';

class PsychologicalTestScreen extends StatefulWidget {
  final String title;

  const PsychologicalTestScreen({
    super.key,
    this.title = "Bài kiểm tra trầm cảm",
  });

  @override
  _PsychologicalTestScreenState createState() =>
      _PsychologicalTestScreenState();
}

class _PsychologicalTestScreenState extends State<PsychologicalTestScreen> {
  int currentQuestionIndex = 0; // Bắt đầu từ câu hỏi đầu tiên

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
                  onPressed: nextQuestion,
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

            // Không hiển thị các câu trả lời nữa
          ],
        ),
      ),
    );
  }
}
