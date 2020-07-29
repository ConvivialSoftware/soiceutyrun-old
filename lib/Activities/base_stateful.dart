import 'package:flutter/material.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

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
    firebaseCloudMessagingListeners();
  }
  void firebaseCloudMessagingListeners() {

    _fcm.firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        try {
          _fcm.redirectToPage(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        try {
          _fcm.redirectToPage(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
    );
  }
}