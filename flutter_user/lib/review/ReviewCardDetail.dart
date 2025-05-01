import 'dart:convert';
import 'dart:ffi';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/doctor/listReview_doctor_screen.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';

class ReviewCardDetail extends StatefulWidget {
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final String reviewId;
  final double screenWidth;
  final double screenHeight;
  const ReviewCardDetail({
    super.key,
    required this.reviewId,
    required this.username,
    required this.date,
    required this.reviewText,
    required this.emoji,
    required this.satisfactionText,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<ReviewCardDetail> createState() => _ReviewCardDetailState();
}

class _ReviewCardDetailState extends State<ReviewCardDetail> {
  bool isPressedReport = false; // Trạng thái báo cáo
  bool isPressedHelpful = false; // Trạng thái hữu ích
  Future<void> plusHelpfulReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
        url: '$apiUrl/review/plus-helpful-review',
        method: 'PATCH',
        body: {"review_id": reviewId});
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi lưu dữ liệu.")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã đánh giá độ hữu ích")));
    }
  }

  Future<void> plusReportReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
        url: '$apiUrl/review/plus-helpful-review',
        method: 'PATCH',
        body: {"review_id": reviewId});
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi lưu dữ liệu.")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Báo cáo thành công")));
    }
  }

  Future<void> fetchPatientReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
      url: '$apiUrl/review/get-review/?review_id=$reviewId',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      if (data['err'] == 0) {
        setState(() {
          isPressedHelpful = data['data']['isHelpful'] ?? false;
          isPressedReport = data['data']['isReport'] ?? false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi tải dữ liệu.")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatientReview();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth * 0.9,
      padding: EdgeInsets.all(widget.screenWidth * 0.05),
      margin: EdgeInsets.all(widget.screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFF9AA5AC),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: widget.screenWidth * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.screenWidth * 0.045)),
                  Text(widget.date,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: widget.screenWidth * 0.035)),
                ],
              ),
            ],
          ),
          SizedBox(height: widget.screenWidth * 0.02),
          Row(
            children: [
              Text(widget.emoji,
                  style: TextStyle(fontSize: widget.screenWidth * 0.04)),
              SizedBox(width: widget.screenWidth * 0.01),
              Text(widget.satisfactionText,
                  style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: widget.screenWidth * 0.04)),
            ],
          ),
          SizedBox(height: widget.screenWidth * 0.02),
          Text(
            widget.reviewText,
            style: TextStyle(fontSize: widget.screenWidth * 0.035),
            softWrap: true,
            maxLines: null,
          ),
          Padding(
            padding: EdgeInsets.only(top: widget.screenHeight * 0.02),
            child: Row(
              children: [
                ButtonReviewDetail(
                    icon: Icon(
                      Icons.thumb_up_off_alt,
                    ),
                    isPressedInitial: isPressedHelpful,
                    label: "Hữu ích",
                    action: plusHelpfulReview,
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight),
                SizedBox(width: widget.screenWidth * 0.05),
                ButtonReviewDetail(
                    label: "Báo cáo",
                    isPressedInitial: isPressedReport,
                    action: (context) => showOptionDialog(
                          context,
                          "Báo cáo",
                          "Nội dung không phù hợp",
                          "HUỶ",
                          "XÁC NHẬN",
                          () => plusReportReview(),
                        ),
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ButtonReviewDetail extends StatefulWidget {
  final String label;
  final double screenWidth;
  final double screenHeight;
  final Icon? icon;
  final Function action;
  final bool isPressedInitial;
  const ButtonReviewDetail({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.screenHeight,
    this.icon,
    required this.action,
    required this.isPressedInitial,
  });

  @override
  _ButtonReviewDetailState createState() => _ButtonReviewDetailState();
}

class _ButtonReviewDetailState extends State<ButtonReviewDetail> {
  late bool isPressed;

  @override
  void initState() {
    super.initState();
    isPressed = widget.isPressedInitial;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isPressed
          ? null
          : () {
              widget.action(context); // Truyền context vào action
              setState(() {
                isPressed = !isPressed;
              });
            },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isPressed ? Color(0xFF119CF0) : const Color(0xFF40494F),
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.04,
          vertical: widget.screenWidth * 0.03,
        ),
        side: BorderSide(
          color: isPressed ? Color(0xFF119CF0) : const Color(0xFFD9D9D9),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        textStyle: TextStyle(
          fontSize: widget.screenWidth * 0.035,
          fontFamily: 'Inter-Medium',
          color: isPressed ? Colors.blue : const Color(0xFFD9D9D9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Container(
              child: Icon(
                widget.icon!.icon,
                color: isPressed ? Color(0xFF119CF0) : Colors.grey,
              ),
            ),
            SizedBox(width: widget.screenWidth * 0.02),
          ],
          Text(widget.label),
        ],
      ),
    );
  }
}
