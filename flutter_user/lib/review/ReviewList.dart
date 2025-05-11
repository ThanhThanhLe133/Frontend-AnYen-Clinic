import 'dart:convert';

import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/review/ReviewCardDetail.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';

class ReviewList extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final String doctorId;
  const ReviewList(
      {super.key,
      required this.screenHeight,
      required this.screenWidth,
      required this.doctorId});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  List<Map<String, dynamic>> reviews = [];
  late ScrollController _scrollController;
  Future<void> fetchReview() async {
    String doctorId = widget.doctorId;
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-reviews/?doctorId=$doctorId',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.body)));
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
      fetchReview();
    });
    _scrollController = ScrollController();
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
                    fontSize: widget.screenWidth * 0.04, color: Colors.grey),
              ),
            ),
          )
        : SizedBox(
            height: 600,
            child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ReviewCardDetail(
                    reviewId: review['id'],
                    username: review['anonymous_name'] ?? "Ẩn danh",
                    date: formatDate(review['createdAt']),
                    reviewText: review['comment'] ?? '',
                    emoji: getEmojiFromRating(review['rating']),
                    satisfactionText: getSatisfactionText(review['rating']),
                    screenHeight: widget.screenHeight,
                    screenWidth: widget.screenWidth,
                  );
                }),
          );
  }
}
