import 'dart:async';

import 'package:ayclinic_doctor_admin/ADMIN/consulting/widget/FinishConsultingCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/consulting/widget/UnFinishConsultingCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_message.dart';
import 'package:ayclinic_doctor_admin/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishedConsultinScreen extends ConsumerStatefulWidget {
  const FinishedConsultinScreen({super.key});
  @override
  ConsumerState<FinishedConsultinScreen> createState() =>
      _FinishedConsultinScreenState();
}

class _FinishedConsultinScreenState
    extends ConsumerState<FinishedConsultinScreen> {
  final List<Map<String, dynamic>> messages = [
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Chưa đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Chưa đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
      'status': "Đã đánh giá",
      'question': "ddddddddddddddddddddđ",
    },
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isCompleteProvider.notifier).reset();
      ref.read(isOnlineProvider.notifier).reset();
      ref.read(isCancelProvider.notifier).reset();
      ref.read(isNewestProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(messages[index].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tin nhắn ${messages[index]["date"]} đã được xoá',
                  ),
                  duration: Duration(milliseconds: 500),
                ),
              );

              setState(() {
                messages.removeAt(index);
              });
            },
            confirmDismiss: (direction) async {
              Completer<bool> completer = Completer<bool>();
              showOptionDialog(
                context,
                "Xác nhận",
                "Bạn có chắc muốn xóa tin nhắn ngày ${messages[index]["date"]} không?",
                "Huỷ",
                "Xoá",
                () {
                  completer.complete(true);
                },
              );
              return await completer.future ?? false;
            },
            background: Container(
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ),
            child: FinishConsultingCard(
              isOnline: messages[index]['isOnline'],
              date: messages[index]['date'],
              time: messages[index]['time'],
              status: messages[index]['status'],
              question: messages[index]['question'],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomFilterBarMessage(screenWidth: screenWidth),
    );
  }
}
