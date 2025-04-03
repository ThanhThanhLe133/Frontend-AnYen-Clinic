import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  final String label;
  final VoidCallback action;
  final IconData icon;
  final Color iconColor;

  const SettingsMenu({
    super.key,
    required this.label,
    required this.action,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: screenWidth * 0.07),
      title: Text(
        label,
        style:
            TextStyle(fontSize: screenWidth * 0.045, color: Color(0xFF40494F)),
      ),
      trailing: SizedBox(
        width: 40,
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.chevron_right,
            color: Color(0xFF9BA5AC),
            size: screenWidth * 0.08,
          ),
        ),
      ),
      onTap: action,
    );
  }
}
