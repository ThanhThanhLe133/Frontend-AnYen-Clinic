import 'dart:ffi';

import 'package:anyen_clinic/widget/FilterItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BottomFilterBar extends ConsumerStatefulWidget {
  const BottomFilterBar({
    super.key,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  _BottomFilterBarState createState() => _BottomFilterBarState();
}

class _BottomFilterBarState extends ConsumerState<BottomFilterBar> {
  late DateTime selectedDate;
  late TextEditingController _dateController;
  bool isChosenTitle1 = false;
  bool isChosenTitle2 = false;
  late Bool isComplete;
  late Bool isOnline;
  late Bool isCancel;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.screenWidth * 0.05),
      padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.1,
          vertical: widget.screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterOption(
              context, Icons.tune, "Lọc", () => showFilterMenu(context)),
          _buildDivider(),
          _buildFilterOption(context, Icons.calendar_month, "Thời gian",
              () => _showDatePicker(context)),
          _buildDivider(),
          _buildFilterOption(context, Icons.sort, "Sắp xếp", () {}),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
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
      });
    }
  }

  void showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterItemWidget(
                title1: 'Đã hoàn thành',
                title2: 'Sắp tới',
                isChosenTitle1: isChosenTitle1,
                isChosenTitle2: isChosenTitle2,
              ),
              FilterItemWidget(
                title1: 'Tư vấn online',
                title2: 'Tư vấn trực tiếp',
                isStatus: false,
              ),
              FilterItemWidget(title1: "Đã huỷ", isStatus: false),
            ],
          ),
        );
      },
    );
  }

  void updateSelection(bool value, String title) {
    setState(() {
      if (title == "title1") {
        isChosenTitle1 = value;
        // Đồng bộ giá trị với isComplete khi thay đổi
        isComplete = isChosenTitle1;
      } else if (title == "title2") {
        isChosenTitle2 = value;
      }
    });
  }

  Widget _buildFilterOption(BuildContext context, IconData icon, String text,
      VoidCallback onTapAction) {
    return GestureDetector(
      onTap: onTapAction,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: widget.screenWidth * 0.05),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: widget.screenWidth * 0.04,
                  color: Colors.blue,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1.5,
      color: Colors.blue.shade200,
    );
  }
}
