import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/psychological_test/psychological_test_home_screen.dart';

class PsychologicalAddQuestionsScreen extends StatefulWidget {
  final String testTitle;

  const PsychologicalAddQuestionsScreen({super.key, required this.testTitle});

  @override
  State<PsychologicalAddQuestionsScreen> createState() =>
      _PsychologicalAddQuestionsScreenState();
}

class _PsychologicalAddQuestionsScreenState
    extends State<PsychologicalAddQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  List<Map<String, dynamic>> questions = [];
  List<String> currentAnswers = [];

  void _addAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isNotEmpty) {
      setState(() {
        currentAnswers.add(answer);
        _answerController.clear();
      });
    }
  }

  void _addQuestion() {
    final question = _questionController.text.trim();
    if (question.isNotEmpty && currentAnswers.isNotEmpty) {
      setState(() {
        questions.add({
          'question': question,
          'answers': List<String>.from(currentAnswers),
        });
        _questionController.clear();
        currentAnswers.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập câu hỏi và ít nhất một câu trả lời"),
        ),
      );
    }
  }

  void _saveAllQuestions() {
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm ít nhất một câu hỏi")),
      );
      return;
    }

    // TODO: Lưu questions vào backend hoặc database tại đây

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hoàn tất'),
            content: Text(
              'Bạn đã tạo thành công bài kiểm tra "${widget.testTitle}" với ${questions.length} câu hỏi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Đóng dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const PsychologicalTestHomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm câu hỏi'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Tiêu đề bài kiểm tra
            Text(
              'Bài kiểm tra: ${widget.testTitle}',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            /// Ô nhập câu hỏi
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Ô nhập câu trả lời
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu trả lời...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Colors.blue),
                        onPressed: _addAnswer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...currentAnswers
                      .asMap()
                      .entries
                      .map(
                        (entry) => ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(entry.value),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                currentAnswers.removeAt(entry.key);
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Nút thêm câu hỏi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Thêm câu hỏi',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Danh sách câu hỏi đã thêm
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final item = questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item['question']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            (item['answers'] as List<String>)
                                .map((ans) => Text('- $ans'))
                                .toList(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            questions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Nút lưu bài trắc nghiệm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAllQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Lưu bài trắc nghiệm',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
