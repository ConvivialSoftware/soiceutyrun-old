import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:societyrun/Activities/Admin.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/NearByShopNotificationItemDetails.dart';
import 'package:societyrun/Activities/OwnerClassifiedNotificationItemDesc.dart';
import 'package:societyrun/Activities/UserManagement.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

//import 'package:societyrun/GlobalClasses/SystemAlertWindow.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/SQLiteDatabase/SQLiteDbProvider.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
//import 'package:system_alert_window/system_alert_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic>? receivedMessage;
final String androidChannelIdVisitor = "1001";
final String androidChannelIdOther = "1002";
final String androidChannelName = "societyrun_channel";
final String androidChannelDesc = "channel_for_gatepass_feature";

//const String TYPE_MANUALLY_STATUS_UPDATE = "manually_status_update";

var androidPlatformChannelSpecificsForVisitor = AndroidNotificationDetails(
  androidChannelIdVisitor,
  androidChannelName,
  androidChannelDesc,
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  enableLights: true,
  color: Colors.green,
  ledColor: const Color.fromARGB(255, 255, 0, 0),
  ledOnMs: 1000,
  ledOffMs: 500,
  playSound: true,
  sound: RawResourceAndroidNotificationSound("alert"),
);

var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  androidChannelIdOther,
  androidChannelName,
  androidChannelDesc,
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
  enableLights: true,
  color: Colors.green,
  ledColor: const Color.fromARGB(255, 255, 0, 0),
  ledOnMs: 1000,
  ledOffMs: 500,
  playSound: true,
);

var iOSPlatformChannelSpecificsForVisitor =
    IOSNotificationDetails(sound: "alert.caf");
var iOSPlatformChannelSpecifics = IOSNotificationDetails();

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  // logger.wtf(message.messageId);
  //
  GlobalVariables.isNewlyArrivedNotification = true;
  //GlobalFunctions.setIsNewlyArrivedNotification(true);
  GatePassPayload gatePassPayload;
  print('myBackgroundMessageHandler before isAlreadyTapped : ' +
      GlobalVariables.isAlreadyTapped.toString());
  /*print('myBackgroundMessageHandler before isNewlyArrivedNotification : ' +
      GlobalVariables.isNewlyArrivedNotification.toString());*/
  print("myBackgroundMessageHandler onMessage >>>> ${message.notification}");
  print("myBackgroundMessageHandler contentAvailable >>>> ${message.contentAvailable}");
  print("myBackgroundMessageHandler sentTime >>>> ${message.sentTime.toString()}");
  Map data;
  /*Map notification;
  notification = message["notification"];
  notification["click_action"]="FLUTTER_NOTIFICATION_CLICK";*/
  GlobalFunctions.setNotificationBackGroundData(message.toString());
  print("After myBackgroundMessageHandler onMessage >>>> ${message.data.toString()}");
  if (Platform.isIOS) {
    data = message.data;
  } else {
    data = message.data;
  }
  try {
    String uuid = Uuid().v1();
    String payloadData = data["society"];
    Map<String, dynamic> society;
    society = json.decode(payloadData.toString());
    society["isBackGround"] = true;
    society["msgID"] = uuid;
    gatePassPayload = GatePassPayload.fromJson(society);
    if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
      DBNotificationPayload _dbNotificationPayload =
          DBNotificationPayload.fromJson(society);
      _dbNotificationPayload.nid = uuid;
      SQLiteDbProvider.db.insertUnReadNotification(_dbNotificationPayload);

      var platformChannelSpecifics = NotificationDetails(
          android: (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
                  gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY)
              ? !GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!) ? androidPlatformChannelSpecificsForVisitor
              : androidPlatformChannelSpecifics : androidPlatformChannelSpecifics,
          iOS: (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
                  gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY)
              ? iOSPlatformChannelSpecificsForVisitor
              : iOSPlatformChannelSpecifics);
      GlobalVariables.isAlreadyTapped = false;
      print('onMessage myBackgroundMessageHandler after isAlreadyTapped : ' +
          GlobalVariables.isAlreadyTapped.toString());
      if(gatePassPayload.tYPE != NotificationTypes.TYPE_VISITOR_VERIFY) {
        Random random = new Random();
        print('generate background randomNumber : ');
        flutterLocalNotificationsPlugin.show(random.nextInt(20), gatePassPayload.title,
          gatePassPayload.body, platformChannelSpecifics,
            payload: json.encode(society));
      }
    }
  } catch (e) {
    print(e);
  }
