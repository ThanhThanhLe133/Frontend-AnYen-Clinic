import 'package:flutter/material.dart';

class BottomFilterBar extends StatelessWidget {
  const BottomFilterBar({super.key, required this.screenWidth});
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.1, vertical: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Màu nền xanh nhạt
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterOption(Icons.tune, "Lọc"),
          _buildDivider(),
          _buildFilterOption(Icons.calendar_month, "Thời gian"),
          _buildDivider(),
          _buildFilterOption(Icons.sort, "Sắp xếp"),
        ],
      ),
    );
  }

  Widget _buildFilterOption(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: screenWidth * 0.05),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.blue,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1.5,
      color: Colors.blue.shade200,
    );
  }
}
