import 'package:intl/intl.dart';

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

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes);
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
