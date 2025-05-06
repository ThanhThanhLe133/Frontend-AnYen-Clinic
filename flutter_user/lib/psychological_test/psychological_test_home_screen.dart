import 'package:anyen_clinic/widget/QuestionCardInList.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:flutter/material.dart';
import 'psychological_test_screen.dart';

const List<Map<String, dynamic>> questions = [
  {
    'title': 'Bài kiểm tra trầm cảm',
    'isComplete': false,
    'questionCount': '6 câu hỏi',
    'buttonText': 'LÀM LẠI',
    'description':
        'Hãy đọc kỹ từng nhóm câu và chọn một câu mô tả đúng nhất về cảm xúc của bạn trong hai tuần qua.',
  },
  {
    'title': 'Bài kiểm tra lo âu',
    'isComplete': false,
    'questionCount': '6 câu hỏi',
    'buttonText': 'LÀM',
    'description':
        'Trong 2 tuần qua, bạn cảm thấy những điều sau đây với mức độ nào?',
  },
  {
    'title': 'Trắc nghiệm căng thẳng',
    'isComplete': true,
    'questionCount': '6 câu hỏi',
    'buttonText': 'LÀM',
    'description': 'Trắc nghiệm giúp bạn đánh giá mức độ căng thẳng hiện tại.',
  },
  {
    'title': 'Trắc nghiệm EQ',
    'isComplete': true,
    'questionCount': '5 câu hỏi',
    'buttonText': 'LÀM',
    'description': 'Trắc nghiệm đo lường khả năng kiểm soát cảm xúc của bạn.',
  },
  {
    'title': 'Đánh giá giấc ngủ',
    'isComplete': true,
    'questionCount': '4 câu hỏi',
    'buttonText': 'LÀM',
    'description': 'Đánh giá nhanh tình trạng rối loạn giấc ngủ.',
  },
];

class PsychologicalTestHomeScreen extends StatefulWidget {
  const PsychologicalTestHomeScreen({super.key});

  @override
  State<PsychologicalTestHomeScreen> createState() =>
      _QuestionListScreenState();
}

class _QuestionListScreenState extends State<PsychologicalTestHomeScreen> {
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
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenWidth * 0.05),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return QuestionCardInList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: question['title'] ?? '',
              isComplete: question['isComplete'] ?? '',
              questionCount: question['questionCount'] ?? '',
              buttonText: question['buttonText'] ?? '',
              description: question['description'] ?? '',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PsychologicalTestScreen(
                              title: question['title'] ?? '',
                            )));
              },
            );
          },
        ),
      ),
    );
  }
}
