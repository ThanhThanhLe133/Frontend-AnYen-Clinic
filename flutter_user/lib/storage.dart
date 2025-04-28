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

Future<String?> getAccessToken() async {
  return await storage.read(key: 'access_token');
}

Future<bool> getLogin() async {
  final result = await storage.read(key: 'isLoggedIn');
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

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  DateTime parsedDate = DateTime.parse(dateString);
  return DateFormat('dd/MM/yyyy').format(parsedDate);
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
