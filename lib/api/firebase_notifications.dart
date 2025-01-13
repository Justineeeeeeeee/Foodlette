import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foodlettemobile/main.dart';

class FirebaseApi {
  final _firebasemessaging = FirebaseMessaging.instance;

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
  }
}
