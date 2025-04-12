import 'dart:async';

import 'package:anyen_clinic/provider/FilterOptionProvider.dart';
import 'package:anyen_clinic/appointment/widget/appointmentConnectedCard.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/widget/BottomFilterBar_appointment.dart';
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
      'status': "Đã hoàn thành"
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Sắp tới"
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành"
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Sắp tới"
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành"
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã hoàn thành"
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
          return Dismissible(
            key: Key(appointments[index].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Lịch hẹn ${appointments[index]["date"]} đã được xoá'),
                duration: Duration(milliseconds: 500),
              ));

              setState(() {
                appointments.removeAt(index);
              });
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
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ),
            child: AppointmentConnectedCard(
              isOnline: appointments[index]['isOnline'],
              date: appointments[index]['date'],
              time: appointments[index]['time'],
              status: appointments[index]['status'],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomFilterBar(
        screenWidth: screenWidth,
      ),
    );
  }
}
