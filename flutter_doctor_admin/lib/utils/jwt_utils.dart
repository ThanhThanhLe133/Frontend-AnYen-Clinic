import 'dart:convert';
import 'package:ayclinic_doctor_admin/storage.dart';

class jwtUtils {
  static Future<String?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      // Split the token into parts
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      // Get the user ID from the payload
      return payloadMap['id'] as String?;
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }
}
