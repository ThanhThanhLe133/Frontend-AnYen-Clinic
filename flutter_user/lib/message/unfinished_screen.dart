import 'dart:async';

import 'package:anyen_clinic/provider/FilterOptionProvider.dart';
import 'package:anyen_clinic/dialog/option_dialog.dart';
import 'package:anyen_clinic/message/widget/UnFinishMessageCard.dart';
import 'package:anyen_clinic/widget/BottomFilterBar_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnfinishedMessageScreen extends ConsumerStatefulWidget {
  const UnfinishedMessageScreen({super.key});
  @override
  ConsumerState<UnfinishedMessageScreen> createState() =>
      _UnfinishedMessageScreenState();
}

class _UnfinishedMessageScreenState
    extends ConsumerState<UnfinishedMessageScreen> {
  final List<Map<String, dynamic>> messages = [
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
    },
    {
      'isOnline': true,
      'date': "05/03/2025",
      'time': "9:00",
    },
    {
      'isOnline': false,
      'date': "05/03/2025",
      'time': "9:00",
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Tin nhắn ${messages[index]["date"]} đã được xoá'),
                duration: Duration(milliseconds: 500),
              ));

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
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ),
            child: MessageConnectingCard(
              isOnline: messages[index]['isOnline'],
              date: messages[index]['date'],
              time: messages[index]['time'],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomFilterBarMessage(
        screenWidth: screenWidth,
      ),
    );
  }
}
