import 'package:flutter/material.dart';

void showEditDateAppointmentDialog(
    BuildContext context, DateTime initialDate, String selectedHour) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EditDateAppointmentDialog(
        initialDate: initialDate,
        selectedHour: selectedHour,
      );
    },
  );
}

class EditDateAppointmentDialog extends StatefulWidget {
  final DateTime initialDate;
  final String selectedHour;

  const EditDateAppointmentDialog({
    super.key,
    required this.initialDate,
    required this.selectedHour,
  });

  @override
  _EditDateAppointmentDialogState createState() =>
      _EditDateAppointmentDialogState();
}

class _EditDateAppointmentDialogState extends State<EditDateAppointmentDialog> {
  late List<DateTime> dates;
  late int selectedDateIndex;
  late int selectedTimeIndex;

  final List<String> times = [
    "9:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00"
  ];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreDates);
    _generateInitialDates();
    selectedDateIndex = 0;
    selectedTimeIndex = times.indexOf(widget.selectedHour);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateInitialDates() {
    dates = List.generate(
        7, (index) => widget.initialDate.add(Duration(days: index)));
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
      title: Center(
        child: Text(
          "Sửa lịch hẹn",
          style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.blue),
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
                      });
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.01,
                          horizontal: screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: selectedDateIndex == index
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
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Text(
                            "${date.day}/${date.month}", // Ngày/Tháng
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold),
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
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.02,
                      horizontal: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: selectedTimeIndex == index
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
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02),
                ),
                child: Text("BỎ QUA",
                    style: TextStyle(fontSize: screenWidth * 0.04)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02),
                ),
                child: Text("CẬP NHẬT",
                    style: TextStyle(fontSize: screenWidth * 0.04)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
