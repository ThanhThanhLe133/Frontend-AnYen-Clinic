import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:ayclinic_doctor_admin/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  bool isOnline = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          setState(() {});
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Nhấn back lần nữa để thoát")));
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Xin chào",
                    style: TextStyle(
                      color: Color(0xFF9BA5AC),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Admin Thanh Thanh",
                    style: TextStyle(
                      color: Color(0xFF119CF0),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(width: screenWidth * 0.02),
              Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: isOnline ? Colors.green : Color(0xFF40494F),
                    size: screenWidth * 0.04,
                  ),
                  Text(
                    isOnline ? "Trực tuyến" : "Ngoại tuyến",
                    style: TextStyle(
                      color:
                          isOnline
                              ? Colors.green
                              : Color(0xFF40494F), // Đổi màu dựa trên isOnline
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    child: Center(
                      child: Transform.scale(
                        scale: screenWidth / 600,
                        child: Switch(
                          value: isOnline,
                          onChanged: (value) {
                            setState(() => isOnline = value);
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        floatingActionButton: MenuAdmin(),
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
                    Text(
                      "Tổng số ca tư vấn trong tháng:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: Color(0xFF949FA6),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "15",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                        color: Color(0xFF119CF0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.05),
                Container(
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListTile(
                        leading: null,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Lịch hẹn đang kết nối: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Color(0xFF40494F),
                              ),
                            ),
                            Text(
                              "02 ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF119CF0),
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 10,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9BA5AC),
                              size: screenWidth * 0.08,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: null,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tin nhắn chưa kết thúc: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Color(0xFF40494F),
                              ),
                            ),
                            Text(
                              "02 ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF119CF0),
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 10,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9BA5AC),
                              size: screenWidth * 0.08,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
