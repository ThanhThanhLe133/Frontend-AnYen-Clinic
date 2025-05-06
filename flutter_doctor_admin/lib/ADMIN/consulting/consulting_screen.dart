import 'package:ayclinic_doctor_admin/ADMIN/consulting/finish_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/consulting/unfinished_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'package:ayclinic_doctor_admin/widget/statusWidget.dart';
import 'package:flutter/material.dart';

class ConsultingScreen extends StatefulWidget {
  const ConsultingScreen({super.key});

  @override
  State<ConsultingScreen> createState() => _ConsultingScreenState();
}

class _ConsultingScreenState extends State<ConsultingScreen> {
  bool unfinished = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: MenuAdmin(),
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
          "Danh sách tư vấn",
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
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatusWidget(
              text1: "Chưa kết thúc",
              text2: "Đã kết thúc",
              initialChosen: unfinished,
              onToggle: (bool chosen) {
                setState(() {
                  unfinished = chosen;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.05),
            Expanded(
              child:
                  unfinished
                      ? const UnfinishedConsultingScreen()
                      : const FinishedConsultinScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
