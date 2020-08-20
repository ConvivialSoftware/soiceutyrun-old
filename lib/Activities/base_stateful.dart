import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '10001', 'societyrun_channel', 'channel_for_gatepass_feature',
      color: Colors.blue.shade800,
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker');
  var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentAlert: true, presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  if (message["data"]["TYPE"] == 'Visitor' ||
      message["data"]["TYPE"] == 'Visitor_verify') {
    flutterLocalNotificationsPlugin.show(msgId, message["data"]["title"],
        message["data"]["REASON"], platformChannelSpecifics,
        payload: message['data']["data"]);
  } else {
    flutterLocalNotificationsPlugin.show(msgId, message["data"]["title"],
        message["data"]["body"], platformChannelSpecifics,
        payload: message['data']['ID']);
  }

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
//      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage >>>> $message");
        _showNotification(message);
        if (message["data"]["TYPE"] == 'Visitor' ||
            message["data"]["TYPE"] == 'Visitor_verify') {
          callVisitorDialog(context, message);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        _showNotification(message);
        if (message["data"]["TYPE"] == 'Visitor' ||
            message["data"]["TYPE"] == 'Visitor_verify') {
          callVisitorDialog(context, message);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        _showNotification(message);
        if (message["data"]["TYPE"] == 'Visitor' ||
            message["data"]["TYPE"] == 'Visitor_verify') {
          callVisitorDialog(context, message);
        }
      },
    );
  }

  Future selectNotification(String payload) async {
    print("TAPPED >>>>" + payload.toString());
    if (payload != null) {
    //debugPrint('notification payload: ' + payload);
    //final map = jsonDecode(payload) as Map<String, dynamic>;
  //  print("RESPONSE >>>>" + map['data']["ID"]);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseComplaintInfoAndComments.ticketNo(payload)));
    }
  }

  _showNotification(Map<String, dynamic> message) {
    int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '10001', 'societyrun_channel', 'channel_for_gatepass_feature',
        color: Colors.blue.shade800,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentAlert: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print('payload message>>>> :' + message['data']["data"].toString());

    if (message["data"]["TYPE"] == 'Visitor' ||
        message["data"]["TYPE"] == 'Visitor_verify') {
      flutterLocalNotificationsPlugin.show(msgId, message["data"]["title"],
          message["data"]["REASON"], platformChannelSpecifics,
          payload: message['data']["data"]);
    } else {
      flutterLocalNotificationsPlugin.show(msgId, message["data"]["title"],
          message["data"]["body"], platformChannelSpecifics,
          payload: message['data']['ID']);
    }
  }

  void callVisitorDialog(BuildContext context, Map<String, dynamic> message) {
    try {
      _fcm.showAlert(context, message);
    } catch (e) {
      _fcm.showErrorDialog(context, e);
    }
  }
}