//  SystemAlertOverlayWindow.showOverLayWindow(false,SystemWindowPrefMode.OVERLAY);
  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();
  static BuildContext? _ctx;
  bool isDailyEntryNotification = false;
  bool isGuestEntryNotification = false;
  bool isInAppCallNotification = false;
  Random random = new Random();
  int randomNumber=1;

/*
  String _platformVersion = 'Unknown';
  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;

*/

  static BuildContext get getCtx => _ctx!;
  static const MethodChannel _channel = MethodChannel('com.societyrun12/create_channel');

  static void setCtx(BuildContext currentContext) {
    _ctx = currentContext;
  }

  void baseMethod() {}

  @override
  void initState() {
    super.initState();
    print('call base init');
    _fcm.setListeners();
    setState(() {
      _ctx = this.context;
    });
    firebaseCloudMessagingListeners();
    createNotificationChannel();
   /* _initPlatformState();
    _requestPermissions();
    SystemAlertWindow.registerOnClickListener(SystemAlertOverlayWindow.callBackFunction);*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctx = this.context;
    print('didChangeDependencies : ' + context.toString());
    if (!mounted) {
      print('UnMounted : ' + mounted.toString());
      print('UnMounted context : ' + context.toString());
    } else {
      print('Mounted : ' + mounted.toString());
      print('Mounted context : ' + context.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

/*
  Future<void> _initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await SystemAlertWindow.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }*/

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
        android:initializationSettingsAndroid, iOS:initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    var details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      print("didNotificationLaunchApp :"+details.payload.toString());
      selectNotification(details.payload);
    }

    FirebaseMessaging.onMessage.listen((message) {
      randomNumber = random.nextInt(20);
      print('randomNumber : '+randomNumber.toString());
      print('onMessage:message.toString()');
      logger.wtf('notification:${message.notification?.body??'NO BODY'}');
      logger.wtf('notification:${message.notification?.title??'TITLE'}');
      GlobalVariables.isNewlyArrivedNotification = true;
      GlobalVariables.isAlreadyTapped = false;
      _showNotification(message.data, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('onMessageOpened: ${message}');
      GlobalVariables.isNewlyArrivedNotification = true;
      GlobalVariables.isAlreadyTapped = false;
      showDialogAlertOnOpen(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      print('onInitialMessage: $value');
      showDialogAlertOnOpen(value!.data);
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    /*_fcm.firebaseMessaging.configure(
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage before isAlreadyTapped : ' +
            GlobalVariables.isAlreadyTapped.toString());
        GlobalVariables.isAlreadyTapped = false;
        print('onMessage after isAlreadyTapped : ' +
            GlobalVariables.isAlreadyTapped.toString());
        print("onMessage >>>> $message");
        GlobalVariables.isNewlyArrivedNotification = true;
        //GlobalFunctions.setIsNewlyArrivedNotification(true);
        _showNotification(message, false);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch >>>> $message");
        GlobalVariables.isNewlyArrivedNotification = true;
        //GlobalFunctions.setIsNewlyArrivedNotification(true);
        //GlobalFunctions.showToast("onLaunch");
        _showNotification(message, true);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        GlobalVariables.isNewlyArrivedNotification = true;
        //GlobalFunctions.setIsNewlyArrivedNotification(true);
        //GlobalFunctions.showToast("OnResume");
        _showNotification(message, true);
      },
    );*/
  }
  showDialogAlertOnOpen(Map<String, dynamic> message) {

    String payloadSData = message["society"];
   var society = json.decode(payloadSData.toString());
    GatePassPayload gatePassPayload = GatePassPayload.fromJson(society);
    if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
        gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
      if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
        _fcm.showAlert(_ctx!, gatePassPayload);
      }
    }
  }

  Future selectNotification(String? payload) async {
    print('selectNotification context : ' + _ctx.toString());
    print('In selectNotification method');
    try {
      // bool isNewlyArrivedNotification = await GlobalFunctions.getIsNewlyArrivedNotification();
      //print('sharedPref isNewlyArrivedNotification : '+isNewlyArrivedNotification.toString());
      //await flutterLocalNotificationsPlugin.cancel(1);
      isGuestEntryNotification =
      await GlobalFunctions.getGuestEntryNotification();
      isDailyEntryNotification =
      await GlobalFunctions.getDailyEntryNotification();
      isInAppCallNotification =
      await GlobalFunctions.getInAppCallNotification();
      String userId = await GlobalFunctions.getUserId();

      Map<String, dynamic> temp = json.decode(payload!);
      GatePassPayload gatePassPayload = GatePassPayload.fromJson(temp);
      print('selectNotification isNewlyArrivedNotification : ' +
        GlobalVariables.isNewlyArrivedNotification.toString());
      print('selectNotification isAlreadyTapped : ' +
          GlobalVariables.isAlreadyTapped.toString());
      print('selectNotification isBackGround : ' +
          gatePassPayload.isBackGround.toString());

      DBNotificationPayload _dbNotificationPayload =
          DBNotificationPayload.fromJson(temp);
      _dbNotificationPayload.nid = gatePassPayload.msgID;
      _dbNotificationPayload.read = 1;
      _dbNotificationPayload.uid = userId;
      SQLiteDbProvider.db.updateReadNotification(_dbNotificationPayload);

      if (GlobalVariables.isNewlyArrivedNotification) {
        GlobalVariables.isNewlyArrivedNotification = false;
        //GlobalFunctions.setIsNewlyArrivedNotification(false);
        if (gatePassPayload.isBackGround!) {
          GlobalVariables.isAlreadyTapped = false;
        }
      }else{
        if (gatePassPayload.isBackGround!) {
          GlobalVariables.isAlreadyTapped = false;
        }
      }
      if (!GlobalVariables.isAlreadyTapped) {
        print('IF selectNotification isAlreadyTapped : ' +
            GlobalVariables.isAlreadyTapped.toString());
        GlobalVariables.isAlreadyTapped = true;

        if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
            gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
          if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
            if(isInAppCallNotification) {
              _fcm.showAlert(_ctx!, gatePassPayload);
            }else{
              navigate(gatePassPayload, _ctx!);
            }
          } else {
            navigate(gatePassPayload, _ctx!);
          }
        }else if(gatePassPayload.tYPE == NotificationTypes.TYPE_BROADCAST){
          _fcm.showDynamicAlert(_ctx!, _dbNotificationPayload);
        } else {
          print('IF selectNotification gatePassPayload.tYPE : ' +
              gatePassPayload.tYPE.toString());
          navigate(gatePassPayload, _ctx!);
        }
      }
    } catch (e) {
      print('exception : ' + e.toString());
      _fcm.showErrorDialog(_ctx!, e);
    }
  }

  _showNotification(Map<String, dynamic> message, bool shouldRedirect,
      {bool showLocalNotification = true}) async {

    //SystemAlertOverlayWindow.showOverLayWindow(_isShowingWindow,prefMode);
    print('_showNotification context : ' + _ctx.toString());
    // bool isNewlyArrivedNotification =
    //await GlobalFunctions.getIsNewlyArrivedNotification();
    //print('sharedPref isNewlyArrivedNotification : '+isNewlyArrivedNotification.toString());
    isGuestEntryNotification =
        await GlobalFunctions.getGuestEntryNotification();
    isDailyEntryNotification =
        await GlobalFunctions.getDailyEntryNotification();
    isInAppCallNotification =
        await GlobalFunctions.getInAppCallNotification();
    print('isDailyEntryNotification : ' + isDailyEntryNotification.toString());
    print('isGuestEntryNotification : ' + isGuestEntryNotification.toString());
    print('isInAppCallyNotification : ' + isInAppCallNotification.toString());
    print("After _showNotification onMessage >>>> $message");
    GatePassPayload gatePassPayload;
    Map data;
    /*Map notification;
    notification = message["notification"];
    notification["click_action"]="FLUTTER_NOTIFICATION_CLICK";*/
    GlobalFunctions.setNotificationBackGroundData(message.toString());
    if (Platform.isIOS) {
      data = message;
    } else {
      data = message;
    }
    try {
      String uuid = Uuid().v1();
      String payloadSData = data["society"];
      Map<String, dynamic> society;
      society = json.decode(payloadSData.toString());
      society["isBackGround"] = shouldRedirect;
      society["msgID"] = uuid;
      // Map<String, dynamic> temp = jsonDecode(society.toString());
      gatePassPayload = GatePassPayload.fromJson(society);

      print('_showNotification isAlreadyTapped : ' + GlobalVariables.isAlreadyTapped.toString());
      print('_showNotification isBackGround : ' +
          gatePassPayload.isBackGround.toString());
      if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
        print('_showNotification isNewlyArrivedNotification : ' + GlobalVariables.isNewlyArrivedNotification.toString());
        print('If shouldRedirect: ' + shouldRedirect.toString());
        if(GlobalVariables.isNewlyArrivedNotification) {
          GlobalVariables.isNewlyArrivedNotification = false;
          DBNotificationPayload _dbNotificationPayload =
          DBNotificationPayload.fromJson(society);
          _dbNotificationPayload.nid = uuid;
          SQLiteDbProvider.db.insertUnReadNotification(_dbNotificationPayload);
        }
      }
      if (!gatePassPayload.isBackGround!) {
      //  if (GlobalVariables.isNewlyArrivedNotification) {
         // GlobalVariables.isNewlyArrivedNotification = false;
          //GlobalFunctions.setIsNewlyArrivedNotification(false);
          try {
            if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
                gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
            if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
                print('_showNotification isAlreadyTapped : ' +
                    GlobalVariables.isAlreadyTapped.toString());
                if ((gatePassPayload.vSITORTYPE ==
                    GlobalVariables.GatePass_Taxi ||
                    gatePassPayload.vSITORTYPE ==
                        GlobalVariables.GatePass_Delivery)) {
                  if (isInAppCallNotification) {
                  _fcm.showAlert(_ctx!, gatePassPayload);
                  }
                } else {
                  if (isGuestEntryNotification) {
                    if (isInAppCallNotification) {
                    _fcm.showAlert(_ctx!, gatePassPayload);
                    }
                  }
                }
              }
            } else {
              if (shouldRedirect) {
                GlobalVariables.isAlreadyTapped = false;
                // navigate(gatePassPayload,_ctx);
              }
              if (gatePassPayload.tYPE == NotificationTypes.TYPE_SInApp) {
                print('before : ' +
                    FirebaseMessagingHandler.isInAppCallDialogOpen.toString());
                if (FirebaseMessagingHandler.isInAppCallDialogOpen) {
                  Navigator.of(context).pop();
                }
                print('after : ' +
                    FirebaseMessagingHandler.isInAppCallDialogOpen.toString());
              }
            }
          } catch (e) {
            print(e);
          }
          if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
            if ((gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
                gatePassPayload.tYPE ==
                    NotificationTypes.TYPE_VISITOR_VERIFY) &&
              !GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
              print('if showGuestNotification');
              if (!isInAppCallNotification) {
                print('false isInAppCallNotification');
                var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecifics,
                    iOS: iOSPlatformChannelSpecifics);

                try {
                if(showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(randomNumber, gatePassPayload.title,
                      gatePassPayload.body, platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
                }
                } catch (e) {
                  print(e);
                }
              }
              else if ((gatePassPayload.vSITORTYPE ==
                  GlobalVariables.GatePass_Taxi ||
                  gatePassPayload.vSITORTYPE ==
                      GlobalVariables.GatePass_Delivery)) {
                var platformChannelSpecifics = NotificationDetails(
                  android: androidPlatformChannelSpecificsForVisitor,
                  iOS: iOSPlatformChannelSpecificsForVisitor);

                try {
                if(showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(randomNumber, gatePassPayload.title,
                      gatePassPayload.body, platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
                }
                } catch (e) {
                  print(e);
                }
              } else {
                print('else showGuestNotification');
                if (isGuestEntryNotification) {
                  print('else showGuestNotification');
                  var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecificsForVisitor,
                    iOS: iOSPlatformChannelSpecificsForVisitor);

                  try {
                    print('else showGuestNotification TRY');
                  if(showLocalNotification) {
                    flutterLocalNotificationsPlugin.show(
                        randomNumber, gatePassPayload.title,
                        gatePassPayload.body, platformChannelSpecifics,
                        payload: /*data["society"]*/ json.encode(society));
                  }
                  } catch (e) {
                    print('else showGuestNotification CATCH');
                    print(e);
                  }
                }
              }
            }
            else {
              if (isDailyEntryNotification) {
                print('if showDailyNotification');
                var platformChannelSpecifics = NotificationDetails(
                    android: androidPlatformChannelSpecifics,
                    iOS: iOSPlatformChannelSpecifics);

                try {
                if(showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(randomNumber, gatePassPayload.title,
                      gatePassPayload.body, platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
                }
                } catch (e) {
                  print(e);
                }
              }
            }
          }
        //}
      }else{
       // if(GlobalVariables.isNewlyArrivedNotification) {
         // GlobalVariables.isNewlyArrivedNotification = false;
          selectNotification(payloadSData);
       // }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> navigate(GatePassPayload temp, BuildContext context) async {
    print('context : ' + context.toString());
    if (temp.tYPE == NotificationTypes.TYPE_COMPLAINT) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD!, false)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_ASSIGN_COMPLAINT) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD!, true)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_MEETING) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('meetings'))));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_ANNOUNCEMENT) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('announcement'))));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_EVENT) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('events'))));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_Document) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('documents'))));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_POLL) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('poll_survey'))));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_VISITOR ||
        temp.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_BILL) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseViewBill(temp.iD!, null, null, null)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_RECEIPT) {
      //String block = await GlobalFunctions.getBlock();
      //String flat = await GlobalFunctions.getFlat();
      /*final result = await */Navigator.push(context,
          MaterialPageRoute(builder: (context) => BaseViewReceipt(temp.iD!, null, null, null)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_FVISITOR) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_SInApp) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_NEW_OFFER) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseNearByShopNotificationItemDetails(temp.iD!)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_INTERESTED_CUSTOMER) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseOwnerClassifiedNotificationItemDesc(temp.iD!)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_UserManagement) {
      /*final result = await */Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => BaseUserManagement()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_MyHousehold) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAdmin()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_PaymentRequest) {
      /*final result = await */Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAdmin()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_Expense) {
      /*final result = await */Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => BaseExpenseSearchAdd()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }*/
    }else if (temp.tYPE == NotificationTypes.TYPE_WEB) {
      launch(GlobalVariables.appURL);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> createNotificationChannel() async {

    Map<String, String> channelMap = {
      "id": androidChannelIdVisitor,
      "name": androidChannelName,
      "description": androidChannelDesc,
    };
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
      setState(() {
        //_statusText = _finished;
      });
    } on PlatformException catch (e) {
      //_statusText = _error;
      print('createNotificationChannel'+e.toString());
    }

  }
}
