import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic> receivedMessage;
final String androidChannelId = "1001";
final String androidChannelName = "societyrun_channel";
final String androidChannelDesc = "channel_for_gatepass_feature";

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
    androidChannelId,
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
    sound: RawResourceAndroidNotificationSound("noti_ring"),
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: "alert.caf");
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(msgId, gatePassPayload.title,
      gatePassPayload.body, platformChannelSpecifics,
      payload: Platform.isAndroid
          ? message['data']['payload']
          : message['notification']['payload']);

  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T>  with WidgetsBindingObserver{
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
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    GlobalVariables.isAlreadyTapped = false;
    print("STATE >>>> ${state.toString()}");
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
        _showNotification(message,false);
      },
      onLaunch: (Map<String, dynamic> message) async {
        GlobalVariables.isAlreadyTapped = false;
        print("onLaunch >>>> $message");
        _showNotification(message,true);
      },
      onResume: (Map<String, dynamic> message) async {
        GlobalVariables.isAlreadyTapped = false;
        print("onResume >>>> $message");
        _showNotification(message,true);
      },
    );
  }

  Future selectNotification(String payload) async {
    if (!GlobalVariables.isAlreadyTapped) {
      GlobalVariables.isAlreadyTapped = true;
      try {
        Map<String, dynamic> temp = json.decode(payload);
        GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
        if (gatePassPayload.tYPE == 'Visitor' ||
            gatePassPayload.tYPE == 'Visitor_verify') {
          _fcm.showAlert(context, gatePassPayload);
        } else {
          navigate(gatePassPayload);
        }
      } catch (e) {
        _fcm.showErrorDialog(context, e);
      }
    }
  }

  _showNotification(Map<String, dynamic> message,bool shouldRedirect) {
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
      } else {
        if(shouldRedirect) {
          navigate(gatePassPayload);
        }
      }
    } catch (e) {
      print(e);
    }
    int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        androidChannelId, androidChannelName, androidChannelDesc,
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
        IOSNotificationDetails(sound: "alert.caf");
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    try{
      flutterLocalNotificationsPlugin.show(msgId, gatePassPayload.title,
          gatePassPayload.body, platformChannelSpecifics,
          payload: Platform.isAndroid
              ? message['data']['payload']
              : message['notification']['payload']);
    }catch(e){
      print(e);
    }

  }

  Future<void> navigate(GatePassPayload temp) async {
    if (temp.tYPE == 'Complaint' || temp.tYPE == 'AssignComplaint') {
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
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
          (Route<dynamic> route) => false);
    }
  }
}
