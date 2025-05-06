import 'dart:convert';

import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

class ReviewListMini extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final String doctorId;
  const ReviewListMini({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.doctorId,
  });

  @override
  State<ReviewListMini> createState() => _ReviewListMiniState();
}

class _ReviewListMiniState extends State<ReviewListMini> {
  List<Map<String, dynamic>> reviews = [];

  Future<void> fetchReview() async {
    String doctorId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-reviews/?doctorId=$doctorId',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        reviews = List<Map<String, dynamic>>.from(data['data']);
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
    ScrollController scrollController = ScrollController();
    final limitedReviews = reviews.take(3).toList();
    return reviews.isEmpty
        ? Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Chưa có đánh giá',
            style: TextStyle(
              fontSize: widget.screenWidth * 0.04,
              color: Colors.grey,
            ),
          ),
        )
        : Scrollbar(
          thumbVisibility: false,
          controller: scrollController,
          child: Container(
            height: widget.screenHeight * 0.22,
            width: widget.screenWidth * 0.9,
            constraints: BoxConstraints(
              minHeight: widget.screenHeight * 0.1,
              maxHeight: widget.screenHeight * 0.25,
            ),
            child: ListView.builder(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: limitedReviews.length,
              itemBuilder: (context, index) {
                final review = limitedReviews[index];
                return ReviewCardMini(
                  username: review['anonymous_name'] ?? "Ẩn danh",
                  date: formatDate(review['createdAt']),
                  reviewText: review['comment'] ?? '',
                  emoji: getEmojiFromRating(review['rating']),
                  satisfactionText: getSatisfactionText(review['rating']),
                  screenHeight: widget.screenHeight,
                  screenWidth: widget.screenWidth,
                );
              },
            ),
          ),
        );
  }
}

class ReviewCardMini extends StatelessWidget {
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final double screenWidth;
  final double screenHeight;

  const ReviewCardMini({
    super.key,
    required this.username,
    required this.date,
    required this.reviewText,
    required this.emoji,
    required this.satisfactionText,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.65,
      height: screenHeight * 0.22,
      padding: EdgeInsets.all(screenWidth * 0.05),
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF9AA5AC), width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                SizedBox(width: screenWidth * 0.05),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: screenWidth * 0.04)),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  satisfactionText,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Flexible(
              child: Text(
                reviewText,
                style: TextStyle(fontSize: screenWidth * 0.035),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
