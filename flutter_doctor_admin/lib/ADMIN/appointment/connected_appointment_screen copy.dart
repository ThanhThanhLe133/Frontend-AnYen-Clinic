import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/widget/appointmentConnectedCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectedAppointmentScreen extends ConsumerStatefulWidget {
  const ConnectedAppointmentScreen({super.key});
  @override
  ConsumerState<ConnectedAppointmentScreen> createState() =>
      _ConnectedAppointmentScreenState();
}

class _ConnectedAppointmentScreenState
    extends ConsumerState<ConnectedAppointmentScreen> {
  final List<Map<String, dynamic>> appointments = [
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã huỷ",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Sắp tới",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành",
      'question': "ddddddddddddddddddddđ",
    },
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isCompleteProvider.notifier).reset();
      ref.read(isOnlineProvider.notifier).reset();
      ref.read(isCancelProvider.notifier).reset();
      ref.read(isNewestProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentConnectedCard(
            isOnline: appointments[index]['isOnline'],
            date: appointments[index]['date'],
            time: appointments[index]['time'],
            status: appointments[index]['status'],
            question: appointments[index]['question'],
          );
        },
      ),
      bottomNavigationBar: BottomFilterBar(screenWidth: screenWidth),
    );
  }
}
