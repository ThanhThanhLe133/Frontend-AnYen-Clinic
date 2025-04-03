import 'package:ayclinic_doctor_admin/widget/BuildToggleOption.dart';
import 'package:ayclinic_doctor_admin/widget/menu.dart';
import 'package:ayclinic_doctor_admin/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            children: [
              Column(
                children: [
                  Text(
                    "Xin chào",
                    style: TextStyle(
                      color: Color(0xFF9BA5AC),
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "BS. CKI MACUS HORIZON",
                    style: TextStyle(
                      color: Color(0xFF119CF0),
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.fiber_manual_record,
                  color: isOnline ? Colors.green : Color(0xFF40494F),
                  size: screenWidth * 0.06,
                ),
                title: Text(
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
                trailing: SizedBox(
                  width: 50,
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
              ),
            ],
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
                  children: [
                    Text(
                      "Cảm xúc trong tháng của bạn",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: Color(0xFF949FA6),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    SizedBox(
                      width: screenWidth * 0.3,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF119CF0),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter-Medium',
                          ),
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
                SizedBox(height: screenWidth * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
