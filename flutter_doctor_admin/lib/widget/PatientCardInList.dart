import 'package:flutter/material.dart';

class PatientCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String name;
  final String gender;
  final String age;
  final String imageUrl;
  final String reviewCount; // Số lượt đánh giá
  final String visitCount; // Số lượt khám

  const PatientCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.name,
    required this.gender,
    required this.age,
    required this.imageUrl,
    required this.reviewCount, // Nhận tham số số lượt đánh giá
    required this.visitCount, // Nhận tham số số lượt khám
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05, // Cách lề trái và phải
        vertical: screenHeight * 0.01, // Cách lề trên và dưới
      ),
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
          // Thêm ảnh bệnh nhân
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
                // Tên bệnh nhân
                Text(
                  name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                // Giới tính và tuổi
                Row(
                  children: [
                    Icon(
                      gender == 'female' ? Icons.female : Icons.male,
                      color: gender == 'female' ? Colors.pink : Colors.blue,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Tuổi: $age',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                // Số lượt đánh giá
                Text(
                  'Số lượt đánh giá: $reviewCount',
                  style: TextStyle(fontSize: screenWidth * 0.03),
                ),
                // Số lượt khám
                Text(
                  'Số lượt khám: $visitCount',
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
