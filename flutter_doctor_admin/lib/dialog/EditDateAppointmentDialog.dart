import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/appointment/appointment_screen.dart';
import 'package:ayclinic_doctor_admin/dialog/SuccessDialog.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

void showEditDateAppointmentDialog(
  BuildContext context,
  String appointmentId,
  String selectedDate,
  String selectedHour,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EditDateAppointmentDialog(
        appointment_id: appointmentId,
        selectedDate: selectedDate,
        selectedHour: selectedHour,
      );
    },
  );
}

class EditDateAppointmentDialog extends StatefulWidget {
  final String appointment_id;
  final String selectedDate;
  final String selectedHour;
  const EditDateAppointmentDialog({
    super.key,
    required this.appointment_id,
    required this.selectedDate,
    required this.selectedHour,
  });

  @override
  _EditDateAppointmentDialogState createState() =>
      _EditDateAppointmentDialogState();
}

class _EditDateAppointmentDialogState extends State<EditDateAppointmentDialog> {
  late List<DateTime> dates;
  late int selectedDateIndex = 0;
  late int selectedTimeIndex;
  late DateTime initialDate;
  late DateTime selectedDate;
  late String selectedHour;
  final List<String> times = [
    "9:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00",
  ];

  late ScrollController _scrollController;

  Future<void> editTimeAppointment() async {
    final parts = selectedHour.split(':');
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final appointmentTime = combinedDateTime.toIso8601String();
    try {
      final response = await makeRequest(
        url: '$apiUrl/admin/edit-appointment',
        method: 'PATCH',
        body: {
          "appointment_id": widget.appointment_id,
          "appoitment_time": appointmentTime,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccessDialog(
          context,
          AppointmentScreen(),
          "Thay đổi thành công",
          "QUay lại",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mes'] ?? "Lỗi sửa lịch hẹn")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreDates);
    selectedDate = formatToDateTime(widget.selectedDate);
    initialDate = selectedDate;
    _generateInitialDates();
    selectedHour = widget.selectedHour;
    selectedTimeIndex = times.indexOf(selectedHour);
    debugPrint(selectedHour);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateInitialDates() {
    dates = List.generate(7, (index) => initialDate.add(Duration(days: index)));
  }

  void _loadMoreDates() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        DateTime lastDate = dates.last;
        for (int i = 1; i <= 7; i++) {
          dates.add(lastDate.add(Duration(days: i)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.04,
      ),
      title: Center(
        child: Text(
          "Sửa lịch hẹn",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Row(
                children: List.generate(dates.length, (index) {
                  DateTime date = dates[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDateIndex = index;
                        selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.01,
                        horizontal: screenWidth * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selectedDateIndex == index
                                ? Colors.blue[50]
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(
                            date.weekday == 1 ? "CN" : "T${date.weekday}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            "${date.day}/${date.month}", // Ngày/Tháng
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20),
          Divider(height: 1),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(times.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimeIndex = index;
                    selectedHour = times[index];
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedTimeIndex == index
                            ? Colors.blue[50]
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    times[index],
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenWidth * 0.02,
                  ),
                ),
                child: Text(
                  "BỎ QUA",
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
              ElevatedButton(
                onPressed: editTimeAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenWidth * 0.02,
                  ),
                ),
                child: Text(
                  "CẬP NHẬT",
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
