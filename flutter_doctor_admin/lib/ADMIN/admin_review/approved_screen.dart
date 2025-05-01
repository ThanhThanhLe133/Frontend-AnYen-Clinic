import 'dart:convert';

import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/widget/ApprovedReviewCard.dart';

class ApprovedScreen extends StatefulWidget {
  const ApprovedScreen({super.key});

  @override
  State<ApprovedScreen> createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
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
              return review['status'] == 'Approved' ||
                  review['status'] == 'Hidden';
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
            return ApprovedReviewCard(
              reviewId: review['id'],
              status: review['status'],
              username: review['full_name'] as String? ?? '',
              date: formatDate(review['createdAt']),
              reviewText: review['comment'] ?? '',
              emoji: getEmojiFromRating(review['rating']),
              satisfactionText: getSatisfactionText(review['rating']),
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              reportCount:
                  int.tryParse(review['report_count']?.toString() ?? '0') ?? 0,
            );
          },
        );
  }
}
