import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/psychological_test/view_answer_screen.dart';
import 'package:ayclinic_doctor_admin/widget/ViewAnswerCardInList.dart';

class Patient {
  final String name;
  final String gender;
  final int age;

  const Patient({required this.name, required this.gender, required this.age});
}

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
  final Patient patient = const Patient(
    name: 'Nguyễn Văn A',
    gender: 'Nam',
    age: 30,
  );

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
          "Danh sách trắc nghiệm",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin người bệnh
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Họ tên: ${patient.name}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Giới tính: ${patient.gender}',
                    style: TextStyle(fontSize: screenWidth * 0.043),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tuổi: ${patient.age}',
                    style: TextStyle(fontSize: screenWidth * 0.043),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // Danh sách bài trắc nghiệm
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return ViewAnswerCardInList(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: question['title'] ?? '',
                    questionCount: question['questionCount'] ?? '',
                    description: question['description'] ?? '',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewAnswersScreen(),
                        ),
                      );
                    },
                    questions: [],
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
