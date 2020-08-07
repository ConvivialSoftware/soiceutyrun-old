import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["msgId"]
      .toString()) ?? 0;
  print("msgId $msgId");
  var androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      '10001', 'societyrun_channel',
      'channel_for_gatepass_feature', color: Colors.blue.shade800,
      importance: Importance.Max,
      priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin
      .show(msgId,
      message["data"]["title"],
      message["data"]["REASON"], platformChannelSpecifics,
      payload: message["data"]["data"]);

  return Future<void>.value();

}
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
    _fcm.setListeners();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    var initializationSettingsAndroid = new AndroidInitializationSettings(
        'icon_notif');

    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid,
        initializationSettingsIOS);

    flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
        onSelectNotification: onSelect);


    _fcm.firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        try {
          _fcm.showAlert(context, message);
        } catch (e) {
          _fcm.showErrorDialog(context, e);
        }
      },
    );
  }

  Future<String> onSelect(String data) async {
    print("onSelectNotification $data");
  }
}