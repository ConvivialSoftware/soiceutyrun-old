import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
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
const String TYPE_FVISITOR = "FVisitor";
const String TYPE_VISITOR_VERIFY = "Visitor_verify";
const String TYPE_POLL = "Poll";
const String TYPE_BILL = "Bill";
const String TYPE_RECEIPT = "Receipt";

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  GatePassPayload gatePassPayload;
  print('myBackgroundMessageHandler before isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
  print("myBackgroundMessageHandler onMessage >>>> $message");
  GlobalVariables.isAlreadyTapped = false;
  print('onMessage myBackgroundMessageHandler after isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
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
  bool isDailyEntryNotification= false;
  bool isGuestEntryNotification= false;
  void baseMethod() {

  }

  @override
  void initState() {
    super.initState();
    _fcm.setListeners();
    setState(()  {
      _ctx = context;
    });
    firebaseCloudMessagingListeners();
  }

  Future<void> firebaseCloudMessagingListeners() async {

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
      onMessage: (Map<String, dynamic> message) async  {
        print('onMessage before isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
        GlobalVariables.isAlreadyTapped = false;
        print('onMessage after isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
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
    print('selectNotification isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
    if (!GlobalVariables.isAlreadyTapped) {
      print('IF selectNotification isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
      GlobalVariables.isAlreadyTapped = true;
      try {
        Map<String, dynamic> temp = json.decode(payload);
        GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
        if (gatePassPayload.tYPE == TYPE_VISITOR ||
            gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
          if(!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME)) {
            _fcm.showAlert(context, gatePassPayload);
          }else{
            navigate(gatePassPayload,_ctx);
          }
        } else {
          navigate(gatePassPayload,_ctx);
        }
      } catch (e) {
        _fcm.showErrorDialog(context, e);
      }
    }
  }

  _showNotification(Map<String, dynamic> message, bool shouldRedirect) async {
    isGuestEntryNotification = await GlobalFunctions.getGuestEntryNotification();
    isDailyEntryNotification = await GlobalFunctions.getDailyEntryNotification();
    GatePassPayload gatePassPayload;
    Map data;
    if (Platform.isIOS) {
      data = message;
    } else {
      data = message['data'] as Map;
    }
    try {
      String payloadSData = data["society"];
      Map<String, dynamic> temp = jsonDecode(payloadSData);
      gatePassPayload = GatePassPayload.fromJson(temp);
    } catch (e) {
      print(e);
    }
    try {
      if (gatePassPayload.tYPE == TYPE_VISITOR ||
          gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) {
        if(!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME)) {
          print('_showNotification isAlreadyTapped : '+ GlobalVariables.isAlreadyTapped.toString());
          if((gatePassPayload.vSITORTYPE==GlobalVariables.GatePass_Taxi || gatePassPayload.vSITORTYPE==GlobalVariables.GatePass_Delivery))  {
            _fcm.showAlert(context, gatePassPayload);
          }else{
            if(isGuestEntryNotification){
              _fcm.showAlert(context, gatePassPayload);
            }
          }
        }
      } else {
        if (shouldRedirect) {
          GlobalVariables.isAlreadyTapped = false;
         // navigate(gatePassPayload,_ctx);
        }
      }
    } catch (e) {
      print(e);
    }
    var androidPlatformChannelSpecifics;
    if ((gatePassPayload.tYPE == TYPE_VISITOR || gatePassPayload.tYPE == TYPE_VISITOR_VERIFY) &&
        !GlobalFunctions.isDateGrater(gatePassPayload.dATETIME) ) {
      print('if showGuestNotification');
      if((gatePassPayload.vSITORTYPE==GlobalVariables.GatePass_Taxi || gatePassPayload.vSITORTYPE==GlobalVariables.GatePass_Delivery)) {
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
      }else{
        print('else showGuestNotification');
        if(isGuestEntryNotification){
          print('else showGuestNotification');
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
          print('else showGuestNotification Alert');
          var iOSPlatformChannelSpecifics =
          IOSNotificationDetails(sound: "alert.caf");
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

          try {
            print('else showGuestNotification TRY');
            flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
                gatePassPayload.body, platformChannelSpecifics,
                payload: data["society"]);
          } catch (e) {
            print('else showGuestNotification CATCH');
            print(e);
          }
        }
      }
    } else {
      if(isDailyEntryNotification) {
        print('if showDailyNotification');
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
    }

  }

  Future<void> navigate(GatePassPayload temp,BuildContext context) async {
    print('context : '+context.toString());
    if (temp.tYPE == TYPE_COMPLAINT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD,false)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_ASSIGN_COMPLAINT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD,true)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == TYPE_MEETING) {
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
    } else if (temp.tYPE == TYPE_POLL) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyComplex(
                      AppLocalizations.of(context).translate('poll_survey'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_VISITOR || temp.tYPE==TYPE_VISITOR_VERIFY) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>BaseMyGate(AppLocalizations.of(context).translate('my_gate'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == TYPE_BILL) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyUnit(
                      AppLocalizations.of(context).translate('my_dues'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == TYPE_RECEIPT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseLedger()));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == TYPE_FVISITOR) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseMyGate(AppLocalizations.of(context).translate('my_gate'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseMyGate(AppLocalizations.of(context).translate('my_gate'))),
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
