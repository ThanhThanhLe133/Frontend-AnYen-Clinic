import 'dart:convert';

import 'package:anyen_clinic/dialog/SuccessDialog.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/posts/list_post_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<int, TextEditingController> _replyControllers = {};

  List<Map<String, dynamic>> comments = [];
  Map<String, dynamic> post = {};

  late String postId;
  String creatorName = "";
  final Set<int> openReplyIndexes = {};
  int? _replyingToIndex;

  Future<void> handleSendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    final response = await makeRequest(
        url: '$apiUrl/patient/create-comment',
        method: 'POST',
        body: {"post_id": postId, "content": content});
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['mes'])));
    } else {
      setState(() {
        comments.insert(0, data['data']);
        _commentController.clear();
      });
    }
  }

  Future<void> handleSendReply(int index, String commentId) async {
    final replyContent = _replyControllers[index]?.text.trim();
    if (replyContent == null || replyContent.isEmpty) return;
    final response = await makeRequest(
        url: '$apiUrl/patient/reply-comment',
        method: 'POST',
        body: {"comment_id": commentId, "content": replyContent});
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['mes'])));
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        comments[index]['replies'].insert(0, data['data']);
        comments[index]['replyCount']++;
        _replyControllers[index]?.clear();
        _replyingToIndex = null;
        openReplyIndexes.add(index);
        _commentController.clear();
      });
    }
  }

  Future<void> deleteComment(String commentId, int index) async {
    final response = await makeRequest(
      url: '$apiUrl/patient/delete-comment',
      body: {"comment_id": commentId},
      method: 'DELETE',
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['mes'])));
    } else {
      setState(() {
        comments.removeWhere((comment) => comment['id'] == commentId);
        openReplyIndexes.remove(index);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xoá thành công")));
    }
  }

  Future<void> deleteReply(String replyId, int index) async {
    final response = await makeRequest(
      url: '$apiUrl/patient/delete-reply',
      body: {"reply_id": replyId},
      method: 'DELETE',
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['mes'])));
    } else {
      setState(() {
        comments[index]['replies']
            .removeWhere((reply) => reply['id'] == replyId);
        comments[index]['replyCount']--;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xoá thành công")));
    }
  }

  Future<void> fetchPost() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-post/?post_id=$postId',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      final responseData = data['data'];
      setState(() {
        post = Map<String, dynamic>.from(responseData['post']);
        creatorName = responseData['post']['doctor']['name'];
      });
    }
  }

  Future<void> fetchComments() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-comments/?post_id=$postId',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        comments = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    fetchPost();
    fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
              SizedBox(height: screenHeight * 0.01),

              // --- Bài viết ---
              Text(
                post['title'] ?? '',
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
                    creatorName ?? '',
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
                    formatDatePost(post['createdAt']) ?? '',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                post['content'] ?? '',
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
                    onTap: handleSendComment,
                    child: Icon(Icons.send, color: Colors.blue),
                  ),
                ),
                maxLines: null,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Danh sách bình luận
              if (comments.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.comment, size: 25.0, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Chưa có bình luận",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...comments.asMap().entries.map((entry) {
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['doctor'] != null
                                              ? comment['doctor']!['name'] ??
                                                  'Không rõ tên'
                                              : comment['patient'] != null
                                                  ? comment['patient']![
                                                          'anonymous_name'] ??
                                                      'Không rõ tên'
                                                  : 'Không rõ tên',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.042,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          comment['content'] ?? '',
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: screenWidth * 0.04),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (comment['isCreator'])
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showOptionDialog(
                                          context,
                                          "Xoá bình luận",
                                          "Bạn có chắc chắn muốn xoá bình luận này?",
                                          "HUỶ",
                                          "OK",
                                          () async {
                                            await deleteComment(
                                                comment['id'], index);
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDateComment(comment['createdAt']) ??
                                        '',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if ((comment['replyCount'] ?? 0) > 0)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if (openReplyIndexes
                                                  .contains(index)) {
                                                openReplyIndexes.remove(index);
                                              } else {
                                                openReplyIndexes.add(index);
                                              }
                                            });
                                          },
                                          child: Text(
                                            openReplyIndexes.contains(index)
                                                ? 'Ẩn'
                                                : '${comment['replyCount']} lượt trả lời',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _replyingToIndex =
                                                _replyingToIndex == index
                                                    ? null
                                                    : index;
                                          });
                                        },
                                        child: Text(
                                          'Trả lời',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_replyingToIndex == index) ...[
                                TextField(
                                  controller: _replyControllers[index],
                                  decoration: InputDecoration(
                                    hintText: 'Nhập phản hồi...',
                                    suffixIcon: IconButton(
                                      icon:
                                          Icon(Icons.send, color: Colors.blue),
                                      onPressed: () =>
                                          handleSendReply(index, comment['id']),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (openReplyIndexes.contains(index))
                          // Danh sách phản hồi
                          ...List.generate(comment['replies'].length,
                              (replyIndex) {
                            final reply = comment['replies'][replyIndex];
                            return Padding(
                              padding: EdgeInsets.only(left: 20.0, top: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reply['doctor'] != null
                                                    ? reply['doctor']![
                                                            'name'] ??
                                                        'Không rõ tên'
                                                    : reply['patient'] != null
                                                        ? reply['patient']![
                                                                'anonymous_name'] ??
                                                            'Không rõ tên'
                                                        : 'Không rõ tên',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              Text(
                                                reply['content'] ?? '',
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.038),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        if (reply['isCreator'])
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              showOptionDialog(
                                                context,
                                                "Xoá bình luận",
                                                "Bạn có chắc chắn muốn xoá bình luận này?",
                                                "HUỶ",
                                                "OK",
                                                () async {
                                                  await deleteReply(
                                                      reply['id'], index);
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatDateComment(reply['createdAt']) ??
                                          '',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
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
                }),
            ],
          ),
        ),
      ),
    );
  }
}
