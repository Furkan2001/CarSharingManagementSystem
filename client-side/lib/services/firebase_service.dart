import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import 'auth_service.dart';
import '../utils/main_link.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? Message) {
    if (Message == null) return;
    if (Message.notification?.title == "İstek Bildirimi") {
      navigatorKey.currentState?.pushNamed('/my_requests');
    } else {
      navigatorKey.currentState?.pushNamed('/messages');
    }
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initNotifications() async {
    print("hi\n");
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    if (fCMToken != null) {
      await sendTokenToBackend(
          userId: AuthService().userId ?? -1, deviceToken: fCMToken);
    }

    initPushNotifications();
  }

  Future<void> sendTokenToBackend({
    required int userId,
    required String deviceToken,
  }) async {
    print("UserId");
    print(userId);
    final String link = MainLink().url;
    final String apiUrl =
        'http://$link:3000/api/Users/save-device-token?userId=$userId&deviceToken=$deviceToken';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Token successfully sent to backend.');
      } else {
        print('Failed to send token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error sending token to backend: $error');
    }
  }
}
