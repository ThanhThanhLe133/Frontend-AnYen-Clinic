import 'dart:async';

import 'package:ayclinic_doctor_admin/FilterOption.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/appointment/widget/appointmentConnectingCard.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/widget/BottomFilterBar_appointment.dart';
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
          return Dismissible(
            key: Key(appointments[index].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Lịch hẹn ${appointments[index]["date"]} đã được xoá',
                  ),
                  duration: Duration(milliseconds: 500),
                ),
              );

              setState(() {
                appointments.removeAt(index);
              });
              // await loadData();
            },
            confirmDismiss: (direction) async {
              Completer<bool> completer = Completer<bool>();
              showOptionDialog(
                context,
                "Xác nhận",
                "Bạn có chắc muốn xóa lịch hẹn ngày ${appointments[index]["date"]} không?",
                "Huỷ",
                "Xoá",
                () {
                  completer.complete(true);
                },
              );
              return await completer.future ?? false;
            },
            background: Container(
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ),
            dismissThresholds: {DismissDirection.endToStart: 0.2},
            movementDuration: Duration(milliseconds: 100),
            child: AppointmentConnectingCard(
              isOnline: appointments[index]['isOnline'],
              date: appointments[index]['date'],
              time: appointments[index]['time'],
              question: appointments[index]['question'],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomFilterBar(screenWidth: screenWidth),
    );
  }
}
