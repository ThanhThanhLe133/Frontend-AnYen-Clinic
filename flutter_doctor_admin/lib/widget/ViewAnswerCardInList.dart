import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/psychological_test/view_answer_screen.dart';

class ViewAnswerCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String questionCount;
  final String description;
  final List<Map<String, dynamic>> questions; // Danh sách câu hỏi
  final VoidCallback onPressed;

  const ViewAnswerCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.questionCount,
    required this.description,
    required this.questions, // Truyền questions từ ngoài vào
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(
          bottom: screenHeight * 0.02,
        ),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và nút xóa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF119CF0),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.01),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  questionCount,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: const Color(0xFF9BA5AC),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119CF0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.015,
                      vertical: screenWidth * 0.01,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // Truyền danh sách câu hỏi vào trang kết quả
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewAnswersScreen(
    ),
  ),
);
                  },
                  icon: Icon(Icons.visibility, size: screenWidth * 0.03),
                  label: Text(
                    'XEM',
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.008),

            Text(
              description,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: const Color(0xFF40494F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
