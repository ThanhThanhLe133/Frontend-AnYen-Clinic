import 'dart:convert';
import 'package:anyen_clinic/storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> makeRequest({
  required String url,
  required String method,
  Map<String, String>? headers,
  dynamic body,
}) async {
  final accessToken = await getAccessToken();
  final refreshToken = await getRefreshToken();

  headers ??= {};
  headers['Authorization'] = 'Bearer $accessToken';
  headers['Content-Type'] = 'application/json';
  http.Response res;

  try {
    final Uri uri = Uri.parse(url);

    Future<http.Response> sendRequest() async {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(uri,
              headers: headers, body: json.encode(body));
        case 'PATCH':
          return await http.patch(uri,
              headers: headers, body: json.encode(body));
        case 'DELETE':
          return await http.delete(uri,
              headers: headers, body: json.encode(body));
        default:
          throw Exception('Unsupported method');
      }
    }

    res = await sendRequest();

    if (res.body.contains('Access token expired')) {
      final refreshRes = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (refreshRes.statusCode == 200) {
        final respond = jsonDecode(refreshRes.body);
        final newAccessToken = respond['access_token'];

        await saveAccessToken(newAccessToken);
        await saveRefreshToken(respond['refresh_token']);

        headers['Authorization'] = 'Bearer $newAccessToken';

        res = await sendRequest();
      }
    }

    return res;
  } catch (e) {
    throw Exception('Request failed: $e');
  }
}
