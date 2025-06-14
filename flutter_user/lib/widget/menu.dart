import 'dart:convert';
import 'dart:math';

import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/chat/chat_screen.dart';
import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/diary/diary_list_screen.dart';
import 'package:anyen_clinic/doctor/list_doctor_screen.dart';
import 'package:anyen_clinic/function.dart';
import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/posts/list_post_screen.dart';
import 'package:anyen_clinic/psychological_test/psychological_test_home_screen.dart';
import 'package:anyen_clinic/settings/account_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuOpenProvider = StateProvider<bool>((ref) => false);

class Menu extends ConsumerStatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends ConsumerState<Menu> {
  final GlobalKey<FabCircularMenuPlusState> _fabKey = GlobalKey();

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
            }),
      );
    }

    Widget navigateToChat(
        IconData icon, String label, Future<void> Function() onTap) {
      return Tooltip(
        message: label,
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 25),
            onPressed: () async {
              ref.read(menuOpenProvider.notifier).state = false; // Đóng menu
              _fabKey.currentState?.close();
              await onTap();
            }),
      );
    }

    return FabCircularMenuPlus(
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
        buildMenuItem(
            Icons.local_hospital, "Danh sách bác sĩ", DoctorListScreen()),
        buildMenuItem(Icons.quiz, "Trắc nghiệm", PsychologicalTestHomeScreen()),
        buildMenuItem(Icons.book, "Nhật ký", DiaryListScreen()),
        buildMenuItem(
          Icons.description,
          "Bài viết",
          ListPostScreen(),
        ),
        buildMenuItem(Icons.event, "Lịch hẹn", AppointmentScreen()),
        buildMenuItem(Icons.settings, "Cài đặt", AccountScreen()),
        navigateToChat(
          Icons.support_agent,
          "Liên hệ CSKH",
          () => sendMessageToAdmin(context),
        ),
      ],
    );
  }
}
