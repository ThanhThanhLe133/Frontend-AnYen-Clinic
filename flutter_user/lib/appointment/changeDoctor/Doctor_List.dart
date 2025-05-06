import 'dart:convert';

import 'package:anyen_clinic/appointment/changeDoctor/details_doctor_change.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/DoctorCardInList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({
    super.key,
    required this.doctorId,
  });
  final String doctorId;
  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
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

      setState(() {
        doctors = List<Map<String, dynamic>>.from(data['data']
            .where((doctor) => doctor['doctorId'] != widget.doctorId));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorDetailChange(
                      doctorId: _displayedDoctors[index]['doctorId']!,
                    ),
                  ),
                );
              },
              child: DoctorCardChange(
                doctorId: _displayedDoctors[index]['doctorId'],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                name: _displayedDoctors[index]['name']!,
                specialty: _displayedDoctors[index]['specialization']!,
                percentage: 100,
                workplace: _displayedDoctors[index]['workplace']!,
                imageUrl: _displayedDoctors[index]['avatar_url']!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class DoctorCardChange extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String name;
  final String specialty;
  final String workplace;
  final String imageUrl;
  final int percentage;
  final String doctorId;

  const DoctorCardChange(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.name,
      required this.specialty,
      required this.workplace,
      required this.imageUrl,
      required this.percentage,
      required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_up,
                        color: Colors.blue, size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '$percentage% hài lòng',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  'Chuyên khoa: $specialty',
                  style: TextStyle(fontSize: screenWidth * 0.03),
                ),
                Text(
                  'Công tác: $workplace',
                  style: TextStyle(fontSize: screenWidth * 0.03),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
