import 'package:anyen_clinic/OTP_verification/otp_verification_screen.dart';
import 'package:anyen_clinic/appointment/appointment_screen.dart';
import 'package:anyen_clinic/chat/CallScreen.dart';
import 'package:anyen_clinic/chat/chat_screen.dart';
import 'package:anyen_clinic/dashboard/dashboard.dart';
import 'package:anyen_clinic/doctor/details_doctor_screen.dart';
import 'package:anyen_clinic/forgotPass/create_new_pass_screen.dart';
import 'package:anyen_clinic/forgotPass/forgot_pass_screen.dart';
import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/message/message_screen.dart';
import 'package:anyen_clinic/payment/payment_screen.dart';
import 'package:anyen_clinic/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
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
        home: PaymentScreen());
  }
}
