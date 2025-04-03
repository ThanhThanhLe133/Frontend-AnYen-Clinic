import 'dart:ffi';

import 'package:ayclinic_doctor_admin/FilterOption.dart';
import 'package:ayclinic_doctor_admin/widget/FilterItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomFilterBarMessage extends ConsumerStatefulWidget {
  const BottomFilterBarMessage({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  _BottomFilterBarState createState() => _BottomFilterBarState();
}

class _BottomFilterBarState extends ConsumerState<BottomFilterBarMessage> {
  late DateTime selectedDate;

  bool isComplete = false;
  bool isOnline = false;
  bool isCancel = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.screenWidth * 0.05),
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenWidth * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterOption(
            context,
            Icons.tune,
            "Lọc",
            () => showFilterMenu(context),
          ),
          _buildDivider(),
          _buildFilterOption(
            context,
            Icons.calendar_month,
            "Thời gian",
            () => _showDatePicker(context),
          ),
          _buildDivider(),
          _buildFilterOption(
            context,
            Icons.sort,
            "Sắp xếp",
            () => showSortMenu(context),
          ),
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
      });
    }
  }

  void showSortMenu(BuildContext context) {
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
                title1: 'Mới nhất',
                title2: 'Cũ nhất',
                isTitle1: ref.watch(isNewestProvider),
                onSelected: (selectedValue) {
                  ref.read(isNewestProvider.notifier).state =
                      (selectedValue == 'Mới nhất');
                },
              ),
            ],
          ),
        );
      },
    );
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
                title1: 'Đã đánh giá',
                title2: 'Chưa đánh giá',
                isTitle1: ref.watch(isCompleteProvider),
                onSelected: (selectedValue) {
                  ref.read(isCompleteProvider.notifier).state =
                      (selectedValue == 'Đã đánh giá');
                },
              ),
              FilterItemWidget(
                title1: 'Tư vấn online',
                title2: 'Tư vấn trực tiếp',
                isTitle1: ref.watch(isOnlineProvider),
                onSelected: (selectedValue) {
                  ref.read(isOnlineProvider.notifier).state =
                      (selectedValue == 'Tư vấn online');
                },
              ),
              FilterItemWidget(
                title1: 'Đã huỷ',
                isTitle1: ref.watch(isCancelProvider),
                onSelected: (selectedValue) {
                  setState(() {
                    ref.read(isOnlineProvider.notifier).state =
                        selectedValue == 'Đã huỷ';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTapAction,
  ) {
    return GestureDetector(
      onTap: onTapAction,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: widget.screenWidth * 0.05),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: widget.screenWidth * 0.04,
              color: Colors.blue,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1.5, color: Colors.blue.shade200);
  }
}
