import 'dart:convert';

import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/widget/PendingReviewCard.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  List<Map<String, dynamic>> reviews = [];

  Future<void> fetchReviews() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/get-all-reviews',
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
        reviews =
            List<Map<String, dynamic>>.from(data['data']).where((review) {
              return review['status'] == 'Pending';
            }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return reviews.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 50.0, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Chưa có đánh giá",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
        : ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return PendingReviewCard(
              reviewId: review['id'],
              username: review['full_name'] as String? ?? '',
              date: formatDate(review['createdAt']),
              reviewText: review['comment'] ?? '',
              emoji: getEmojiFromRating(review['rating']),
              satisfactionText: getSatisfactionText(review['rating']),
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              isNegative: review['is_negative'] == true,
            );
          },
        );
  }
}
