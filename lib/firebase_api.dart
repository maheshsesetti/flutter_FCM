import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fcm/main.dart';
import 'package:flutter_fcm/notification_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _localNotification = FlutterLocalNotificationsPlugin();

Future<void> handleBackgroundMessage(RemoteMessage? message) async {}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;
  navigatorKey.currentState
      ?.pushNamed(NotifcationScreen.route, arguments: message);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidNotification = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  Future initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            final message = RemoteMessage.fromMap(
                jsonDecode(notificationResponse.payload!));
            handleMessage(message);
            break;
          case NotificationResponseType.selectedNotificationAction:
            final message = RemoteMessage.fromMap(
                jsonDecode(notificationResponse.payload!));
            handleMessage(message);
            break;
        }
      },
    );
    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidNotification);
  }

  Future<void> initPushNotification() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        sound: true, alert: true, badge: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidNotification.id,
              _androidNotification.name,
              channelDescription: _androidNotification.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();

    if (kDebugMode) {
      print(fcmToken);
    }

    initPushNotification();

    initLocalNotification();
  }
}
