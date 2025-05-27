import 'package:flutter/material.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> postDetail;

  const PostDetailScreen({super.key, required this.postDetail});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🔹 Danh sách bình luận mẫu
    final List<Map<String, String>> comments = [
      {
        'name': 'Nguyễn Thị Mai',
        'content': 'Bài viết rất hữu ích, cảm ơn bác sĩ!',
        'time': '22/05/2025 - 12:45',
      },
      {
        'name': 'Lê Văn Nam',
        'content': 'Mình sẽ áp dụng thử các mẹo này xem sao.',
        'time': '22/05/2025 - 13:10',
      },
      {
        'name': 'Trần Hồng',
        'content': 'Bài viết hay quá, mong có thêm nhiều nội dung như vậy!',
        'time': '22/05/2025 - 14:20',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Chi tiết bài viết",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Thông tin bài viết ---
            Text(
              postDetail['title'] ?? '',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.grey[700]),
                SizedBox(width: 6),
                Text(
                  postDetail['author'] ?? '',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey[700]),
                SizedBox(width: 6),
                Text(
                  postDetail['postedTime'] ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              postDetail['content'] ?? '',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                height: 1.6,
              ),
            ),

            /// --- Phần bình luận ---
            SizedBox(height: screenHeight * 0.05),
            Divider(color: Colors.grey[400]),
Text(
  'Bình luận',
  style: TextStyle(
    fontSize: screenWidth * 0.05,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),
SizedBox(height: screenHeight * 0.02),

// Ô nhập bình luận
TextField(
  decoration: InputDecoration(
    hintText: 'Nhập bình luận của bạn...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: screenHeight * 0.015,
      horizontal: screenWidth * 0.04,
    ),
    suffixIcon: Icon(Icons.send, color: Colors.blue),
  ),
  maxLines: null,
),
SizedBox(height: screenHeight * 0.03),
            SizedBox(height: screenHeight * 0.02),
            ...comments.map((comment) => Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.035),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.042,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      comment['content'] ?? '',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      comment['time'] ?? '',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
