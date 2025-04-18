import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/ADMIN/psychological_test/psychological_review_screen.dart';

class QuestionCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String questionCount;
  final String description;
  final VoidCallback onPressed;

  const QuestionCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.questionCount,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(
          bottom: screenHeight * 0.02,
        ), // giảm margin dưới
        padding: EdgeInsets.all(screenWidth * 0.03), // giảm padding xung quanh
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
            // Row tiêu đề + icon xóa
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
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa bài kiểm tra này không?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã xóa bài kiểm tra.'),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.01), // giảm chiều cao

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
                      vertical: screenWidth * 0.01, // giảm padding dọc
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PsychologicalTestScreen(title: title),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility, size: screenWidth * 0.03),
                  label: Text(
                    'REVIEW',
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.008), // tiếp tục giảm chút nữa

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
