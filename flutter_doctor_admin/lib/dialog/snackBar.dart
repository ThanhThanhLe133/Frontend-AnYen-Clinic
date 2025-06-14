import 'dart:convert';

import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<void> refreshToken(BuildContext context) async {
  // Get access token
  String? refreshToken = await getRefreshToken();
  final refreshRes = await http.post(
    Uri.parse('$apiUrl/auth/refresh-token'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"refresh_token": refreshToken}),
  );

  if (refreshRes.statusCode == 200) {
    final respond = jsonDecode(refreshRes.body);
    final newAccessToken = respond['access_token'];
    final newRefreshToken = respond['refresh_token'];

    // Lưu token mới
    if (newAccessToken != null) await saveAccessToken(newAccessToken);
    if (newRefreshToken != null) await saveRefreshToken(newRefreshToken);
  } else {
    showErrorSnackBar(
        'Failed to get refresh token: ${refreshRes.body}', context);
    throw Exception('Failed to refresh token: ${refreshRes.body}');
  }
}

void showErrorSnackBar(String message, BuildContext context,
    {WebSocketService? websocket, bool showRetry = false}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: showRetry
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () async {
                await refreshToken(context);
                String? accessToken = await getAccessToken();
                String token = accessToken!.replaceFirst("Bearer ", "");
                try {
                  websocket!.connect(token);
                  websocket.isConnected = true;
                  showSuccessSnackBar(
                    '✅ Kết nối lại thành công!',
                    context,
                  );
                } catch (e) {
                  showErrorSnackBar('❌ Kết nối lại thất bại!', context);
                }
              },
            )
          : null,
    ),
  );
}

void showSuccessSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
    ),
  );
}

void showInfoSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 1),
    ),
  );
}
