import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/DynamicWidgetDialog.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/gatepass_dialog.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/main.dart';

class FirebaseMessagingHandler {
  late final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static bool isInAppCallDialogOpen=false;
  static bool isDynamicDialogOpen=false;

  void setListeners() {
    if (Platform.isIOS) _iOSPermission();

    getToken();

    refreshToken();
  }

  void getToken() {
    firebaseMessaging.getToken().then((token) {
      GlobalFunctions.saveFCMToken(token!);
      print("DEVICE TOKEN >>>> $token");
    });
  }

  void _iOSPermission() {
    //firebaseMessaging.configure();
    firebaseMessaging.requestPermission(sound: true, badge: true, alert: true, provisional: false);
   // firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
  }

  void refreshToken() {
    firebaseMessaging.onTokenRefresh.listen((token) {
    });
  }

  void showAlert(BuildContext context, GatePassPayload payload) {
      _showItemDialog(payload, context);
  }

  void showDynamicAlert(BuildContext context, DBNotificationPayload payload) {
    _showDynamicWidgetDialog(payload, context);
  }

  void showErrorDialog(BuildContext context, dynamic error) {
    // data
  }

  void redirectToPage(Map<String, dynamic> message) {

  }
  void _showItemDialog(GatePassPayload payload,BuildContext context) {
    isInAppCallDialogOpen=true;
    showDialog<bool>(
      context: context,
      builder: (_) =>GatePassDialog(message: payload),
    ).then((bool? shouldNavigate) {
      isInAppCallDialogOpen = false;
      print('after Dialog Close : '+FirebaseMessagingHandler.isInAppCallDialogOpen.toString());
      if (shouldNavigate == true) {

      }
    });
  }

  void _showDynamicWidgetDialog(DBNotificationPayload payload,BuildContext context) {
    isDynamicDialogOpen=true;
    showDialog<bool>(
      context: context,
      builder: (_) =>DynamicWidgetDialog(message: payload),
    ).then((bool? shouldNavigate) {
      isDynamicDialogOpen = false;
      print('after Dialog Close : '+FirebaseMessagingHandler.isDynamicDialogOpen.toString());
      if (shouldNavigate == true) {

      }
    });
  }


}