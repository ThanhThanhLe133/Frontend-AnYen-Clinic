import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EmotionHistory extends ConsumerStatefulWidget {
  const EmotionHistory({super.key});

  @override
  ConsumerState<EmotionHistory> createState() => _EmotionHistoryState();
}

class _EmotionHistoryState extends ConsumerState<EmotionHistory> {
  late int selectedMonth;
  late int selectedYear;

  List<dynamic> diaries = [];
  int totalDiaries = 0;
  int stressDiaries = 0;
  int happyDiaries = 0;
  int sadDiaries = 0;
  int relaxDiaries = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;
    fetchDiary();
  }

  Future<void> fetchDiary() async {
    final response = await makeRequest(
      url: '$apiUrl/patient/diary/',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      setState(() {
        diaries = data['data'] ?? [];

        final currentdiary = diaries.where((diary) {
          final time = diary['created_at'];
          DateTime? dateTime;
          if (time is String) {
            try {
              dateTime = DateTime.parse(time);
            } catch (e) {
              return false;
            }
          } else if (time is DateTime) {
            dateTime = time;
          }

          if (dateTime == null) return false;

          return dateTime.month == selectedMonth &&
              dateTime.year == selectedYear;
        }).toList();

        totalDiaries = currentdiary.length;

        stressDiaries =
            currentdiary.where((diary) => diary['mood'] == 'stress').length;
        happyDiaries =
            currentdiary.where((diary) => diary['mood'] == 'happy').length;
        sadDiaries =
            currentdiary.where((diary) => diary['mood'] == 'sad').length;
        relaxDiaries =
            currentdiary.where((diary) => diary['mood'] == 'relax').length;

        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải danh sách nhật ký")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    List<int> yearList = [for (var y = 2024; y <= DateTime.now().year; y++) y];

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
          "Lịch sử tâm trạng",
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
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tháng",
                  style: TextStyle(
                      fontSize: screenWidth * 0.05, color: Colors.black),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    underline: SizedBox(),
                    style: TextStyle(
                        fontSize: screenWidth * 0.06, color: Colors.black),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                      fetchDiary();
                    },
                  ),
                ),
                SizedBox(width: screenWidth * 0.1),
                Text(
                  "Năm",
                  style: TextStyle(
                      fontSize: screenWidth * 0.05, color: Colors.black),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    underline: SizedBox(),
                    style: TextStyle(
                        fontSize: screenWidth * 0.06, color: Colors.black),
                    items: yearList.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                      fetchDiary();
                    },
                  ),
                ),
              ],
            ),
            isLoading
                ? const Center(
                    child: SpinKitWaveSpinner(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                : RadialBarChart(
                    screenWidth: screenWidth,
                    happyDiaries: happyDiaries,
                    relaxDiaries: relaxDiaries,
                    sadDiaries: sadDiaries,
                    stressDiaries: stressDiaries,
                    year: selectedYear,
                    month: selectedMonth,
                  )
          ],
        ),
      ),
    );
  }
}
