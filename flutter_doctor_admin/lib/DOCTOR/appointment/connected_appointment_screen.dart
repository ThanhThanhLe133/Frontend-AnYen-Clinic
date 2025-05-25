import 'dart:async';
import 'dart:convert';

import 'package:ayclinic_doctor_admin/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/appointment/widget/appointmentConnectedCard.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/widget/BottomFilterBarConnected.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
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
      url: '$apiUrl/doctor/get-all-appointments',
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
            List<Map<String, dynamic>>.from(data['data']).where((appointment) {
          return appointment['status'] == 'Confirmed' ||
              appointment['status'] == 'Completed' ||
              appointment['status'] == 'Canceled';
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> getFilteredSortedAppointments() {
    final isComplete = ref.watch(isCompleteProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isCancel = ref.watch(isCancelProvider);
    final isNewest = ref.watch(isNewestProvider) ?? true;

    final selectedDate = ref.watch(dateTimeProvider);

    List<Map<String, dynamic>> filtered = appointments.where((a) {
      // Lọc theo trạng thái hoàn thành nếu được chọn
      if (isComplete != null) {
        if (isComplete && a['status'] != 'Completed') return false;
        if (!isComplete && a['status'] == 'Completed') return false;
      }

      // Lọc theo loại cuộc hẹn (online / offline)
      if (isOnline != null) {
        if (isOnline && a['appointment_type'] != 'Online') return false;
        if (!isOnline && a['appointment_type'] == 'Online') return false;
      }

      // Lọc theo trạng thái huỷ
      if (isCancel != null) {
        if (isCancel && a['status'] != 'Canceled') return false;
        if (!isCancel && a['status'] == 'Canceled') return false;
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
      DateTime dateA = DateTime.parse(a['appointment_time']).toLocal();
      DateTime dateB = DateTime.parse(b['appointment_time']).toLocal();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final filteredAppointments = getFilteredSortedAppointments();

    return Scaffold(
      backgroundColor: Colors.white,
      body: filteredAppointments.isEmpty
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
              itemCount: filteredAppointments.length,
              itemBuilder: (context, index) {
                return AppointmentConnectedCard(
                  appointment_id: filteredAppointments[index]['id'],
                  patient_id: filteredAppointments[index]['patient_id'],
                  isOnline: filteredAppointments[index]['appointment_type'] ==
                      "Online",
                  date: _getFormattedDate(
                    filteredAppointments[index]['appointment_time'],
                  ),
                  time: _getFormattedTime(
                    filteredAppointments[index]['appointment_time'],
                  ),
                  status: filteredAppointments[index]['status'],
                  question: filteredAppointments[index]['question'],
                );
              },
            ),
      bottomNavigationBar: BottomFilterBarConnected(screenWidth: screenWidth),
    );
  }
}
