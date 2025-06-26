import 'dart:convert';

import 'package:ayclinic_doctor_admin/ADMIN/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';

Future<void> sendMessageToUser(context, userId2, name, avatarUrl) async {
  final response = await makeRequest(
      url: '$apiUrl/chat/create-conversation',
      method: 'POST',
      body: {"userId2": userId2});
  final responseData = jsonDecode(response.body);
  if (response.statusCode != 200) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(responseData['mes'])));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: responseData['data']['id'],
          name: name,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }
}
