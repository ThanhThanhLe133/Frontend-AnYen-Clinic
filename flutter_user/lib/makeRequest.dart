import 'dart:convert';
import 'dart:io';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/main.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as ref;

Future<http.Response> makeRequest({
  required String url,
  required String method,
  Map<String, String>? headers,
  dynamic body,
  File? file,
  String? fileFieldName,
}) async {
  String? accessToken = await getAccessToken();
  String? refreshToken = await getRefreshToken();

  Map<String, String> createHeaders([String? token]) {
    final updatedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    if (token != null && token.isNotEmpty) {
      updatedHeaders['Authorization'] = token;
    }
    return updatedHeaders;
  }

  final Uri uri = Uri.parse(url);

  // Hàm gửi request
  Future<http.Response> sendRequest({String? token}) async {
    final requestHeaders = createHeaders(token);
    if (file != null && fileFieldName != null) {
      if (method.toUpperCase() != 'POST') {
        throw Exception('File upload only supports POST method');
      }

      var request = http.MultipartRequest('POST', uri);
      var pic = await http.MultipartFile.fromPath(fileFieldName, file.path);
      request.files.add(pic);

      if (body != null) {
        body!.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      request.headers.addAll(requestHeaders);
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } else {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(
            uri,
            headers: requestHeaders,
          );
        case 'POST':
          return await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        case 'PATCH':
          return await http.patch(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        case 'PUT':
          return await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        case 'DELETE':
          return await http.delete(
            uri,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          );
        default:
          debugPrint('Got response!');
          throw Exception('Unsupported method');
      }
    }
  }

  try {
    http.Response res = await sendRequest(token: accessToken);
    final bodyRefresh = jsonDecode(res.body);

    if (bodyRefresh is Map<String, dynamic> &&
        bodyRefresh['err'] == 2 &&
        refreshToken != null) {
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

        // Thử lại request
        res = await sendRequest(token: newAccessToken);
      } else {
        throw Exception('Failed to refresh token: ${refreshRes.body}');
      }
    }

    return res;
  } catch (e) {
    final navigator = globalNavigatorKey.currentState;

    if (navigator != null) {
      final context = navigator.overlay!.context;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    throw Exception('Request failed: $e');
  }
}
