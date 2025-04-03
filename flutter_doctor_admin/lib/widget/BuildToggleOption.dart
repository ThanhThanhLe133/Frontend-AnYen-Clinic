import 'package:flutter/material.dart';

class BuildToggleOption extends StatelessWidget {
  const BuildToggleOption(
      {super.key,
      required this.screenWidth,
      required this.icon,
      required this.title,
      required this.value,
      required this.onChanged});

  final double screenWidth;
  final IconData icon;
  final String title;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
        size: screenWidth * 0.06,
      ),
      title: Text(title,
          style: TextStyle(
              color: Color(0xFF40494F),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400)),
      trailing: SizedBox(
        width: 50,
        child: Center(
          child: Transform.scale(
            scale: screenWidth / 600,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
