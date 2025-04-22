import 'dart:async';
import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/provider/FilterOptionProvider.dart';
import 'package:anyen_clinic/appointment/widget/appointmentConnectedCard.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/storage.dart';
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
  List<Map<String, dynamic>> appointments = [];
  Future<void> fetchAppointment() async {
    final response = await makeRequest(
      url: '$apiUrl/patient/get-all-appointments',
      method: 'GET',
    );
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        appointments = data['data'].where((appointment) {
          return appointment['status'] == 'Confirmed' ||
              appointment['status'] == 'Completed' ||
              appointment['status'] == 'Canceled';
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isCompleteProvider.notifier).reset();
      ref.read(isOnlineProvider.notifier).reset();
      ref.read(isCancelProvider.notifier).reset();
      ref.read(isNewestProvider.notifier).reset();
    });
    fetchAppointment();
  }

  String _getFormattedDate(String appointmentTime) {
    DateTime dateTime = DateTime.parse(appointmentTime);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _getFormattedTime(String appointmentTime) {
    DateTime dateTime = DateTime.parse(appointmentTime);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
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
                content: Text('Lịch hẹn đã được ẩn'),
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
                "Bạn có chắc muốn ẩn lịch hẹn này không?",
                "Huỷ",
                "Ẩn",
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
              isOnline: appointments[index]['appointment_type'] == "Online",
              date: _getFormattedDate(appointments[index]['appointment_time']),
              time: _getFormattedTime(appointments[index]['appointment_time']),
              status: appointments[index]['status'],
              question: appointments[index]['question'],
              doctor_id: appointments[index]['doctor_id'],
              appointment_id: appointments[index]['id'],
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
