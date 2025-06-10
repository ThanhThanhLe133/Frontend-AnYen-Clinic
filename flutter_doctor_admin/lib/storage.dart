import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

String apiUrl = dotenv.env['API_URL'] ?? 'https://default-api.com';
final storage = FlutterSecureStorage();

// Hàm lưu token
Future<void> saveAccessToken(String token) async {
  await storage.write(key: 'access_token', value: token);
}

Future<void> saveRefreshToken(String token) async {
  await storage.write(key: 'refresh_token', value: token);
}

Future<void> saveLogin() async {
  await storage.write(key: 'isLoggedIn', value: 'true');
}

Future<void> saveDoctorState() async {
  await storage.write(key: 'isDoctor', value: 'true');
}

Future<void> saveAdminState() async {
  await storage.write(key: 'isAdmin', value: 'true');
}

Future<String?> getAccessToken() async {
  return await storage.read(key: 'access_token');
}

Future<bool> getLogin() async {
  final result = await storage.read(key: 'isLoggedIn');
  return result == 'true';
}

Future<bool> getDoctorState() async {
  final result = await storage.read(key: 'isDoctor');
  return result == 'true';
}

Future<bool> getAdminState() async {
  final result = await storage.read(key: 'isAdmin');
  return result == 'true';
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refresh_token');
}

Future<void> deleteAccessToken() async {
  await storage.delete(key: 'access_token');
}

Future<void> deleteRefreshToken() async {
  await storage.delete(key: 'refresh_token');
}

Future<void> deleteLogin() async {
  await storage.delete(key: 'isLoggedIn');
}
