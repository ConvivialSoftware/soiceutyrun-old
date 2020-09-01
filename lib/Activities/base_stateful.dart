import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/Models/gatepass_payload_ios.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic> receivedMessage;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  GatePassPayload gatePassPayload;
  if (Platform.isIOS) {
    try {
      String jsonStr = message["notification"]["payload"];
      Map<String, dynamic> temp = json.decode(jsonStr);
      gatePassPayload = GatePassPayload.fromJson(temp);
    } catch (e) {
      print(e);
    }
  } else {
    try {
      String jsonStr = message["data"]["payload"];
      Map<String, dynamic> temp = json.decode(jsonStr);
      gatePassPayload = GatePassPayload.fromJson(temp);
    } catch (e) {
      print(e);
    }
  }

  int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '10001',
    'societyrun_channel',
    'channel_for_gatepass_feature',
    importance: Importance.Max,
    priority: Priority.High,
    ticker: 'ticker',
    enableLights: true,
    color: Colors.green,
    ledColor: const Color.fromARGB(255, 255, 0, 0),
    ledOnMs: 1000,
    ledOffMs: 500,
    playSound: true,
    sound: RawResourceAndroidNotificationSound("noti_ring"),
  );
  var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentAlert: true, presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(msgId, gatePassPayload.title,
      gatePassPayload.body, platformChannelSpecifics,
      payload: Platform.isAndroid
          ? message['data']['payload']
          : message['notification']['payload']);

  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();

  BaseStatefulState() {}

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
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('icon_notif');

    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    _fcm.firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage >>>> $message");
        _showNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        _showNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        _showNotification(message);
      },
    );
  }

  Future selectNotification(String payload) async {
    if (!GlobalVariables.isAlreadyTapped) {
      GlobalVariables.isAlreadyTapped = true;
      try {
        Map<String, dynamic> temp = json.decode(payload);
        GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
        _fcm.showAlert(context, gatePassPayload);
      } catch (e) {
        _fcm.showErrorDialog(context, e);
      }
    }
  }

  _showNotification(Map<String, dynamic> message) {
    GatePassPayload gatePassPayload;
    if (Platform.isIOS) {
      try {
        String jsonStr = message["notification"]["payload"];
        Map<String, dynamic> temp = json.decode(jsonStr);
        gatePassPayload = GatePassPayload.fromJson(temp);
      } catch (e) {
        print(e);
      }
    } else {
      try {
        String jsonStr = message["data"]["payload"];
        Map<String, dynamic> temp = json.decode(jsonStr);
        gatePassPayload = GatePassPayload.fromJson(temp);
      } catch (e) {
        print(e);
      }
    }

    try {
      _fcm.showAlert(context, gatePassPayload);
    } catch (e) {
      _fcm.showErrorDialog(context, e);
    }

    int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '10001', 'societyrun_channel', 'channel_for_gatepass_feature',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        enableLights: true,
        color: Colors.green,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        playSound: true,
        sound: RawResourceAndroidNotificationSound("noti_ring"));
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentAlert: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(msgId, gatePassPayload.title,
        gatePassPayload.body, platformChannelSpecifics,
        payload: Platform.isAndroid
            ? message['data']['payload']
            : message['notification']['payload']);
  }

}
