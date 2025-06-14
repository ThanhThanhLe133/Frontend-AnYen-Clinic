import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/psychological_test/psychological_test_home_screen.dart';
import 'dart:convert';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';

class PsychologicalAddQuestionsScreen extends StatefulWidget {
  final String testId;

  const PsychologicalAddQuestionsScreen({super.key, required this.testId});

  @override
  State<PsychologicalAddQuestionsScreen> createState() =>
      _PsychologicalAddQuestionsScreenState();
}

class _PsychologicalAddQuestionsScreenState
    extends State<PsychologicalAddQuestionsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  late String testName = widget.testId;

  final List<Map<String, dynamic>> _questions = [];
  final List<String> _currentAnswers = [];

  Future<void> submitQuestionToAPI(
      String question, List<String> answers) async {
    try {
      print('Câu hỏi: $question');
      print('Đáp án: $answers');
      print(json.encode({
        "question_text": question,
        "answers": answers,
      }));

      final response = await makeRequest(
        url: '$apiUrl/admin/test/${widget.testId}/questions',
        method: 'POST',
        body: {
          "question_text": question,
          "answers": List<String>.from(answers),
        },
      );

      if (response.statusCode == 201) {
        _showSnackBar("Câu hỏi đã được thêm thành công.");
      } else {
        _showSnackBar("Lỗi khi thêm câu hỏi.");
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối khi thêm câu hỏi.");
    }
  }

  void _addAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isNotEmpty) {
      setState(() {
        _currentAnswers.add(answer);
        _answerController.clear();
      });
    }
  }

  void _addQuestion() {
    final question = _questionController.text.trim();
    if (question.isNotEmpty && _currentAnswers.isNotEmpty) {
      submitQuestionToAPI(question, _currentAnswers);
      setState(() {
        _questions.add({
          'question': question,
          'answers': List<String>.from(_currentAnswers),
        });
        _questionController.clear();
        _currentAnswers.clear();
      });
    } else {
      _showSnackBar("Vui lòng nhập câu hỏi và ít nhất một câu trả lời");
    }
  }

  void _saveAllQuestions() {
    if (_questions.isEmpty) {
      _showSnackBar("Vui lòng thêm ít nhất một câu hỏi");
      return;
    }

    // TODO: Save questions to backend or database

    _showCompletionDialog();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hoàn tất'),
        content: Text(
          'Bạn đã tạo thành công bài kiểm tra với ${_questions.length} câu hỏi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const PsychologicalTestHomeScreen(),
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

  Widget _buildAnswerInput() {
    return Container(
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
          ..._currentAnswers.asMap().entries.map(
                (entry) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _currentAnswers.removeAt(entry.key));
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    if (_questions.isEmpty) {
      return const Text('Chưa có câu hỏi nào được thêm.');
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _questions.length,
      itemBuilder: (_, index) {
        final item = _questions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(item['question']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (item['answers'] as List<String>)
                  .map((ans) => Text('- $ans'))
                  .toList(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => _questions.removeAt(index));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bài kiểm tra đang tạo',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

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

            _buildAnswerInput(),
            const SizedBox(height: 10),

            _buildActionButton(
              label: 'Thêm câu hỏi',
              color: Colors.blue,
              onPressed: _addQuestion,
            ),
            const SizedBox(height: 20),

            Text(
              'Danh sách câu hỏi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
            const SizedBox(height: 10),

            _buildQuestionsList(),
            const SizedBox(height: 100), // Để tránh che khuất bởi nút lưu
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildActionButton(
          label: 'Lưu bài trắc nghiệm',
          color: const Color.fromARGB(255, 105, 214, 250),
          onPressed: _saveAllQuestions,
        ),
      ),
    );
  }
}
