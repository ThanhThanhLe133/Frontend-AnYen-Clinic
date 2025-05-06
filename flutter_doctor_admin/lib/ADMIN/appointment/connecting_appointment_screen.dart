import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/widget/appointmentConnectingCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_appointment.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
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
  List<Map<String, dynamic>> appointments = [];
  Future<void> fetchAppointment() async {
    final response = await makeRequest(
      url: '$apiUrl/admin/get-all-appointments',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        appointments =
            List<Map<String, dynamic>>.from(data['data'])
                .where((appointment) {
                  return appointment['status'] == 'Pending' ||
                      appointment['status'] == 'Unpaid';
                })
                .map((appointment) {
                  return {
                    ...appointment,
                    'total_paid':
                        appointment['payment'] != null
                            ? appointment['payment']['total_paid']
                            : 0,
                  };
                })
                .toList();
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body:
          appointments.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 50.0, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "Chưa có lịch hẹn",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return AppointmentConnectingCard(
                    appointment_id: appointments[index]['id'],
                    status: appointments[index]['status'],
                    isOnline:
                        appointments[index]['appointment_type'] == "Online",
                    doctor_id: appointments[index]['doctor_id'],
                    patient_id: appointments[index]['patient_id'],
                    date: _getFormattedDate(
                      appointments[index]['appointment_time'],
                    ),
                    time: _getFormattedTime(
                      appointments[index]['appointment_time'],
                    ),
                    total_paid: appointments[index]['total_paid'],
                    question: appointments[index]['question'],
                  );
                },
              ),
      bottomNavigationBar: BottomFilterBar(screenWidth: screenWidth),
    );
  }
}
