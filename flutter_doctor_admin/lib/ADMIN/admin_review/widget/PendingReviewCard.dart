import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/admin_review/admin_review_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

class PendingReviewCard extends StatefulWidget {
  final String reviewId;
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final double screenWidth;
  final double screenHeight;
  final bool isNegative;

  const PendingReviewCard({
    super.key,
    required this.reviewId,
    required this.username,
    required this.date,
    required this.reviewText,
    required this.emoji,
    required this.satisfactionText,
    required this.screenHeight,
    required this.screenWidth,
    required this.isNegative,
  });

  @override
  State<PendingReviewCard> createState() => _PendingReviewCardState();
}

class _PendingReviewCardState extends State<PendingReviewCard> {
  Future<void> hideReview() async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/hide-review',
        method: 'PATCH',
        body: {"review_id": widget.reviewId},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AdminReviewScreen(),
          "Thay đổi thành công",
          "Quay lại",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi ẩn đánh giá")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

  Future<void> approveReview() async {
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/approve-review',
        method: 'PATCH',
        body: {"review_id": widget.reviewId},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AdminReviewScreen(),
          "Thay đổi thành công",
          "Quay lại",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi duyệt đánh giá")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth,
      padding: EdgeInsets.all(widget.screenWidth * 0.04),
      margin: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.01),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.screenWidth * 0.045,
                ),
              ),
              if (widget.isNegative)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Tiêu cực",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            widget.date,
            style: TextStyle(
              fontSize: widget.screenWidth * 0.035,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.reviewText,
            style: TextStyle(fontSize: widget.screenWidth * 0.04),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.screenWidth * 0.05),
              ),
              SizedBox(width: 6),
              Text(
                widget.satisfactionText,
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  showOptionDialog(
                    context,
                    "Ẩn đánh giá",
                    "Bạn có chắc chắn muốn ẩn đánh giá này",
                    "HUỶ",
                    "ĐỒNG Ý",
                    hideReview,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 89, 153),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: TextStyle(fontSize: widget.screenWidth * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Ẩn'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  showOptionDialog(
                    context,
                    "Duyệt đánh giá",
                    "Bạn có chắc chắn muốn duyệt đánh giá này",
                    "HUỶ",
                    "ĐỒNG Ý",
                    approveReview,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 73, 125, 198),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: TextStyle(fontSize: widget.screenWidth * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Duyệt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
