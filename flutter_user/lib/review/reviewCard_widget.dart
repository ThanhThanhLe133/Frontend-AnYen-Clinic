import 'package:flutter/material.dart';

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
        border: Border.all(
          color: Color(0xFF9AA5AC),
          width: 1,
        ),
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
                    Text(username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045)),
                    Text(date,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035)),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: screenWidth * 0.04)),
                SizedBox(width: screenWidth * 0.01),
                Text(satisfactionText,
                    style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04)),
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
