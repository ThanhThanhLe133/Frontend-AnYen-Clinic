import 'dart:math';

import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool toggle1 = true;
  bool toggle2 = true;
  bool toggle3 = true;
  bool toggle4 = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

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
          "Cài đặt thông báo",
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.1),
          child: Container(
            height: max(screenHeight * 0.5, 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color(0xFFD9D9D9),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  _buildToggleOption(
                      screenWidth, Icons.article, "Nhật ký", toggle1, (value) {
                    setState(() => toggle1 = value);
                  }),
                  _buildToggleOption(
                      screenWidth, Icons.lock, "Lịch hẹn", toggle2, (value) {
                    setState(() => toggle2 = value);
                  }),
                  _buildToggleOption(
                      screenWidth, Icons.notifications, "Tin nhắn", toggle3,
                      (value) {
                    setState(() => toggle3 = value);
                  }),
                  _buildToggleOption(
                      screenWidth, Icons.payment, "Thanh toán", toggle4,
                      (value) {
                    setState(() => toggle4 = value);
                  }),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(double screenWidth, IconData icon, String title,
      bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
        size: screenWidth * 0.06,
      ),
      title: Text(title,
          style: TextStyle(
              color: Color(0xFF40494F),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400)),
      trailing: SizedBox(
        width: 50,
        child: Center(
          child: Transform.scale(
            scale: screenWidth / 600,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
