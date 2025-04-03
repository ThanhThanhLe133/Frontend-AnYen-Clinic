import 'package:anyen_clinic/dashboard/DoctorList.dart';
import 'package:anyen_clinic/diary/EmotionHistory.dart';
import 'package:anyen_clinic/doctor/list_doctor_screen.dart';
import 'package:anyen_clinic/widget/circleButton.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:anyen_clinic/widget/radialBarChart.dart';
import 'package:anyen_clinic/widget/sectionTitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  String getGreetingMessage() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Chúc buổi sáng tốt lành ☀️";
    } else if (hour >= 12 && hour < 18) {
      return "Chúc buổi chiều vui vẻ 🌤️";
    } else {
      return "Chúc buổi tối an lành 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nhấn back lần nữa để thoát")),
          );
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            getGreetingMessage(),
            style: TextStyle(
              color: Colors.blue,
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        floatingActionButton: Menu(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(child: RadialBarChart(screenWidth: screenWidth)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Cảm xúc trong tháng của bạn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF949FA6))),
                    SizedBox(
                      width: screenWidth * 0.02,
                    ),
                    SizedBox(
                      width: screenWidth * 0.3,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmotionHistory()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF119CF0),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter-Medium'),
                        ),
                        child: Text(
                          "Lịch sử tâm trạng",
                          softWrap: true,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenWidth * 0.05,
                ),
                Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  constraints: BoxConstraints(minWidth: screenWidth * 0.9),
                  decoration: BoxDecoration(
                    color: Color(0xFFECF8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 4,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                sectionTitle(
                                  title: "Bác sĩ tư vấn",
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                ),
                                Image.asset(
                                  'assets/images/icon_toolDoctor.png',
                                  width: screenWidth * 0.08,
                                  height: screenWidth * 0.08,
                                  fit: BoxFit.contain,
                                )
                              ],
                            ),
                            Text(
                              "Bạn hãy ghi vấn đề cần hỏi để được kết nối với bác sĩ nhé",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Color(0xFF949FA6)),
                              maxLines: null,
                            ),
                            SizedBox(
                              height: screenWidth * 0.05,
                            ),
                            circleButton(
                              label: "Chat với bác sĩ",
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              nextScreen: DoctorListScreen(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      Flexible(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/doctor.png",
                              width: screenWidth * 0.36,
                              height: screenWidth * 0.36,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sectionTitle(
                        title: 'Bác sĩ/Chuyên gia tiêu biểu',
                        screenHeight: screenHeight,
                        screenWidth: screenWidth),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DoctorListScreen()),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Xem tất cả',
                              style: TextStyle(
                                color: Color(0xFF119CF0),
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                DoctorList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
