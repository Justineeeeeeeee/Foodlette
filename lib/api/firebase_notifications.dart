import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebasemessaging = FirebaseMessaging.instance;

  Future<void> getFirebaseToken() async {
    await _firebasemessaging
        .requestPermission(); // request permission for notification

    final fCMtoken = await _firebasemessaging.getToken(); // get token

    print('FCM Token: $fCMtoken');
  }
}
