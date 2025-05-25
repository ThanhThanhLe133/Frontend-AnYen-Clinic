import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/DoctorCardInListRow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({super.key});

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  late ScrollController _scrollController;
  final List<Map<String, dynamic>> _displayedDoctors = [];
  int _currentPage = 1;
  final int _itemsPerPage = 4;
  bool _isLoading = false;
  List<Map<String, dynamic>> doctors = [];
  Future<void> fetchDoctors() async {
    final response = await makeRequest(
      url: '$apiUrl/get/get-all-doctors',
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
        doctors = List<Map<String, dynamic>>.from(data['data'])
            .where((doctor) => doctor['averageSatisfaction'] >= 80)
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchDoctors().then((_) {
      _loadMoreDoctors();
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
      _loadMoreDoctors();
    }
  }

  void _loadMoreDoctors() {
    if (_isLoading || _displayedDoctors.length >= doctors.length) {
      return; // Không tải thêm nếu đang loading hoặc đã hết dữ liệu
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

    Future.delayed(Duration(seconds: 1), () {
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

    return SizedBox(
      height: screenHeight * 0.5,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        shrinkWrap: true,
        itemCount: _displayedDoctors.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _displayedDoctors.length) {
            return Center(
              child: SpinKitWaveSpinner(
                color: const Color.fromARGB(255, 72, 166, 243),
                size: 36.0,
              ),
            );
          }
          return DoctorCardInListRow(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            percentage: _displayedDoctors[index]['averageSatisfaction']!,
            name: _displayedDoctors[index]['name']!,
            specialty: _displayedDoctors[index]['specialization']!,
            workplace: _displayedDoctors[index]['workplace']!,
            imageUrl: _displayedDoctors[index]['avatar_url']!,
          );
        },
      ),
    );
  }
}
