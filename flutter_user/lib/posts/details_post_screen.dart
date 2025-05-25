import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic> postDetail = {};

  Future<void> fetchPostDetail() async {
    // DỮ LIỆU MẪU - KHÔNG GỌI API
    await Future.delayed(Duration(seconds: 1)); // Giả lập delay

    setState(() {
      postDetail = {
        'title': 'Cách chăm sóc da mùa hè',
        'author': 'Bác sĩ An Yên',
        'postedTime': '22/05/2025 - 10:00',
        'content': '''
Mùa hè đến mang theo ánh nắng gay gắt, khiến làn da dễ bị tổn thương. 
Dưới đây là một số cách đơn giản để bảo vệ làn da của bạn:

- Luôn sử dụng kem chống nắng có SPF từ 30 trở lên.
- Uống đủ nước mỗi ngày (tối thiểu 2 lít).
- Hạn chế ra ngoài từ 10h sáng đến 4h chiều.
- Làm sạch da mặt 2 lần/ngày và dưỡng ẩm thường xuyên.

Hãy bắt đầu chăm sóc da ngay hôm nay để luôn rạng rỡ trong mùa hè này nhé!
        ''',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: postDetail.isEmpty
          ? Center(
              child: SpinKitWaveSpinner(
                color: Colors.blue,
                size: 60,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
    );
  }
}
