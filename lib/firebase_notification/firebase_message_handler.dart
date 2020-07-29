import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/gatepass_dialog.dart';

class FirebaseMessagingHandler {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void setListeners() {
    if (Platform.isIOS) _iOSPermission();

    getToken();

    refreshToken();
  }

  void getToken() {
    firebaseMessaging.getToken().then((token) {
      print('DeviceToken = $token');
    });
  }

  void _iOSPermission() {
    firebaseMessaging.configure();
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
    });
  }

  void refreshToken() {
    firebaseMessaging.onTokenRefresh.listen((token) {
    });
  }

  void showAlert(BuildContext context, Map<String, dynamic> message) {
    _showItemDialog(message, context);
  }

  void showErrorDialog(BuildContext context, dynamic error) {
    // data
  }

  void redirectToPage(BuildContext context, Map<String, dynamic> message) {
    // data
  }
  void _showItemDialog(Map<String, dynamic> message,BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) =>GatePassDialog(message: message,),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {

      }
    });
  }


}