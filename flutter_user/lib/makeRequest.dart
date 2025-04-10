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
  // final accessToken = await getAccessToken();
  final refreshToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjI0MWE1MjVkLTU1NTItNGUzOC04Y2UwLTFmYTVhODgzMThiYiIsImlhdCI6MTc0NDI3Mzg5NiwiZXhwIjoxNzQ0ODc4Njk2fQ.cIqxIILI_0weotxYNUzAZ_J_-QchtPuOSSATNn9ZxRM";
  final accessToken =
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjI0MWE1MjVkLTU1NTItNGUzOC04Y2UwLTFmYTVhODgzMThiYiIsInBob25lX251bWJlciI6Iis4NDM5NzgxMzM5OCIsInJvbGVzIjpbInBhdGllbnQiXSwiaWF0IjoxNzQ0MjczODk2LCJleHAiOjE3NDQyNzQxOTZ9.SKcs6Fp614aAafU8-YHEKSSQBhCE6Hrq4VxyMcpmcaU";
  // Khởi tạo headers, đảm bảo non-null
  Map<String, String> requestHeaders = headers ?? {};
  requestHeaders['Authorization'] = accessToken;

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
          return await http.get(uri, headers: requestHeaders);
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
        debugPrint("ddd $newAccessToken");
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
