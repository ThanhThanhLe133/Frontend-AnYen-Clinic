import 'package:ayclinic_doctor_admin/widget/circleButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationBottomBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String content;
  final String totalMoney;
  final String nameButton;
  final Widget nextScreen;
  const ConsultationBottomBar({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.content,
    required this.totalMoney,
    required this.nameButton,
    required this.nextScreen,
  });
  String formatCurrency(String totalMoney) {
    final money = int.tryParse(totalMoney.replaceAll('.', '')) ?? 0;
    return NumberFormat('###,###', 'vi_VN').format(money).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.15,
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenHeight * 0.04,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // Bóng đậm hơn một chút
            blurRadius: 5, // Mở rộng bóng ra xung quanh
            spreadRadius: 0.3, // Kéo dài bóng theo mọi hướng
            offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ),
                Text(
                  formatCurrency(totalMoney),
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            circleButton(
              nextScreen: nextScreen,
              label: nameButton,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ],
        ),
      ),
    );
  }
}
