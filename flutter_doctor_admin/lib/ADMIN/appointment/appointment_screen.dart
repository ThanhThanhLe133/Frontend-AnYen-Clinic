import 'package:ayclinic_doctor_admin/ADMIN/appointment/connected_appointment_screen%20copy.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/connecting_appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/statusWidget.dart';
import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool isConnecting = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: MenuAdmin(),
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Lịch hẹn",
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
              text1: "Đang kết nối",
              text2: "Đã kết nối",
              initialChosen: isConnecting,
              onToggle: (bool chosen) {
                setState(() {
                  isConnecting = chosen;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.05),
            Expanded(
              child:
                  isConnecting
                      ? ConnectingAppointmentScreen()
                      : ConnectedAppointmentScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
