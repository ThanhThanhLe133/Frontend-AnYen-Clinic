import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/widget/appointmentConnectingCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectingAppointmentScreen extends ConsumerStatefulWidget {
  const ConnectingAppointmentScreen({super.key});
  @override
  ConsumerState<ConnectingAppointmentScreen> createState() =>
      _ConnectingAppointmentScreenState();
}

class _ConnectingAppointmentScreenState
    extends ConsumerState<ConnectingAppointmentScreen> {
  final List<Map<String, dynamic>> appointments = [
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
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

  // Future<void> loadData() async {
  //   // Thực hiện các thao tác tải lại dữ liệu, ví dụ gọi API hoặc query database
  //   // Sau khi tải dữ liệu, gọi setState để cập nhật lại danh sách appointments
  //   setState(() {
  //     // Giả sử sau khi tải lại dữ liệu, bạn gán lại cho appointments
  //     appointments = await fetchAppointmentsFromDatabase(); // Ví dụ
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentConnectingCard(
            isOnline: appointments[index]['isOnline'],
            date: appointments[index]['date'],
            time: appointments[index]['time'],
            question: appointments[index]['question'],
          );
        },
      ),
      bottomNavigationBar: BottomFilterBar(screenWidth: screenWidth),
    );
  }
}
