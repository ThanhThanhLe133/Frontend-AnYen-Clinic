import 'dart:async';
import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/provider/FilterOptionProvider.dart';
import 'package:anyen_clinic/appointment/widget/appointmentConnectingCard.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/widget/BottomFilterBarConnected.dart';
import 'package:anyen_clinic/widget/BottomFilterBarConnecting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      url: '$apiUrl/patient/get-all-appointments',
      method: 'GET',
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.body)));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        appointments =
            List<Map<String, dynamic>>.from(data['data']).where((appointment) {
          return appointment['status'] == 'Pending';
        }).map((appointment) {
          // Lấy thông tin 'total_paid' và thêm vào bản ghi
          return {
            ...appointment,
            'total_paid': appointment['payment'] != null
                ? appointment['payment']['total_paid']
                : 0,
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> getFilteredSortedAppointments() {
    final isOnline = ref.watch(isOnlineProvider);
    final isNewest = ref.watch(isNewestProvider) ?? true;
    final selectedDate = ref.watch(dateTimeProvider);

    List<Map<String, dynamic>> filtered = appointments.where((a) {
      // Lọc theo loại cuộc hẹn (online / offline)
      if (isOnline != null) {
        if (isOnline && a['appointment_type'] != 'Online') return false;
        if (!isOnline && a['appointment_type'] == 'Online') return false;
      }
      if (selectedDate != null) {
        final appointmentDate = DateTime.parse(a['appointment_time']).toLocal();

        if (appointmentDate.year != selectedDate.year ||
            appointmentDate.month != selectedDate.month ||
            appointmentDate.day != selectedDate.day) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sắp xếp theo ngày hẹn
    filtered.sort((a, b) {
      DateTime dateA = DateTime.parse(a['appointment_time']);
      DateTime dateB = DateTime.parse(b['appointment_time']);
      return isNewest ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isCompleteProvider.notifier).reset();
      ref.read(isOnlineProvider.notifier).reset();
      ref.read(isCancelProvider.notifier).reset();
      ref.read(isNewestProvider.notifier).reset();
      ref.read(dateTimeProvider.notifier).clear();
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
    final filteredAppointments = getFilteredSortedAppointments();
    return Scaffold(
      backgroundColor: Colors.white,
      body: filteredAppointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 50.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có lịch hẹn",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                return AppointmentConnectingCard(
                  question: filteredAppointments[index]['question'],
                  doctor_id: filteredAppointments[index]['doctor_id'],
                  appointment_id: filteredAppointments[index]['id'],
                  isOnline: filteredAppointments[index]['appointment_type'] ==
                      "Online",
                  date: _getFormattedDate(
                      filteredAppointments[index]['appointment_time']),
                  time: _getFormattedTime(
                      filteredAppointments[index]['appointment_time']),
                  total_paid: filteredAppointments[index]['total_paid'],
                );
              },
            ),
      bottomNavigationBar: BottomFilterBarConnecting(
        screenWidth: screenWidth,
      ),
    );
  }
}
