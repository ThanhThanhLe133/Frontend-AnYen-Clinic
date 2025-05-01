import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/admin_review/admin_review_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

class ApprovedReviewCard extends StatefulWidget {
  final String status;
  final String reviewId;
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final double screenWidth;
  final double screenHeight;
  final int reportCount;

  const ApprovedReviewCard({
    super.key,
    required this.status,
    required this.reviewId,
    required this.username,
    required this.date,
    required this.reviewText,
    required this.emoji,
    required this.satisfactionText,
    required this.screenHeight,
    required this.screenWidth,
    required this.reportCount,
  });

  @override
  State<ApprovedReviewCard> createState() => _ApprovedReviewCardState();
}

class _ApprovedReviewCardState extends State<ApprovedReviewCard> {
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
          "QUay lại",
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth,
      padding: EdgeInsets.all(widget.screenWidth * 0.04),
      margin: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.01),
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.reportCount} báo cáo',
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
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: widget.screenWidth * 0.2,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.screenWidth * 0.01,
                  vertical: widget.screenWidth * 0.01,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.status == "Approved"
                          ? Color(0xFF19EA31)
                          : Color(0xFF9BA5AC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  widget.status == "Approved" ? "Đã duyệt" : "Đã ẩn",
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.022,
                    color: Colors.white,
                  ),
                ),
              ),
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
            ],
          ),
        ],
      ),
    );
  }
}
