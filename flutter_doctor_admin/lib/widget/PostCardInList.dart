import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/post/details_post_screen.dart';

class PostCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String author;
  final String postedTime;
  final String content;

  const PostCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.author,
    required this.postedTime,
    required this.content,

    
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              postDetail: {
                'title': title,
                'author': author,
                'postedTime': postedTime,
                'content': content,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  author,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(Icons.access_time,
                    color: Colors.grey, size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  postedTime,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
