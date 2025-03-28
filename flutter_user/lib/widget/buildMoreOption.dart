import 'package:flutter/material.dart';

class MoreOptionsMenu extends StatelessWidget {
  final List<String> options;
  final Function(String)? onSelected;

  const MoreOptionsMenu({
    super.key,
    required this.options,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[600], size: 20),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => options
          .map((option) => PopupMenuItem<String>(
                value: option,
                height: screenWidth * 0.1,
                child: Text(
                  option,
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ))
          .toList(),
    );
  }
}
