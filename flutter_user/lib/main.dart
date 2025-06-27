import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/notification_service.dart';
import 'package:anyen_clinic/posts/list_post_screen.dart';
import 'package:anyen_clinic/splash/splash_screen.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await dotenv.load(fileName: "assets/config/.env");

  await Firebase.initializeApp();
  await NotificationService.instance.initialize();

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
