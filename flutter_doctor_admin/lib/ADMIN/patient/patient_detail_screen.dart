import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final String name;
  final String gender;
  final String dob;
  final String reviewCount;
  final String visitCount;
  final String medicalHistory; // Thêm tiền sử bệnh
  final String allergies; // Thêm dị ứng
  final String age;
  final String height;
  final String weight;

  const PatientDetailScreen({
    Key? key,
    required this.name,
    required this.gender,
    required this.dob,
    required this.reviewCount,
    required this.visitCount,
    required this.medicalHistory, // Thêm tiền sử bệnh
    required this.allergies, // Thêm dị ứng
    required this.age,
    required this.height,
    required this.weight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chi tiết bệnh nhân",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên bệnh nhân in đậm
              _buildSectionTitle('Tên bệnh nhân'),
              _buildSectionContent(name, isBold: true),
              SizedBox(height: 10),

              // Chia thành 2 cột: Giới tính & Tuổi
              Row(
                children: [
                  Expanded(
                    child: _buildColumn(title: 'Giới tính', content: gender),
                  ),
                  SizedBox(width: 20),
                  Expanded(child: _buildColumn(title: 'Tuổi', content: age)),
                ],
              ),
              SizedBox(height: 10),

              // Ngày sinh
              _buildSectionTitle('Ngày sinh'),
              _buildSectionContent(dob),
              SizedBox(height: 10),

              // Tiêu đề "Thông tin sức khỏe" căn giữa, nền màu xanh nhạt, chữ trắng
              _buildSectionTitleWithStyle('Thông tin sức khỏe của bệnh nhân'),
              // Chia thành 2 cột: Chiều cao & Cân nặng
              Row(
                children: [
                  Expanded(
                    child: _buildColumn(
                      title: 'Chiều cao',
                      content: '$height cm',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildColumn(
                      title: 'Cân nặng',
                      content: '$weight kg',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Tiền sử bệnh và dị ứng
              _buildSectionTitle('Tiền sử bệnh'),
              _buildSectionContent(medicalHistory),
              _buildSectionTitle('Dị ứng'),
              _buildSectionContent(allergies),
              SizedBox(height: 20),

              // Tiêu đề "Hoạt động" căn giữa, nền màu xanh nhạt, chữ trắng
              _buildSectionTitleWithStyle('Hoạt động của bệnh nhân'),
              // Số lượt đánh giá và số lượt khám
              Row(
                children: [
                  Expanded(
                    child: _buildColumn(
                      title: 'Số lượt đánh giá',
                      content: reviewCount,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildColumn(
                      title: 'Số lượt khám',
                      content: visitCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget để tạo tiêu đề cho từng phần
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Widget để tạo tiêu đề "Thông tin sức khỏe" và "Hoạt động" với style đặc biệt
  Widget _buildSectionTitleWithStyle(String title) {
    return Container(
      width: double.infinity,
      color: Colors.lightBlueAccent, // Màu nền xanh nhạt
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Màu chữ trắng
        ),
      ),
    );
  }

  // Widget để tạo nội dung cho từng phần
  Widget _buildSectionContent(String content, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget để tạo cột với tiêu đề và nội dung
  Widget _buildColumn({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildSectionTitle(title), _buildSectionContent(content)],
    );
  }
}
