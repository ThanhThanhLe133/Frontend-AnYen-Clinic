import 'package:flutter/material.dart';

class PendingReviewCard extends StatelessWidget {
  final String username;
  final String date;
  final String reviewText;
  final String emoji;
  final String satisfactionText;
  final double screenWidth;
  final double screenHeight;

  const PendingReviewCard({
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
      width: screenWidth,
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(reviewText, style: TextStyle(fontSize: screenWidth * 0.04)),
          SizedBox(height: 8),
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: screenWidth * 0.05)),
              SizedBox(width: 6),
              Text(
                satisfactionText,
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Xử lý ẩn đánh giá
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 89, 153),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: TextStyle(fontSize: screenWidth * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Ẩn'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Xử lý duyệt đánh giá
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 73, 125, 198),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: TextStyle(fontSize: screenWidth * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text('Duyệt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
