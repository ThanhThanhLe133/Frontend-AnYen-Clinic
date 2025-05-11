import 'dart:convert';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/listReview_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

class ReviewList extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final String doctorId;
  const ReviewList({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.doctorId,
  });

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  List<Map<String, dynamic>> reviews = [];

  Future<void> fetchReview() async {
    String doctorId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/admin/get-all-reviews',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        reviews =
            List<Map<String, dynamic>>.from(data['data']).where((review) {
              return review['status'] != 'Pending' &&
                  review['doctorId'] == doctorId;
            }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return reviews.isEmpty
        ? Padding(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Chưa có đánh giá',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.04,
                color: Colors.grey,
              ),
            ),
          ),
        )
        : SizedBox(
          height: 600,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewCardDetail(
                status: review['status'] ?? '',
                countReport: review['report_count'] ?? 0,
                countHelpful: review['helpful_count'] ?? 0,
                reviewId: review['id'] ?? '',
                username: review['full_name'] ?? 'Ẩn danh',
                date: formatDate(review['createdAt']),
                reviewText: review['comment'] ?? '',
                emoji: getEmojiFromRating(review['rating'] ?? 'Unknown'),
                satisfactionText: getSatisfactionText(
                  review['rating'] ?? 'Unknown',
                ),
                screenHeight: widget.screenHeight,
                screenWidth: widget.screenWidth,
              );
            },
          ),
        );
  }
}

class ReviewCardDetail extends StatefulWidget {
  final int countReport;
  final int countHelpful;
  final String status;
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
    required this.countHelpful,
    required this.countReport,
    required this.status,
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
  late String status;
  Future<void> hideReview() async {
    String reviewId = widget.reviewId;
    final response = await makeRequest(
      url: '$apiUrl/admin/hide-review',
      method: 'PATCH',
      body: {"review_id": reviewId},
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi lưu dữ liệu.")));
      Navigator.pop(context);
    } else {
      setState(() {
        status = 'Hidden';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ẩn thành công.")));
    }
  }

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.screenWidth * 0.9,
          padding: EdgeInsets.all(widget.screenWidth * 0.05),
          margin: EdgeInsets.all(widget.screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFF9AA5AC), width: 1),
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
                      Text(
                        widget.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.screenWidth * 0.045,
                        ),
                      ),
                      Text(
                        widget.date,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: widget.screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: widget.screenWidth * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.emoji,
                        style: TextStyle(fontSize: widget.screenWidth * 0.04),
                      ),
                      SizedBox(width: widget.screenWidth * 0.01),
                      Text(
                        widget.satisfactionText,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: widget.screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: widget.screenWidth * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.screenWidth * 0.03,
                      vertical: widget.screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color:
                          status == 'Approved'
                              ? const Color.fromARGB(255, 48, 218, 54)
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      status == 'Approved' ? 'Hiển thị' : 'Đã ẩn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      icon: Icon(Icons.thumb_up_off_alt),
                      count: widget.countHelpful,
                      label: "Hữu ích",
                      screenWidth: widget.screenWidth,
                      screenHeight: widget.screenHeight,
                    ),
                    SizedBox(width: widget.screenWidth * 0.05),
                    ButtonReviewDetail(
                      icon: Icon(Icons.report),
                      label: "Báo cáo",
                      count: widget.countReport,
                      screenWidth: widget.screenWidth,
                      screenHeight: widget.screenHeight,
                    ),
                    SizedBox(width: widget.screenWidth * 0.05),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (status != "Hidden")
          Positioned(
            top: widget.screenWidth * 0.03,
            right: widget.screenWidth * 0.03,
            child: GestureDetector(
              onTap: () {
                showOptionDialog(
                  context,
                  "Ẩn đánh giá",
                  "Bạn có chắc chắn muốn ẩn đánh giá khỏi giao diện người dùng",
                  "HUỶ",
                  "OK",
                  hideReview,
                );
              },
              child: Icon(Icons.close, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class ButtonReviewDetail extends StatefulWidget {
  final String label;
  final double screenWidth;
  final double screenHeight;
  final Icon? icon;
  final int count;
  const ButtonReviewDetail({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.screenHeight,
    this.icon,
    required this.count,
  });

  @override
  _ButtonReviewDetailState createState() => _ButtonReviewDetailState();
}

class _ButtonReviewDetailState extends State<ButtonReviewDetail> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF119CF0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.04,
          vertical: widget.screenWidth * 0.03,
        ),
        side: BorderSide(color: Color(0xFF119CF0), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: TextStyle(
          fontSize: widget.screenWidth * 0.035,
          fontFamily: 'Inter-Medium',
          color: Colors.blue,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Container(child: Icon(widget.icon!.icon, color: Colors.black)),
            SizedBox(width: widget.screenWidth * 0.02),
          ],
          Text('${widget.count} ${widget.label}'),
        ],
      ),
    );
  }
}
