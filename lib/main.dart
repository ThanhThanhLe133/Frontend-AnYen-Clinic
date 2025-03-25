import 'package:anyen_clinic/chat/chat_screen.dart';
import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jqbpguplezywjemitmna.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxYnBndXBsZXp5d2plbWl0bW5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NDgxNTksImV4cCI6MjA1NjAyNDE1OX0.zbE38vdeJg-10mZoH7zd4EiwkS_ZhWdisYiMseDK5mM',
  );
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Inter-Medium',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ),
      ),
      home: Dashboard(),
    );
  }
}
