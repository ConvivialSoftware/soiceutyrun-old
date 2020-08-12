import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/gatepass_dialog.dart';
import 'package:societyrun/Models/gatepass_payload.dart';

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

  void showAlert(BuildContext context, GatePassPayload payload) {
    _showItemDialog(payload, context);
  }

  void showErrorDialog(BuildContext context, dynamic error) {
    // data
  }

  void redirectToPage(Map<String, dynamic> message) {

  }
  void _showItemDialog(GatePassPayload payload,BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) =>GatePassDialog(message: payload),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {

      }
    });
  }


}