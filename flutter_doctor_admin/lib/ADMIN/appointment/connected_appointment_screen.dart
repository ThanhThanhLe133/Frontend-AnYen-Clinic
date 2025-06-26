import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/appointment/widget/appointmentConnectedCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBarConnected.dart';
import 'package:ayclinic_doctor_admin/function.dart';
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
  Set<Map<String, dynamic>> patientSet = {};
  Set<Map<String, dynamic>> doctorSet = {};
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
            List<Map<String, dynamic>>.from(data['data']).where((appointment) {
          return appointment['status'] == 'Confirmed' ||
              appointment['status'] == 'Canceled' ||
              appointment['status'] == 'Completed';
        }).map((appointment) {
          final patient = appointment['patient'];
          final doctor = appointment['doctor'];

          bool existsPatient =
              patientSet.any((p) => p['id'] == patient['patient_id']);
          if (!existsPatient) {
            patientSet.add({
              'id': patient['patient_id'],
              'name': patient['fullname'],
            });
          }

          bool existsDoctor =
              doctorSet.any((d) => d['id'] == doctor['doctor_id']);
          if (!existsDoctor) {
            doctorSet.add({
              'id': doctor['doctor_id'],
              'name': doctor['name'],
            });
          }
          return {
            ...appointment,
            'total_paid': appointment['payment'] != null
                ? appointment['payment']['total_paid']
                : 0,
            'patient_id': patient?['patient_id'],
            'doctor_id': doctor?['doctor_id'],
            'review_id': appointment['review'] != null
                ? appointment['review']['id']
                : "",
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> getFilteredSortedAppointments() {
    final isComplete = ref.watch(isCompleteProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isCancel = ref.watch(isCancelProvider);
    final isReview = ref.watch(isReviewProvider);
    final isNewest = ref.watch(isNewestProvider) ?? true;

    final selectedDate = ref.watch(dateTimeProvider);
    final selectedDoctorId = ref.watch(selectedDoctorProvider);
    final selectedPatientId = ref.watch(selectedPatientProvider);

    List<Map<String, dynamic>> filtered = appointments.where((a) {
      //lọc review hay chưa
      if (isReview != null) {
        if (isReview &&
            (a['review_id'] == null || a['review_id'].toString().isEmpty)) {
          return false;
        }
        if (!isReview &&
            a['review_id'] != null &&
            a['review_id'].toString().isNotEmpty) {
          return false;
        }
      }

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
      // Lọc theo bác sĩ (nếu chọn khác 'all')
      if (selectedDoctorId != 'all' &&
          a['doctor_id'].toString() != selectedDoctorId) {
        return false;
      }

      // Lọc theo bệnh nhân (nếu chọn khác 'all')
      if (selectedPatientId != 'all' &&
          a['patient_id'].toString() != selectedPatientId) {
        return false;
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
      ref.read(isReviewProvider.notifier).reset();
      ref.read(selectedPatientProvider.notifier).state = "all";
      ref.read(selectedDoctorProvider.notifier).state = "all";
    });
    fetchAppointment();
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
                  status: filteredAppointments[index]['status'],
                  isOnline: filteredAppointments[index]['appointment_type'] ==
                      "Online",
                  doctor_id: filteredAppointments[index]['doctor_id'],
                  patient_id: filteredAppointments[index]['patient_id'],
                  date: getFormattedDate(
                    filteredAppointments[index]['appointment_time'],
                  ),
                  time: getFormattedTime(
                    filteredAppointments[index]['appointment_time'],
                  ),
                  total_paid: filteredAppointments[index]['total_paid'],
                  cancel_reason:
                      filteredAppointments[index]['cancel_reason'] ?? '',
                  question: filteredAppointments[index]['question'],
                  review_id: filteredAppointments[index]['review_id'],
                );
              },
            ),
      bottomNavigationBar: BottomFilterBarConnected(
        screenWidth: screenWidth,
        doctorSet: doctorSet,
        patientSet: patientSet,
      ),
    );
  }
}
