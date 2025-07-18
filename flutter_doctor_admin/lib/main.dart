import 'package:ayclinic_doctor_admin/ADMIN/dashboard_admin/dashboard.dart';
import 'package:ayclinic_doctor_admin/DOCTOR/dashboard_doctor/dashboard.dart';
import 'package:ayclinic_doctor_admin/login/login_screen.dart';
import 'package:ayclinic_doctor_admin/notification_service.dart';
import 'package:ayclinic_doctor_admin/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await dotenv.load(fileName: "assets/config/.env");
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  final bool isLoggedIn = await getLogin();
  final bool isDoctor = await getDoctorState();
  final bool isAdmin = await getAdminState();

  runApp(ProviderScope(
      child: MainApp(
          isLoggedIn: isLoggedIn, isDoctor: isDoctor, isAdmin: isAdmin)));
}

class MainApp extends StatelessWidget {
  const MainApp(
      {super.key,
      required this.isLoggedIn,
      required this.isDoctor,
      required this.isAdmin});
  final bool isLoggedIn;
  final bool isDoctor;
  final bool isAdmin;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
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
      home: !isLoggedIn
          ? const SplashScreen()
          : isDoctor
              ? DashboardDoctor()
              : DashboardAdmin(),
      // home: LoginScreen(),
    );
  }
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
