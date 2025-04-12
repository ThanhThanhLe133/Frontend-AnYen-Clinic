import 'package:flutter/material.dart';

class QuestionCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String status;
  final String buttonText;
  final String questionCount;
  final String description;
  final VoidCallback onTap;

  const QuestionCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.status,
    required this.buttonText,
    required this.questionCount,
    required this.description,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          padding: EdgeInsets.all(screenWidth * 0.04),
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
              // Tiêu đề và trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color:
                          status == "Đã hoàn thành" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              // Số câu hỏi + nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    questionCount,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Xử lý khi bấm nút "LÀM" / "LÀM LẠI"
                    },
                    child: Text(
                      buttonText.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              // Mô tả
              Text(
                description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ));
  }
}
