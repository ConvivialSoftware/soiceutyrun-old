import 'package:flutter/material.dart';
import 'package:societyrun/firebase_notification/firebase_background_message_handle.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print(data);
    final _fcm = FirebaseMessagingHandler();
    _fcm.redirectToPage(message);
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    final _fcm = FirebaseMessagingHandler();
    _fcm.redirectToPage(message);
  }

  // Or do other work.
}
abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();
  BaseStatefulState() {

  }

  void baseMethod() {
    // Parent method
  }
  @override
  void initState() {
    super.initState();
    _fcm.setListeners();
    firebaseCloudMessagingListeners();
  }
  void firebaseCloudMessagingListeners() {

    _fcm.firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
    );
  }
}