import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  final bool isLoggedIn = await getLogin();
  runApp(ProviderScope(child: MainApp(isLoggedIn: isLoggedIn)));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
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
