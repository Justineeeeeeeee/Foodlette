import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodlettemobile/main.dart';

class FirebaseApi {
  final _firebasemessaging = FirebaseMessaging.instance;

  final _androidChannel = AndroidNotificationChannel(
    'foodlette_channel',
    'Foodlette Channel',
    description: 'Foodlette Channel Description',
    importance: Importance.defaultImportance,
  );
  final _localNotification = FlutterLocalNotificationsPlugin();

  Future<void> getFirebaseToken() async {
    await _firebasemessaging
        .requestPermission(); // request permission for notification

    final fCMtoken = await _firebasemessaging.getToken(); // get token

    print('FCM Token: $fCMtoken');

    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    message = message?.data.isNotEmpty == true ? message : null;
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((Message) {});
  }
}
