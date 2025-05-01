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
        'reportCount': 2, // ✅ Có 2 lượt báo cáo
      },
      {
        'username': 'Lê Thị B',
        'date': '18/04/2025',
        'reviewText': 'Chưa hài lòng với thời gian xử lý.',
        'emoji': '😕',
        'satisfactionText': 'Chưa hài lòng',
        'reportCount': 0, // ✅ Không có lượt báo cáo
      },
            {
        'username': 'Nguyễn Văn A',
        'date': '20/04/2025',
        'reviewText': 'Thái độ phục vụ rất tốt!',
        'emoji': '😊',
        'satisfactionText': 'Rất hài lòng',
        'reportCount': 2, // ✅ Có 2 lượt báo cáo
      },
      {
        'username': 'Lê Thị B',
        'date': '18/04/2025',
        'reviewText': 'Chưa hài lòng với thời gian xử lý.',
        'emoji': '😕',
        'satisfactionText': 'Chưa hài lòng',
        'reportCount': 0, // ✅ Không có lượt báo cáo
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
return ApprovedReviewCard(
  username: (review['username'] as String?) ?? '',
  date: (review['date'] as String?) ?? '',
  reviewText: (review['reviewText'] as String?) ?? '',
  emoji: (review['emoji'] as String?) ?? '',
  satisfactionText: (review['satisfactionText'] as String?) ?? '',
  screenHeight: screenHeight,
  screenWidth: screenWidth,
  reportCount: (review['reportCount'] as int?) ?? 0, // ✅ Fix kiểu dữ liệu
);

      },
    );
  }
}
