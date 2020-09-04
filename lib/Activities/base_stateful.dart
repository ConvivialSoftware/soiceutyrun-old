import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
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

  if(gatePassPayload.tYPE=='Visitor' || gatePassPayload.tYPE=='Visitor_verify') {
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
  }else{
    int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '10002',
      'societyrun_channel',
      'channel_for_complaint_feature',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      enableLights: true,
      color: Colors.green,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: false,
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
    print('isTap : ' + GlobalVariables.isAlreadyTapped.toString());
    GlobalFunctions.getLoginValue().then((value) {
      if (value) {
        Map<String, dynamic> temp = json.decode(payload);
        if (!GlobalVariables.isAlreadyTapped) {
          GlobalVariables.isAlreadyTapped = true;
          try {
            if (temp['TYPE'] == 'Visitor' || temp['TYPE'] == 'Visitor_verify') {
              GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
              _fcm.showAlert(context, gatePassPayload);
            } else {
              navigate(temp);
            }
          } catch (e) {
            _fcm.showErrorDialog(context, e);
          }
        }
      }
    });
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
      if (gatePassPayload.tYPE == 'Visitor' ||
          gatePassPayload.tYPE == 'Visitor_verify') {
        _fcm.showAlert(context, gatePassPayload);
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
      } else {
        String jsonStr = message["data"]["payload"];
        Map<String, dynamic> temp = json.decode(jsonStr);
        gatePassPayload = GatePassPayload.fromJson(temp);
        int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          '10002',
          'societyrun_channel',
          'channel_for_complaint_feature',
          importance: Importance.Max,
          priority: Priority.High,
          ticker: 'ticker',
          enableLights: true,
          color: Colors.green,
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          playSound: false,
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
      }
    } catch (e) {
      _fcm.showErrorDialog(context, e);
    }
  }

  Future<void> navigate(Map<String, dynamic> temp) async {
    print('navigate to page');
    print(temp['TYPE'].toString());
    if (temp['TYPE'] == 'Complaint' || temp['TYPE'] == 'AssignComplaint') {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp['ID'])));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }
    else if (temp['TYPE'] == 'Announcement') {
      final result = await  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('announcement'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }
    else if (temp['TYPE'] == 'Event') {
      final result = await  Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseMyComplex(AppLocalizations.of(context).translate('events'))));

      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }
    else if (temp['TYPE'] == 'Meeting') {
      final result = await   Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('meetings'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else{
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
                  BaseDashBoard()),
              (Route<dynamic> route) => false);
    }
  }
}
