import 'package:flutter/material.dart';

class ButtonReview extends StatefulWidget {
  final String label;
  final double screenWidth;
  final double screenHeight;

  const ButtonReview({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  _ButtonReviewState createState() => _ButtonReviewState();
}

class _ButtonReviewState extends State<ButtonReview> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          isPressed = !isPressed;
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isPressed ? Color(0xFF119CF0) : const Color(0xFF40494F),
        minimumSize: Size(widget.screenWidth * 0.2, widget.screenHeight * 0.05),
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.05,
          vertical: widget.screenWidth * 0.03,
        ),
        side: BorderSide(
          color: isPressed ? Color(0xFF119CF0) : const Color(0xFFD9D9D9),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        textStyle: TextStyle(
          fontSize: widget.screenWidth * 0.04,
          fontFamily: 'Inter-Medium',
          color: isPressed ? Colors.red : const Color(0xFF40494F),
        ),
      ),
      child: Text(widget.label),
    );
  }
}
