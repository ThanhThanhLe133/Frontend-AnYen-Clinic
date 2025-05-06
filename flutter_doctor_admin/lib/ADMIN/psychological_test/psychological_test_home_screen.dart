import 'package:ayclinic_doctor_admin/widget/QuestionCardInList.dart';
import 'package:flutter/material.dart';
import 'psychological_review_screen.dart';
import 'psychological_add_test_screen.dart';

const List<Map<String, dynamic>> questions = [
  {
    'title': 'Bài kiểm tra trầm cảm',
    'questionCount': '6 câu hỏi',
    'description':
        'Hãy đọc kỹ từng nhóm câu và chọn một câu mô tả đúng nhất về cảm xúc của bạn trong hai tuần qua.',
  },
  {
    'title': 'Bài kiểm tra lo âu',
    'questionCount': '6 câu hỏi',
    'description':
        'Trong 2 tuần qua, bạn cảm thấy những điều sau đây với mức độ nào?',
  },
  {
    'title': 'Trắc nghiệm căng thẳng',
    'questionCount': '6 câu hỏi',
    'description': 'Trắc nghiệm giúp bạn đánh giá mức độ căng thẳng hiện tại.',
  },
  {
    'title': 'Trắc nghiệm EQ',
    'questionCount': '5 câu hỏi',
    'description': 'Trắc nghiệm đo lường khả năng kiểm soát cảm xúc của bạn.',
  },
  {
    'title': 'Đánh giá giấc ngủ',
    'questionCount': '4 câu hỏi',
    'description': 'Đánh giá nhanh tình trạng rối loạn giấc ngủ.',
  },
];

class PsychologicalTestHomeScreen extends StatefulWidget {
  const PsychologicalTestHomeScreen({super.key});

  @override
  State<PsychologicalTestHomeScreen> createState() =>
      _PsychologicalTestHomeScreenState();
}

class _PsychologicalTestHomeScreenState
    extends State<PsychologicalTestHomeScreen> {
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
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return QuestionCardInList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: question['title'] ?? '',
              questionCount: question['questionCount'] ?? '',
              description: question['description'] ?? '',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PsychologicalTestScreen(
                          title: question['title'] ?? '',
                        ),
                  ),
                );
              },
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
