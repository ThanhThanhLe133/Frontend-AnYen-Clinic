import 'dart:math';

import 'package:ayclinic_doctor_admin/ADMIN/admin_review/admin_review_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/dashboard_admin/dashboard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/message/message_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/post/list_post_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/settings/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/add_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_doctor/doctor_list_screen.dart';
import '../manage_doctor/listReview_doctor_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/psychological_test/psychological_test_home_screen.dart';
import 'package:ayclinic_doctor_admin/ADMIN/manage_patient/patient_list_screen.dart';

final menuOpenProvider = StateProvider<bool>((ref) => false);

class MenuAdmin extends ConsumerStatefulWidget {
  const MenuAdmin({super.key});

  @override
  _MenuAdminState createState() => _MenuAdminState();
}

class _MenuAdminState extends ConsumerState<MenuAdmin> {
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
          },
        ),
      );
    }

    return FabCircularMenuPlus(
      key: _fabKey,
      ringColor: Colors.blue.withOpacity(0.3),
      ringDiameter: max(screenWidth, screenHeight) * 0.5,
      fabColor: Color(0xFF119CF0).withOpacity(0.8),
      fabSize: screenWidth * 0.1,
      ringWidth: screenWidth * 0.13,
      fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
      fabCloseIcon: const Icon(Icons.close, color: Colors.white),
      children: [
        buildMenuItem(Icons.home, "Trang chủ", DashboardAdmin()),
        buildMenuItem(
          Icons.local_hospital,
          "Danh sách bác sĩ",
          DoctorListScreen(),
        ),
        buildMenuItem(Icons.event, "Lịch hẹn", AppointmentScreen()),
        buildMenuItem(Icons.message, "Tin nhắn", MessageScreen()),
        buildMenuItem(Icons.reviews, "DS đánh giá", AdminReviewScreen()),
        buildMenuItem(
          Icons.description,
          "Bài viết",
          ListPostScreen(),
        ),
        buildMenuItem(
          Icons.library_books,
          "Trắc nghiệm tâm lý",
          PsychologicalTestHomeScreen(),
        ),
        buildMenuItem(Icons.people, "Danh sách bệnh nhân", PatientListScreen()),
        buildMenuItem(Icons.settings, "Cài đặt", AccountScreen()),
      ],
    );
  }
}
