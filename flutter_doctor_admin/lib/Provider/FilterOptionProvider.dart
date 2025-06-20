import 'package:flutter_riverpod/flutter_riverpod.dart';

// Định nghĩa một Notifier cho trạng thái lọc
class FilterNotifier extends Notifier<bool?> {
  @override
  bool? build() {
    return null;
  }

  void setValue(bool? value) {
    state = value;
  }

  void reset() {
    state = null;
  }
}

class DateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void setDate(DateTime? date) {
    state = date;
  }

  void clear() {
    state = null;
  }
}

final isOnlineProvider = NotifierProvider<FilterNotifier, bool?>(
  () => FilterNotifier(),
);
final isCancelProvider = NotifierProvider<FilterNotifier, bool?>(
  () => FilterNotifier(),
);
final isNewestProvider = NotifierProvider<FilterNotifier, bool?>(
  () => FilterNotifier(),
);

final isCompleteProvider = NotifierProvider<FilterNotifier, bool?>(
  () => FilterNotifier(),
);
final dateTimeProvider =
    NotifierProvider<DateNotifier, DateTime?>(DateNotifier.new);
