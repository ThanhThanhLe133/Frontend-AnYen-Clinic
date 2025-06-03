import 'package:flutter/material.dart';
import 'diary_detail_screen.dart';
import 'add_diary_page.dart';
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

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});
  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<dynamic> diaries = [];

  Future<void> fetchDiary() async {
    final response = await makeRequest(
      url: '$apiUrl/patient/diary', // Đúng URL API bạn có
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      setState(() {
        diaries = data;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách nhật ký")),
      );
    }
  }

  String searchQuery = '';

  // Hàm điều hướng đơn giản, không cần trả về kết quả
  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // Hàm thêm nhật ký mới
  void _createNewDiary() async {
    final newDiary = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDiaryScreen()),
    );

    if (newDiary != null) {
      setState(() {
        diaries.add(newDiary); // Thêm nhật ký mới vào danh sách
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDiary();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredDiaries = diaries.isNotEmpty
        ? diaries.where((diary) {
            return (diary['diary_title'] ?? '').toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                (diary['diary_text'] ?? '')
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
          }).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhật ký của tôi',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhật ký...',
                hintStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Color.fromRGBO(237, 235, 235, 1),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredDiaries.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredDiaries.length,
                    itemBuilder: (context, index) {
                      dynamic diary = filteredDiaries[index];
                      String diaryTitle = diary['diary_title'] ?? "";
                      String diaryText = diary['diary_text'] ?? "";
                      String diaryMood = diary['mood'] ?? "happy";
                      return GestureDetector(
                        onTap: () {
                          // Điều hướng đến trang chi tiết nhật ký
                          _navigateToPage(DiaryDetailScreen(diary: diary));
                        },
                        child: Card(
                          color: Color.fromRGBO(236, 248, 255, 1),
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        diaryTitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Content Preview
                                      Text(
                                        diaryText.length > 50
                                            ? '${diaryText.substring(0, 50)}...'
                                            : diaryText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: getMoodIcon(diaryMood), // Mood icon
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Không có nhật ký nào.',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        child: IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: _createNewDiary, // Thêm nhật ký mới
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
