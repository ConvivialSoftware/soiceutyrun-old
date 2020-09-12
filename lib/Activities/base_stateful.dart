import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic> receivedMessage;
final String androidChannelIdVisitor = "1001";
final String androidChannelIdOther = "1002";
final String androidChannelName = "societyrun_channel";
final String androidChannelDesc = "channel_for_gatepass_feature";
const String TYPE_EVENT = "Event";
const String TYPE_MEETING = "Meeting";
const String TYPE_ANNOUNCEMENT = "Announcement";
const String TYPE_ASSIGN_COMPLAINT = "AssignComplaint";
const String TYPE_COMPLAINT = "Complaint";
const String TYPE_VISITOR = "Visitor";
const String TYPE_VISITOR_VERIFY = "Visitor_verify";

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  GatePassPayload gatePassPayload;
  Map data;
  if (Platform.isIOS) {
    data = message;
  } else {
    data = message['data'];
  }
  try {
    String payloadData = data["society"];
    Map<String, dynamic> temp = json.decode(payloadData);
    gatePassPayload = GatePassPayload.fromJson(temp);
  } catch (e) {
    print(e);
  }
  var androidPlatformChannelSpecifics;
  if (gatePassPayload.tYPE == TYPE_VISITOR ||
      gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      androidChannelIdVisitor,
      androidChannelName,
      androidChannelDesc,
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      enableLights: true,
      color: Colors.green,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: true,
      sound: RawResourceAndroidNotificationSound("alert"),
    );
  } else {
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      androidChannelIdOther,
      androidChannelName,
      androidChannelDesc,
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      enableLights: true,
      color: Colors.green,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: true,
    );
  }
  var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: "alert.caf");

  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(
      1, gatePassPayload.title, gatePassPayload.body, platformChannelSpecifics,
      payload: data["society"]);

  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();
  BuildContext _ctx;

  void baseMethod() {

  }

  @override
  void initState() {
    super.initState();
    _fcm.setListeners();
    setState(() {
      _ctx = context;
    });
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('icon_notif');

    var initializationSettingsIOS = IOSInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: false,
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true);

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    _fcm.firebaseMessaging.configure(
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        GlobalVariables.isAlreadyTapped = false;
        print("onMessage >>>> $message");
        _showNotification(message, false);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        _showNotification(message, true);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        _showNotification(message, true);
      },
    );
  }

  Future selectNotification(String payload) async {
    if (!GlobalVariables.isAlreadyTapped) {
      GlobalVariables.isAlreadyTapped = true;
      try {
        Map<String, dynamic> temp = json.decode(payload);
        GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
        if (gatePassPayload.tYPE == TYPE_VISITOR ||
            gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
          _fcm.showAlert(context, gatePassPayload);
        } else {
          navigate(gatePassPayload,_ctx);
        }
      } catch (e) {
        _fcm.showErrorDialog(context, e);
      }
    }
  }

  _showNotification(Map<String, dynamic> message, bool shouldRedirect) {
    GatePassPayload gatePassPayload;
    Map data;
    if (Platform.isIOS) {
      data = message;
    } else {
      data = message['data'] as Map;
    }
    try {
      String payloadData = data["society"];
      Map<String, dynamic> temp = jsonDecode(payloadData);
      gatePassPayload = GatePassPayload.fromJson(temp);
    } catch (e) {
      print(e);
    }
    try {
      if (gatePassPayload.tYPE == TYPE_VISITOR ||
          gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
        _fcm.showAlert(context, gatePassPayload);
      } else {
        if (shouldRedirect) {
          navigate(gatePassPayload,_ctx);
        }
      }
    } catch (e) {
      print(e);
    }
    var androidPlatformChannelSpecifics;
    if (gatePassPayload.tYPE == TYPE_VISITOR ||
        gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        androidChannelIdVisitor,
        androidChannelName,
        androidChannelDesc,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        enableLights: true,
        color: Colors.green,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        playSound: true,
        sound: RawResourceAndroidNotificationSound("alert"),
      );
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        androidChannelIdOther,
        androidChannelName,
        androidChannelDesc,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        enableLights: true,
        color: Colors.green,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        playSound: true,
      );
    }

    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: "alert.caf");
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    try {
      flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
          gatePassPayload.body, platformChannelSpecifics,
          payload: data["society"]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> navigate(GatePassPayload temp,BuildContext context) async {
    if (temp.tYPE == TYPE_COMPLAINT || temp.tYPE == TYPE_ASSIGN_COMPLAINT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_MEETING) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('meetings'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_ANNOUNCEMENT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('announcement'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_EVENT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('events'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
          (Route<dynamic> route) => false);
    }
  }
}
