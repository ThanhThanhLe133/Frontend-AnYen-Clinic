import 'package:anyen_clinic/psychological_test/psychological_test_screen.dart';
import 'package:flutter/material.dart';

class QuestionCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title;
  final String testId;
  final bool isComplete;
  final String buttonText;
  final String questionCount;
  final String description;
  final VoidCallback onPressed;

  const QuestionCardInList({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title,
    required this.testId,
    required this.isComplete,
    required this.buttonText,
    required this.questionCount,
    required this.description,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.04),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color: Color(0xFF119CF0)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? const Color(0xFF00C853) // xanh lá
                          : const Color(0xFFE0E0E0), // xám nhạt
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Text(
                      isComplete ? "Đã hoàn thành" : "Chưa làm",
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color:
                            isComplete ? Colors.white : const Color(0xFF616161),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Số câu hỏi + nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    questionCount,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Color(0xFF9BA5AC),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isComplete
                            ? const Color(0xFF949FA6)
                            : const Color(0xFF119CF0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.015,
                          vertical: screenWidth * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PsychologicalTestScreen(
                                      title: title ?? '',
                                      testId: testId,
                                    )));
                      },
                      icon: Icon(
                        isComplete ? Icons.refresh : Icons.play_arrow,
                        size: screenWidth * 0.03,
                      ),
                      label: Text(
                        isComplete ? 'LÀM LẠI' : 'BẮT ĐẦU',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              // Mô tả
              Text(
                description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Color(0xFF40494F),
                ),
              ),
            ],
          ),
        ));
  }
}
