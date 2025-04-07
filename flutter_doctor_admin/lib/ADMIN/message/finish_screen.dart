import 'dart:async';

import 'package:ayclinic_doctor_admin/ADMIN/Provider/FilterOptionProvider.dart';
import 'package:ayclinic_doctor_admin/ADMIN/message/widget/FinishMessageCard.dart';
import 'package:ayclinic_doctor_admin/ADMIN/widget/BottomFilterBar_message.dart';
import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishedMessageScreen extends ConsumerStatefulWidget {
  const FinishedMessageScreen({super.key});
  @override
  ConsumerState<FinishedMessageScreen> createState() =>
      _FinishedMessageScreenState();
}

class _FinishedMessageScreenState extends ConsumerState<FinishedMessageScreen> {
  final List<Map<String, dynamic>> messages = [
    {
      'isPatient': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
    },
    {
      'isPatient': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
    },
    {
      'isPatient': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
    },
    {
      'isPatient': false,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
    },
    {
      'isPatient': true,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
    },
    {
      'isPatient': false,
      'date': "05/03/2025",
      'time': "9:00",
      'question': "ashshshhhhhhhhhhhhhhhhhhhh",
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
          return FinishMessageCard(
            isPatient: messages[index]['isPatient'],
            date: messages[index]['date'],
            time: messages[index]['time'],
            question: messages[index]['question'],
          );
        },
      ),
      bottomNavigationBar: BottomFilterBarMessage(screenWidth: screenWidth),
    );
  }
}
