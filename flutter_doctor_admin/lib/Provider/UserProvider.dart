import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final userProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

final phoneNumberProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
