import 'dart:convert';
import 'package:ayclinic_doctor_admin/widget/chat_widget/models/message.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:http/http.dart' as http;

class ChatService {
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/conversation/$conversationId/messages'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];

          if (data is List && data.isEmpty) {
            return [];
          } else if (data is Map && data.containsKey('messages')) {
            final List<dynamic> messagesJson = data['messages'];
            return messagesJson.map((json) => Message.fromJson(json)).toList();
          } else {
            throw Exception('Unexpected data format');
          }
        } else {
          throw Exception(
              'Failed to load messages: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }
}
