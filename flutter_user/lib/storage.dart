import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String apiUrl = dotenv.env['API_URL'] ?? 'https://default-api.com';
final storage = FlutterSecureStorage();

// Hàm lưu token
Future<void> saveToken(String token) async {
  await storage.write(key: 'access_token', value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: 'access_token');
}

Future<void> deleteToken() async {
  await storage.delete(key: 'access_token');
}
