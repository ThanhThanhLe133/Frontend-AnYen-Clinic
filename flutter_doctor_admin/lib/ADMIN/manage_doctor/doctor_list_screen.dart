import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/widget/menu_admin.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/CustomBackButton.dart';
import 'package:ayclinic_doctor_admin/widget/circleButton.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/widget/DoctorCardInList.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/add_doctor_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'details_doctor_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late ScrollController _scrollController;
  final List<Map<String, dynamic>> _displayedDoctors = [];
  int _currentPage = 1;
  final int _itemsPerPage = 5;
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
      debugPrint("1222222222");
      setState(() {
        doctors = List<Map<String, dynamic>>.from(data['data']);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          "Danh sách bác sĩ",
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
      // floatingActionButton: MenuAdmin(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.05,
        ),
        child: ListView.builder(
          controller: _scrollController, // Gán controller cho ListView
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
            return DoctorCardInList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              name: _displayedDoctors[index]['name']!,
              specialty: _displayedDoctors[index]['specialization']!,
              percentage:
                  _displayedDoctors[index]['averageSatisfaction'].toInt(),
              workplace: _displayedDoctors[index]['workplace']!,
              imageUrl: _displayedDoctors[index]['avatar_url']!,
              doctorId: _displayedDoctors[index]['doctorId'],
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
                  MaterialPageRoute(builder: (context) => AddDoctorScreen()),
                );
              },
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          MenuAdmin(),
        ],
      ),
    );
  }
}
