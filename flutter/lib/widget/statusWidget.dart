import 'package:flutter/material.dart';

class StatusWidget extends StatefulWidget {
  const StatusWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.initialChosen,
    required this.onToggle,
  });
  final String text1;
  final String text2;
  final bool initialChosen;
  final Function(bool) onToggle;
  @override
  State<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  late bool isChosen;

  @override
  void initState() {
    super.initState();
    isChosen = widget.initialChosen;
  }

  void toggleConnection(bool chosen) {
    setState(() {
      isChosen = chosen;
    });
    widget.onToggle(chosen);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: screenWidth * 0.4,
          child: _buildButton(
            widget.text1,
            isChosen ? Colors.blue : Colors.grey.shade300,
            isChosen ? Colors.white : Colors.grey,
            screenWidth: screenWidth,
            isLeft: true,
            onTap: () => toggleConnection(true),
          ),
        ),
        SizedBox(height: screenWidth * 0.1),
        SizedBox(
          width: screenWidth * 0.4,
          child: _buildButton(
            widget.text2,
            isChosen ? Colors.grey.shade300 : Colors.blue,
            isChosen ? Colors.black : Colors.white,
            screenWidth: screenWidth,
            isLeft: false,
            onTap: () => toggleConnection(false),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor, {
    bool isLeft = true,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.03, horizontal: screenWidth * 0.05),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(10) : Radius.zero,
            right: !isLeft ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
