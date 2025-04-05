import 'package:anyen_clinic/widget/radialBarChart.dart';
import 'package:flutter/material.dart';

class EmotionHistory extends StatefulWidget {
  const EmotionHistory({super.key});

  @override
  State<EmotionHistory> createState() => _EmotionHistoryState();
}

class _EmotionHistoryState extends State<EmotionHistory> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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
                        // yearController.text=value!.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            RadialBarChart(screenWidth: screenWidth),
          ],
        ),
      ),
    );
  }
}
