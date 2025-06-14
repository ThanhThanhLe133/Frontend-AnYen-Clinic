import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineAppointmentNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setValue(int value) => state = value;
}

class OfflineAppointmentNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setValue(int value) => state = value;
}

// Khai báo provider
final onlineAppointmentProvider =
    NotifierProvider<OnlineAppointmentNotifier, int>(
        () => OnlineAppointmentNotifier());

final offlineAppointmentProvider =
    NotifierProvider<OfflineAppointmentNotifier, int>(
        () => OfflineAppointmentNotifier());
