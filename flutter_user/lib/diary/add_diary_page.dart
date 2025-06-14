import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/makeRequest.dart';

Widget getMoodIcon(String mood) {
  IconData iconData;
  Color iconColor;

  switch (mood) {
    case 'happy':
      iconData = Icons.sentiment_satisfied_alt;
      iconColor = Colors.orange;
      break;
    case 'sad':
      iconData = Icons.sentiment_dissatisfied;
      iconColor = Colors.blue;
      break;
    case 'relax':
      iconData = Icons.self_improvement;
      iconColor = Colors.green;
      break;
    case 'stress':
      iconData = Icons.sentiment_very_dissatisfied;
      iconColor = Colors.red;
      break;
    default:
      iconData = Icons.sentiment_satisfied_alt;
      iconColor = Colors.grey;
  }

  return Icon(iconData, size: 40, color: iconColor);
}

class AddDiaryScreen extends StatefulWidget {
  const AddDiaryScreen({super.key});

  @override
  State<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends State<AddDiaryScreen> {
  late String selectedMood;
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    selectedMood = 'happy';
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _changeMood(String newMood) {
    setState(() {
      selectedMood = newMood;
    });
  }

  Future<void> _createDiary() async {
    final newDiary = {
      'diary_title': _titleController.text,
      'diary_text': _textController.text,
      'mood': selectedMood,
    };

    final response = await makeRequest(
      url: '$apiUrl/patient/diary/',
      method: 'POST',
      body: newDiary,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã tạo nhật ký!')),
    );
    Navigator.pop(context, newDiary);
  }

  void _saveDiary() {
    String title = _titleController.text;
    String text = _textController.text;

    if (title.isEmpty || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tiêu đề và nội dung!')),
      );
      return;
    }
    print('Create Diary: $title, $text, $selectedMood');
    _createDiary();
  }

  @override
  Widget build(BuildContext context) {
    List<String> moodIcons = ['happy', 'sad', 'relax', 'stress'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm mới nhật ký'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveDiary)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và Icon Mood cùng một hàng
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(236, 248, 255, 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiêu đề nhật ký với TextField
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tiêu đề nhật ký',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Icon Mood - hiển thị và chọn cảm xúc
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Ngày hôm nay của bạn như thế nào?'),
                            backgroundColor: Color.fromRGBO(255, 250, 219, 1),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: moodIcons.map((mood) {
                                return ListTile(
                                  title: Text(mood),
                                  leading: getMoodIcon(mood),
                                  onTap: () {
                                    _changeMood(mood);
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                    child: getMoodIcon(selectedMood),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Phần nội dung nhật ký với TextField
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(236, 248, 255, 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nội dung nhật ký',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
