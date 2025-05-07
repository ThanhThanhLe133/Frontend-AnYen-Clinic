import 'dart:convert';
import 'dart:io';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Map<String, String> requestHeaders = headers ?? {};

  if (accessToken != null && accessToken.isNotEmpty) {
    requestHeaders['Authorization'] = accessToken;
  }

  final Uri uri = Uri.parse(url);

  // Hàm gửi request
  Future<http.Response> sendRequest() async {
    if (file != null && fileFieldName != null) {
      if (method.toUpperCase() != 'POST') {
        throw Exception('File upload only supports POST method');
      }

      var request = http.MultipartRequest('POST', uri);
      var pic = await http.MultipartFile.fromPath(fileFieldName, file.path);
      request.files.add(pic);
      request.headers.addAll(requestHeaders);
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } else {
      requestHeaders['Content-Type'] = 'application/json';

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
    // Gửi request lần đầu
    http.Response res = await sendRequest();
    final body = jsonDecode(res.body);

    if (body['err'] == 2 && body['mes'] == 'Access token expired') {
      final refreshRes = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final respond = jsonDecode(refreshRes.body);
        final newAccessToken = respond['access_token'];
        final newRefreshToken = respond['refresh_token'];
        debugPrint("$newAccessToken");
        // Lưu token mới
        await saveAccessToken(newAccessToken);
        if (newRefreshToken != null) await saveRefreshToken(newRefreshToken);

        // Cập nhật header với token mới
        requestHeaders['Authorization'] = '$newAccessToken';

        // Thử lại request
        res = await sendRequest();
      } else {
        throw Exception('Failed to refresh token: ${refreshRes.body}');
      }
    }

    return res;
  } catch (e) {
    throw Exception('Request failed: $e');
  }
}
