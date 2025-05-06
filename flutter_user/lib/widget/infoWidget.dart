import 'package:flutter/material.dart';

class infoWidget extends StatelessWidget {
  const infoWidget(
      {super.key,
      required this.screenWidth,
      required this.label,
      required this.info});

  final double screenWidth;
  final String label;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: Text(
            label,
            style: TextStyle(fontSize: screenWidth * 0.035),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.05,
        ),
        Flexible(
          child: SizedBox(
            child: Text(
              info,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
              style: TextStyle(
                  fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}
