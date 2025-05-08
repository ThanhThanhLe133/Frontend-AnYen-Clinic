import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Thiết lập hệ thống thông báo nếu chưa được thiết lập
  await NotificationService.instance.setupFlutterNotification();

  // Hiển thị thông báo với nội dung nhận được
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final message = FirebaseMessaging.instance;
  final localNotifications = FlutterLocalNotificationsPlugin();
  bool isFlutterNotificationInitialized = false;
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await requestPermission();
    await setupMessaheHandlers();

    final token = await message.getToken();
    print('FCM Token: $token');
  }

  Future<void> requestPermission() async {
    final settings = await message.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);
  }

  Future<void> setupFlutterNotification() async {
    if (isFlutterNotificationInitialized) return;

    const channel = AndroidNotificationChannel(
        'high_importance_channel', 'High Importantance Notifications',
        description: 'This channel is used for important notifications',
        importance: Importance.high);

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

//android
    const initializeSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
//ios
    const initializeSettingsIos = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
        android: initializeSettingsAndroid, iOS: initializeSettingsIos);

    await localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: (details) {});

    isFlutterNotificationInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await localNotifications.show(
        notification.hashCode,
        notification.title, // 🔧 nên hiển thị title thay vì chỉ body
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(), // Có thể truyền thêm thông tin
      );
    }
  }

  Future<void> setupMessaheHandlers() async {
    //foreground mess
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    //background mess
    FirebaseMessaging.onMessageOpenedApp.listen(handelBackgroundMessage);

    //open app
    final initMeassage = await message.getInitialMessage();
    if (initMeassage != null) {
      handelBackgroundMessage(initMeassage);
    }
  }

  void handelBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      //open chat screen
    }
  }
}
