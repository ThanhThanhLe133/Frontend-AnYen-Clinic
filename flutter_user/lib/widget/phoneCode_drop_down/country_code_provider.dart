import 'package:flutter_riverpod/flutter_riverpod.dart';

// Quản lý mã quốc gia
class CountryCodeNotifier extends Notifier<String> {
  @override
  String build() {
    return "+84";
  }

  void updateCode(String newCode) {
    state = newCode;
  }
}

final countryCodeProvider = NotifierProvider<CountryCodeNotifier, String>(
  () => CountryCodeNotifier(),
);
