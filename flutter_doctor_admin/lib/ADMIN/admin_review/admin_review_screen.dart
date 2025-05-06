import 'dart:convert';

import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/approved_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/pending_screen.dart';
import 'package:ayclinic_doctor_admin/widget/statusWidget.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<AdminReviewScreen> {
  bool isPending = true;

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Đánh giá khách hàng",
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
              text1: "Chờ duyệt",
              text2: "Đã duyệt",
              initialChosen: isPending,
              onToggle: (bool value) {
                setState(() {
                  isPending = value;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.05),
            Expanded(child: isPending ? PendingScreen() : ApprovedScreen()),
          ],
        ),
      ),
    );
  }
}
