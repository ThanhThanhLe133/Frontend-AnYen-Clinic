import 'dart:convert';

import 'package:ayclinic_doctor_admin/DOCTOR/menu_doctor.dart';
import 'package:ayclinic_doctor_admin/Provider/historyConsultProvider.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/radialBarChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryConsulting extends ConsumerStatefulWidget {
  const HistoryConsulting({super.key});

  @override
  ConsumerState<HistoryConsulting> createState() => _HistoryConsultingState();
}

class _HistoryConsultingState extends ConsumerState<HistoryConsulting> {
  late int selectedMonth;
  late int selectedYear;
  List<Map<String, dynamic>> appointments = [];
  late int totalAppointments = 0;
  late int onlineAppointment = 0;
  late int offlineAppointment = 0;
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
          return appointment['status'] == 'Pending' ||
              appointment['status'] == 'Confirmed' ||
              appointment['status'] == 'Completed';
        }).toList();

        //tổng số ca tư vấn trong tháng
        final filteredAppointments = appointments.where((appointment) {
          final time = DateTime.tryParse(appointment['appointment_time']);
          return time != null &&
              time.month == selectedMonth &&
              time.year == selectedYear;
        }).toList();

        totalAppointments = filteredAppointments.length;

        //số ca tư vấn online
        onlineAppointment = filteredAppointments
            .where((appointment) => appointment['appointment_type'] == "Online")
            .toList()
            .length;

        //số ca tư vấn offline
        offlineAppointment = filteredAppointments
            .where(
                (appointment) => appointment['appointment_type'] == "Offline")
            .toList()
            .length;
      });

      ref.read(onlineAppointmentProvider.notifier).setValue(onlineAppointment);
      ref
          .read(offlineAppointmentProvider.notifier)
          .setValue(offlineAppointment);
    }
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAppointment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    List<int> yearList = [for (var y = 2024; y <= DateTime.now().year; y++) y];

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: MenuDoctor(),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Lịch sử tư vấn",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color(0xFF9BA5AC), height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tháng",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    underline: SizedBox(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.black,
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text((index + 1).toString().padLeft(2, '0')),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                      fetchAppointment();
                    },
                  ),
                ),
                SizedBox(width: screenWidth * 0.1),
                Text(
                  "Năm",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    underline: SizedBox(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.black,
                    ),
                    items: yearList.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                      fetchAppointment();
                    },
                  ),
                ),
              ],
            ),
            RadialBarChart(
              screenWidth: screenWidth,
              year: selectedYear,
              month: selectedMonth,
              onlineAppointment: ref.watch(onlineAppointmentProvider),
              offlineAppointment: ref.watch(offlineAppointmentProvider),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tổng số ca tư vấn trong tháng",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: Color(0xFF949FA6),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '$totalAppointments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                    color: Color(0xFF119CF0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
