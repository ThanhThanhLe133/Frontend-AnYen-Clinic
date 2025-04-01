import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final userProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

final patientProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final response = await Supabase.instance.client
      .from('patients')
      .select()
      .eq('id', user.id)
      .maybeSingle(); // maybeSingle() để tránh lỗi nếu không có dữ liệu

  if (response == null) return null;

  return response;
});
final phoneNumberProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
