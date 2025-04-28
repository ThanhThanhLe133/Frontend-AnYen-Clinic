import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/review/ReviewList.dart';
import 'package:anyen_clinic/review/reviewCard_widget.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';

class ReviewListMini extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final String doctorId;
  const ReviewListMini(
      {super.key,
      required this.screenHeight,
      required this.screenWidth,
      required this.doctorId});

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
                  fontSize: widget.screenWidth * 0.04, color: Colors.grey),
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
                  }),
            ),
          );
  }
}
