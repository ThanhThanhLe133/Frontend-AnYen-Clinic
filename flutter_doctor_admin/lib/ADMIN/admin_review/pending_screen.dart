import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/admin_review/widget/PendingReviewCard.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final pendingReviews = [
      {
        'username': 'Trần Văn C',
        'date': '22/04/2025',
        'reviewText': 'Cần cải thiện chất lượng tư vấn.',
        'emoji': '😐',
        'satisfactionText': 'Bình thường',
      },
      {
        'username': 'Phạm Thị D',
        'date': '19/04/2025',
        'reviewText': 'Dịch vụ tốt nhưng thời gian chờ lâu.',
        'emoji': '😕',
        'satisfactionText': 'Chưa hài lòng',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pendingReviews.length,
      itemBuilder: (context, index) {
        final review = pendingReviews[index];
        return PendingReviewCard(
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
