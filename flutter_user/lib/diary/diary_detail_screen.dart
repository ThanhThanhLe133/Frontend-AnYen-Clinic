import 'dart:convert';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
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

class DiaryDetailScreen extends StatefulWidget {
  final dynamic diary;
  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late String diaryId;
  late String selectedMood;
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    diaryId = widget.diary['diary_id'] ?? '';
    selectedMood = widget.diary['mood'] ?? 'happy';
    _titleController = TextEditingController(text: widget.diary['diary_title']);
    _textController = TextEditingController(text: widget.diary['diary_text']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Format date: {day} tháng {month}, năm {year}
  String formatDate(DateTime date) {
    return '${date.day} tháng ${date.month}, năm ${date.year}';
  }

  // Update mood
  void _changeMood(String newMood) {
    setState(() {
      selectedMood = newMood;
    });
  }

  Future<void> _updateDiary() async {
    final updatedDiary = {
      'diary_title': _titleController.text,
      'diary_text': _textController.text,
      'mood': selectedMood, // Chuỗi như 'happy', 'sad'
    };

    final response = await makeRequest(
      url: '$apiUrl/patient/diary/${diaryId}',
      method: 'PUT',
      body: updatedDiary,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cập nhật nhật ký!')),
    );
    Navigator.pop(context);
  }

  // Save changes and show confirmation
  void _saveChanges() {
    String title = _titleController.text;
    String text = _textController.text;

    if (title.isEmpty || text.isEmpty) {
      // Show error if the fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tiêu đề và nội dung!')),
      );
      return;
    }
    print('Saved Diary: $title, $text, $selectedMood');

    _updateDiary();
  }

  // Delete diary entry with confirmation
  void _deleteDiary() async {
    final diaryId = widget.diary['diary_id']; // hoặc widget.diary.id

    final response = await makeRequest(
      url: '$apiUrl/patient/diary/$diaryId',
      method: 'DELETE',
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // đóng dialog
      Navigator.pop(context); // quay lại màn hình trước
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa nhật ký!')),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa nhật ký thất bại!')),
      );
    }
  }

  void _confirmDeleteDiary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa nhật ký'),
          content: Text('Bạn có chắc chắn muốn xóa nhật ký này không?'),
          actions: [
            TextButton(
              onPressed: _deleteDiary,
              child: Text('Xóa'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String formattedDate = formatDate(date);
    List<String> moodIcons = ['happy', 'sad', 'relax', 'stress'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết nhật ký'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveChanges),
          IconButton(icon: Icon(Icons.delete), onPressed: _confirmDeleteDiary),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood and title in one row
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(236, 248, 255, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tiêu đề nhật ký',
                            hintStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Chọn cảm xúc'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: moodIcons.map((mood) {
                                    return ListTile(
                                      title:
                                          Text(mood.toString().split('.').last),
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
                  SizedBox(height: 16),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Content section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(236, 248, 255, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nội dung nhật ký',
                  hintStyle: TextStyle(fontSize: 16),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),

            // Display the formatted date
          ],
        ),
      ),
    );
  }
}
