import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as https;
import 'package:http/src/response.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';

import 'package:anyen_clinic/widget/menu.dart';
import 'package:anyen_clinic/widget/CustomBackButton.dart';
import 'package:anyen_clinic/widget/PostCardInList.dart';
import 'package:anyen_clinic/posts/details_post_screen.dart';



class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState ();
}

class _ListPostScreenState  extends State<ListPostScreen> {
  late ScrollController _scrollController;
  final List<Map<String, dynamic>> _displayedDoctors = [];
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  bool _isLoading = false;

  // ✅ Dữ liệu mẫu
  final List<Map<String, dynamic>> doctors = List.generate(20, (index) {
    return {
      'name': 'Bác sĩ ${index + 1}',
      'specialization': 'Chuyên khoa ${index + 1}',
      'averageSatisfaction': (80 + index % 20),
      'workplace': 'Bệnh viện A${index + 1}',
      'avatar_url': 'https://via.placeholder.com/150',
      'doctorId': index + 1,
    };
  });

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMoreDoctors(); // Load dữ liệu ngay khi khởi tạo
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
      _loadMoreDoctors();
    }
  }

  void _loadMoreDoctors() {
    if (_isLoading || _displayedDoctors.length >= doctors.length) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > doctors.length) {
      endIndex = doctors.length;
    }

    List<Map<String, dynamic>> newDoctors = doctors.sublist(
      startIndex,
      endIndex,
    );

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _displayedDoctors.addAll(newDoctors);
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
      floatingActionButton: Menu(),
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.05,
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _displayedDoctors.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _displayedDoctors.length) {
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
      title: 'Làm thế nào để chăm sóc sức khỏe tâm thần?',
      author: 'Nguyễn Văn A',
      postedTime: '20 Tháng 5, 2025',
      );

          },
        ),
      ),
    );
  }
}
