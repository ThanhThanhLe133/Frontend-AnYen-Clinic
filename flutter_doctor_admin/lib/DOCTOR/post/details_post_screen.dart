import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postDetail;

  const PostDetailScreen({super.key, required this.postDetail});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};

  final List<Map<String, dynamic>> _comments = [
    {
      'name': 'Nguyễn Thị Mai',
      'content': 'Bài viết rất hữu ích, cảm ơn bác sĩ!',
      'time': '22/05/2025 - 12:45',
      'replies': [],
    },
    {
      'name': 'Lê Văn Nam',
      'content': 'Mình sẽ áp dụng thử các mẹo này xem sao.',
      'time': '22/05/2025 - 13:10',
      'replies': [],
    },
    {
      'name': 'Trần Hồng',
      'content': 'Bài viết hay quá, mong có thêm nhiều nội dung như vậy!',
      'time': '22/05/2025 - 14:20',
      'replies': [],
    },
  ];

  int? _replyingToIndex;

  void _handleSendComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final now = DateTime.now();
    final formattedTime = DateFormat('dd/MM/yyyy - HH:mm').format(now);

    setState(() {
      _comments.insert(0, {
        'name': 'Bạn đọc',
        'content': content,
        'time': formattedTime,
        'replies': [],
      });
      _commentController.clear();
    });
  }

  void _handleSendReply(int index) {
    final replyContent = _replyControllers[index]?.text.trim();
    if (replyContent == null || replyContent.isEmpty) return;

    final now = DateTime.now();
    final formattedTime = DateFormat('dd/MM/yyyy - HH:mm').format(now);

    setState(() {
      _comments[index]['replies'].add({
        'name': 'Bạn đọc',
        'content': replyContent,
        'time': formattedTime,
      });
      _replyControllers[index]?.clear();
      _replyingToIndex = null;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
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
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      // --- Nút sửa và xoá ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Thêm logic chỉnh sửa
                  print("Chỉnh sửa bài viết");
                },
                icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                label: Text("Chỉnh sửa", style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Thêm logic xoá
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Xác nhận xoá"),
                      content: Text("Bạn có chắc muốn xoá bài viết này không?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Huỷ"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            print("Bài viết đã bị xoá");
                            Navigator.pop(context); // Quay về màn hình trước
                          },
                          child: Text("Xoá", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete, size: 18, color: Colors.red),
                label: Text("Xoá", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),

            // --- Bài viết ---
            Text(
              widget.postDetail['title'] ?? '',
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
                  widget.postDetail['author'] ?? '',
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
                  widget.postDetail['postedTime'] ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              widget.postDetail['content'] ?? '',
              style: TextStyle(fontSize: screenWidth * 0.045, height: 1.6),
            ),

            // --- Bình luận ---
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

            // Ô nhập bình luận chính
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Nhập bình luận của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                suffixIcon: GestureDetector(
                  onTap: _handleSendComment,
                  child: Icon(Icons.send, color: Colors.blue),
                ),
              ),
              maxLines: null,
            ),
            SizedBox(height: screenHeight * 0.03),

            // Danh sách bình luận
            ..._comments.asMap().entries.map((entry) {
              final index = entry.key;
              final comment = entry.value;

              _replyControllers[index] ??= TextEditingController();

              return Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bình luận chính
                    Container(
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
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment['time'] ?? '',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _replyingToIndex = _replyingToIndex == index ? null : index;
                                  });
                                },
                                child: Text(
                                  'Trả lời',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          if (_replyingToIndex == index) ...[
                            TextField(
                              controller: _replyControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Nhập phản hồi...',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.send, color: Colors.blue),
                                  onPressed: () => _handleSendReply(index),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Danh sách phản hồi
                    ...List.generate(comment['replies'].length, (replyIndex) {
                      final reply = comment['replies'][replyIndex];
                      return Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                reply['content'] ?? '',
                                style: TextStyle(fontSize: screenWidth * 0.038),
                              ),
                              SizedBox(height: 4),
                              Text(
                                reply['time'] ?? '',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.033,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
