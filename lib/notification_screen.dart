import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotifcationScreen extends StatelessWidget {
  const NotifcationScreen({super.key});

  static const route = '/notificationScreen';

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const Text("Push Notifcation"), 
          Text('${message.notification?.title}'),
          Text('${message.notification?.body}'),
          Text('${message.data}'),
          ],
        ),
      ),
    );
  }
}
