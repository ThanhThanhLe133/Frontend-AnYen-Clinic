import 'dart:math';

import 'package:ayclinic_doctor_admin/DOCTOR/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dashboard_doctor/dashboard.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/message/message_screen.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/settings/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuOpenProvider = StateProvider<bool>((ref) => false);

class MenuDoctor extends ConsumerStatefulWidget {
  const MenuDoctor({super.key});

  @override
  _MenuDoctorState createState() => _MenuDoctorState();
}

class _MenuDoctorState extends ConsumerState<MenuDoctor> {
  final GlobalKey<FabCircularMenuState> _fabKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Widget buildMenuItem(IconData icon, String label, Widget nextScreen) {
      return Tooltip(
        message: label,
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 25),
          onPressed: () {
            ref.read(menuOpenProvider.notifier).state = false; // Đóng menu
            _fabKey.currentState?.close();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => nextScreen),
            );
          },
        ),
      );
    }

    return FabCircularMenu(
      key: _fabKey,
      ringColor: Colors.blue.withOpacity(0.5),
      ringDiameter: max(screenWidth, screenHeight) * 0.65,
      fabColor: Color(0xFF119CF0).withOpacity(0.8),
      fabSize: screenWidth * 0.1,
      ringWidth: screenWidth * 0.13,
      fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
      fabCloseIcon: const Icon(Icons.close, color: Colors.white),
      children: [
        buildMenuItem(Icons.home, "Trang chủ", Dashboard()),
        buildMenuItem(Icons.event, "Lịch hẹn", AppointmentScreen()),
        buildMenuItem(Icons.message, "Tin nhắn", MessageScreen()),
        buildMenuItem(Icons.settings, "Cài đặt", AccountScreen()),
        buildMenuItem(Icons.support_agent, "Liên hệ CSKH", ChatScreen()),
      ],
    );
  }
}
