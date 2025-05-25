import 'package:flutter/material.dart';
import 'package:anyen_clinic/posts/details_post_screen.dart'; // ✅ import màn hình chi tiết

class PostCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String author;
  final String postedTime;

  const PostCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.author,
    required this.postedTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostDetailScreen(
        postDetail: {
          'title': title,
          'author': author,
          'postedTime': postedTime,
          'content': '''
Mùa hè đến mang theo ánh nắng gay gắt, khiến làn da dễ bị tổn thương. 
Dưới đây là một số cách đơn giản để bảo vệ làn da của bạn:

- Luôn sử dụng kem chống nắng có SPF từ 30 trở lên.
- Uống đủ nước mỗi ngày (tối thiểu 2 lít).
- Hạn chế ra ngoài từ 10h sáng đến 4h chiều.
- Làm sạch da mặt 2 lần/ngày và dưỡng ẩm thường xuyên.

Hãy bắt đầu chăm sóc da ngay hôm nay để luôn rạng rỡ trong mùa hè này nhé!
          '''
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
                Icon(Icons.person,
                    color: Colors.blue, size: screenWidth * 0.045),
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
