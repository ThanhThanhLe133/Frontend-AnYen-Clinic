import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/widget/ApprovedReviewCard.dart';

class ApprovedScreen extends StatelessWidget {
  const ApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final reviews = [
      {
        'username': 'Nguyễn Văn A',
        'date': '20/04/2025',
        'reviewText': 'Thái độ phục vụ rất tốt!',
        'emoji': '😊',
        'satisfactionText': 'Rất hài lòng',
      },
      {
        'username': 'Lê Thị B',
        'date': '18/04/2025',
        'reviewText': 'Chưa hài lòng với thời gian xử lý.',
        'emoji': '😕',
        'satisfactionText': 'Chưa hài lòng',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ApprovedReviewCard(
          username: review['username'] ?? '',
          date: review['date'] ?? '',
          reviewText: review['reviewText'] ?? '',
          emoji: review['emoji'] ?? '',
          satisfactionText: review['satisfactionText'] ?? '',
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        );
      },
    );
  }
}
