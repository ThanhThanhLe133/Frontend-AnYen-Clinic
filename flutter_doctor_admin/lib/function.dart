import 'dart:convert';

import 'package:ayclinic_doctor_admin/DOCTOR/chat/chat_screen.dart';
import 'package:ayclinic_doctor_admin/makeRequest.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(String dateString) {
  DateTime datetime = DateTime.parse(dateString);
  return DateFormat('HH:mm').format(datetime);
}

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  DateTime parsedDate = DateTime.parse(dateString);
  return DateFormat('dd/MM/yyyy').format(parsedDate);
}

String formatDatePost(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  DateTime parsedDate = DateTime.parse(dateString);
  return DateFormat('dd MMMM, yyyy', 'vi').format(parsedDate);
}

String formatDateComment(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  DateTime parsedDate = DateTime.parse(dateString);
  return DateFormat('dd/MM/yyyy - HH:mm', 'vi').format(parsedDate);
}

String formatCurrency(String totalMoney) {
  final money =
      num.tryParse(totalMoney.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(money);
}

DateTime formatToDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return DateTime.now();
  }

  try {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  } catch (e) {
    return DateTime.now();
  }
}

String getEmojiFromRating(String rating) {
  switch (rating) {
    case 'Very pleased':
      return '😍';
    case 'Pleased':
      return '😊';
    case 'Normal':
      return '😐';
    case 'Unpleased':
      return '😞';
    default:
      return '😐';
  }
}

String getSatisfactionText(String rating) {
  switch (rating) {
    case 'Very pleased':
      return 'Rất hài lòng';
    case 'Pleased':
      return 'Hài lòng';
    case 'Normal':
      return 'Bình thường';
    case 'Unpleased':
      return 'Không hài lòng';
    default:
      return 'Bình thường';
  }
}

int calculateVeryPleasedPercentage(List<Map<String, dynamic>> reviews) {
  if (reviews.isEmpty) {
    return 0;
  }
  int veryPleasedCount =
      reviews.where((review) => review['rating'] == 'Very pleased').length;
  int percentage = ((veryPleasedCount / reviews.length) * 100).round();

  return percentage;
}

int calculatePleasedPercentage(List<Map<String, dynamic>> reviews) {
  if (reviews.isEmpty) {
    return 0;
  }
  int pleasedCount =
      reviews.where((review) => review['rating'] == 'Pleased').length;
  int percentage = ((pleasedCount / reviews.length) * 100).round();

  return percentage;
}

int calculateNormalPercentage(List<Map<String, dynamic>> reviews) {
  if (reviews.isEmpty) {
    return 0;
  }
  int normalCount =
      reviews.where((review) => review['rating'] == 'Normal').length;
  int percentage = ((normalCount / reviews.length) * 100).round();
  return percentage;
}

int calculateUnpleasedPercentage(List<Map<String, dynamic>> reviews) {
  if (reviews.isEmpty) {
    return 0;
  }
  int unPleasedCount =
      reviews.where((review) => review['rating'] == 'Unpleased').length;
  int percentage = ((unPleasedCount / reviews.length) * 100).round();

  return percentage;
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes);
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

Future<void> sendMessageToAdmin(context) async {
  final response = await makeRequest(
    url: '$apiUrl/chat/create-conversation',
    method: 'POST',
  );
  final responseData = jsonDecode(response.body);
  if (response.statusCode != 200) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(responseData['mes'])));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversationId: responseData['data']['id']),
      ),
    );
  }
}
