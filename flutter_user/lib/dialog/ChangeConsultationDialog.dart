import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showChangeConsultationDialog(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      bool isSelected = true;
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
          title: Text(
            "Thay đổi hình thức tư vấn",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: _buildOption(
                          Icons.chat_rounded, "Online", isSelected, () {
                        setState(() => isSelected = true);
                      }, screenWidth),
                    ),
                    SizedBox(
                      child: _buildOption(
                          Icons.people_alt_rounded, "Trực tiếp", !isSelected,
                          () {
                        setState(() => isSelected = false);
                      }, screenWidth),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                        text: "BỎ QUA",
                        isPrimary: false,
                        screenWidth: screenWidth),
                    CustomButton(
                      text: "CẬP NHẬT",
                      isPrimary: true,
                      screenWidth: screenWidth,
                      onPressed: () {
                        print("Nút được nhấn!");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

Widget _buildOption(IconData icon, String text, bool isSelected,
    VoidCallback onTap, double screenWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: screenWidth / 500,
          child: Radio(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
            activeColor: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Icon(
          icon,
          color: Colors.blue,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(text,
            maxLines: null,
            softWrap: true,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            )),
      ],
    ),
  );
}
