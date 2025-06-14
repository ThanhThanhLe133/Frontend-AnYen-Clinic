import 'dart:convert';
import 'package:ayclinic_doctor_admin/DOCTOR/menu_doctor.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/post/new_post_screen.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/post_widget/PostCardInList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState();
}

class _ListPostScreenState extends State<ListPostScreen> {
  late ScrollController _scrollController;
  final List<Map<String, dynamic>> _displayedPosts = [];
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  bool _isLoading = false;
  List<Map<String, dynamic>> posts = [];
  Future<void> fetchPosts() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-posts',
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
        posts = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchPosts().then((_) {
      _loadMorePosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (_isLoading || _displayedPosts.length >= posts.length) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > posts.length) {
      endIndex = posts.length;
    }

    List<Map<String, dynamic>> newPosts = posts.sublist(
      startIndex,
      endIndex,
    );

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _displayedPosts.addAll(newPosts);
        _currentPage++;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Bài viết",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 50.0, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có bài viết",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.05,
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _displayedPosts.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _displayedPosts.length) {
                    return Center(
                      child: SpinKitWaveSpinner(
                        color: const Color.fromARGB(255, 72, 166, 243),
                        size: 75.0,
                      ),
                    );
                  }
                  return PostCardInList(
                    screenWidth: MediaQuery.of(context).size.width,
                    screenHeight: MediaQuery.of(context).size.height,
                    title: _displayedPosts[index]['title'],
                    author: _displayedPosts[index]['doctor']['name'],
                    postedTime:
                        formatDatePost(_displayedPosts[index]['createdAt']),
                    postId: _displayedPosts[index]['id'],
                    content: _displayedPosts[index]['content'],
                    isCreator: _displayedPosts[index]['isCreator'],
                  );
                },
              ),
            ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPostScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          MenuDoctor(),
        ],
      ),
    );
  }
}
