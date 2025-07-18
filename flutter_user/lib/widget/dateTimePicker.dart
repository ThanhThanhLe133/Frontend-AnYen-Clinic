import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  final Function(DateTime) onDateSelected; // Callback khi chọn ngày
  final DateTime initialDate;
  final double width;
  const DatePickerField(
      {super.key,
      required this.onDateSelected,
      required this.initialDate,
      required this.width});

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
        widget.onDateSelected(picked); // Gửi ngày đã chọn ra ngoài
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width * 0.45,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF3EFEF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFD9D9D9), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextField(
                controller: _dateController,
                style: TextStyle(
                    fontSize: widget.width * 0.04, color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: widget.width * 0.03),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.calendar_month,
                color: Colors.black54,
                size: widget.width * 0.06,
              ),
              onPressed: () => _selectDate(context),
            ),
          ],
        ),
      ),
    );
  }
}
