import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/Admin.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/NearByShopNotificationItemDetails.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/Activities/OwnerClassifiedNotificationItemDesc.dart';
import 'package:societyrun/Activities/OwnerDiscover.dart';
import 'package:societyrun/Activities/UserManagement.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Models/NearByShopResponse.dart';
import 'package:societyrun/Models/gatepass_payload.dart';
import 'package:societyrun/SQLiteDatabase/SQLiteDbProvider.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic> receivedMessage;
final String androidChannelIdVisitor = "1001";
final String androidChannelIdOther = "1002";
final String androidChannelName = "societyrun_channel";
final String androidChannelDesc = "channel_for_gatepass_feature";

//const String TYPE_MANUALLY_STATUS_UPDATE = "manually_status_update";

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  GlobalVariables.isNewlyArrivedNotification = true;
  //GlobalFunctions.setIsNewlyArrivedNotification(true);
  GatePassPayload gatePassPayload;
  print('myBackgroundMessageHandler before isAlreadyTapped : ' +
      GlobalVariables.isAlreadyTapped.toString());
  /*print('myBackgroundMessageHandler before isNewlyArrivedNotification : ' +
      GlobalVariables.isNewlyArrivedNotification.toString());*/
  print("myBackgroundMessageHandler onMessage >>>> $message");
  Map data;
  if (Platform.isIOS) {
    data = message;
  } else {
    data = message['data'];
  }
  try {
    String uuid = Uuid().v1();
    String payloadData = data["society"];
    Map society;
    society = json.decode(payloadData.toString());
    society["isBackGround"] = true;
    society["msgID"] = uuid;
    gatePassPayload = GatePassPayload.fromJson(society);
    if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
      DBNotificationPayload _dbNotificationPayload =
          DBNotificationPayload.fromJson(society);
      _dbNotificationPayload.nid = uuid;
      SQLiteDbProvider.db.insertUnReadNotification(_dbNotificationPayload);

      var androidPlatformChannelSpecifics;
      if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
          gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
      } else {
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
      }
      var iOSPlatformChannelSpecifics =
          IOSNotificationDetails(sound: "alert.caf");

      var platformChannelSpecifics = NotificationDetails(
           android : androidPlatformChannelSpecifics, iOS:iOSPlatformChannelSpecifics);
      GlobalVariables.isAlreadyTapped = false;
      print('onMessage myBackgroundMessageHandler after isAlreadyTapped : ' +
          GlobalVariables.isAlreadyTapped.toString());
      flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
          gatePassPayload.body, platformChannelSpecifics,
          payload: /*data["society"]*/ json.encode(society));
    }
  } catch (e) {
    print(e);
  }
  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();
  static BuildContext _ctx;
  bool isDailyEntryNotification = false;
  bool isGuestEntryNotification = false;
  bool isInAppCallNotification = false;

  static BuildContext get getCtx => _ctx;

  static void setCtx(BuildContext currentContext) {
    _ctx = currentContext;
  }

  void baseMethod() {}

  @override
  void initState() {
    super.initState();
    _fcm.setListeners();
    setState(() {
      _ctx = this.context;
    });
    firebaseCloudMessagingListeners();
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

    _fcm.firebaseMessaging.configure(
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
        _showNotification(message, true);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume >>>> $message");
        GlobalVariables.isNewlyArrivedNotification = true;
        //GlobalFunctions.setIsNewlyArrivedNotification(true);
        _showNotification(message, true);
      },
    );
  }

  Future selectNotification(String payload) async {
    print('selectNotification context : ' + _ctx.toString());
    print('In selectNotification method');
    try {
      // bool isNewlyArrivedNotification = await GlobalFunctions.getIsNewlyArrivedNotification();
      //print('sharedPref isNewlyArrivedNotification : '+isNewlyArrivedNotification.toString());

      isGuestEntryNotification =
      await GlobalFunctions.getGuestEntryNotification();
      isDailyEntryNotification =
      await GlobalFunctions.getDailyEntryNotification();
      isInAppCallNotification =
      await GlobalFunctions.getInAppCallNotification();
      String userId = await GlobalFunctions.getUserId();

      Map<String, dynamic> temp = json.decode(payload);
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
        if (gatePassPayload.isBackGround) {
          GlobalVariables.isAlreadyTapped = false;
        }
      }
      if (!GlobalVariables.isAlreadyTapped) {
        print('IF selectNotification isAlreadyTapped : ' +
            GlobalVariables.isAlreadyTapped.toString());
        GlobalVariables.isAlreadyTapped = true;

        if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
            gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
          if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME)) {
            if(isInAppCallNotification) {
              _fcm.showAlert(_ctx, gatePassPayload);
            }else{
              navigate(gatePassPayload, _ctx);
            }
          } else {
            navigate(gatePassPayload, _ctx);
          }
        }else if(gatePassPayload.tYPE == NotificationTypes.TYPE_BROADCAST){
          _fcm.showDynamicAlert(_ctx, _dbNotificationPayload);
        } else {
          print('IF selectNotification gatePassPayload.tYPE : ' +
              gatePassPayload.tYPE.toString());
          navigate(gatePassPayload, _ctx);
        }
      }
    } catch (e) {
      print('exception : ' + e.toString());
      _fcm.showErrorDialog(_ctx, e);
    }
  }

  _showNotification(Map<String, dynamic> message, bool shouldRedirect) async {
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
    GatePassPayload gatePassPayload;
    Map data;
    if (Platform.isIOS) {
      data = message;
    } else {
      data = message['data'] as Map;
    }
    try {
      String uuid = Uuid().v1();
      String payloadSData = data["society"];
      Map society;
      society = society = json.decode(payloadSData.toString());
      society["isBackGround"] = shouldRedirect;
      society["msgID"] = uuid;
      // Map<String, dynamic> temp = jsonDecode(society.toString());
      gatePassPayload = GatePassPayload.fromJson(society);

      print('_showNotification isAlreadyTapped : ' +
          GlobalVariables.isAlreadyTapped.toString());
      print('_showNotification isBackGround : ' +
          gatePassPayload.isBackGround.toString());

      if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
        DBNotificationPayload _dbNotificationPayload =
            DBNotificationPayload.fromJson(society);
        _dbNotificationPayload.nid = uuid;
        SQLiteDbProvider.db.insertUnReadNotification(_dbNotificationPayload);
      }
      if (GlobalVariables.isNewlyArrivedNotification) {
        GlobalVariables.isNewlyArrivedNotification = false;
        //GlobalFunctions.setIsNewlyArrivedNotification(false);
        if (gatePassPayload.isBackGround) {
          GlobalVariables.isAlreadyTapped = false;
        }
        try {
          if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
              gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
            if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME)) {
              print('_showNotification isAlreadyTapped : ' +
                  GlobalVariables.isAlreadyTapped.toString());
              if ((gatePassPayload.vSITORTYPE ==
                      GlobalVariables.GatePass_Taxi ||
                  gatePassPayload.vSITORTYPE ==
                      GlobalVariables.GatePass_Delivery)) {
                if(isInAppCallNotification) {
                  _fcm.showAlert(_ctx, gatePassPayload);
                }
              } else {
                if (isGuestEntryNotification) {
                  if(isInAppCallNotification) {
                    _fcm.showAlert(_ctx, gatePassPayload);
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
          var androidPlatformChannelSpecifics;
          if ((gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR || gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) && !GlobalFunctions.isDateGrater(gatePassPayload.dATETIME)) {
            print('if showGuestNotification');
            if (!isInAppCallNotification) {
              print('false isInAppCallNotification');
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
              var iOSPlatformChannelSpecifics =
              IOSNotificationDetails(sound: "alert.caf");
              var platformChannelSpecifics = NotificationDetails(
                  android:androidPlatformChannelSpecifics, iOS:iOSPlatformChannelSpecifics);

              try {
                flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
                    gatePassPayload.body, platformChannelSpecifics,
                    payload: /*data["society"]*/ json.encode(society));
              } catch (e) {
                print(e);
              }
            }
            else if ((gatePassPayload.vSITORTYPE == GlobalVariables.GatePass_Taxi ||
                gatePassPayload.vSITORTYPE ==
                    GlobalVariables.GatePass_Delivery)) {
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
              var iOSPlatformChannelSpecifics =
                  IOSNotificationDetails(sound: "alert.caf");
              var platformChannelSpecifics = NotificationDetails(
                  android:androidPlatformChannelSpecifics, iOS:iOSPlatformChannelSpecifics);

              try {
                flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
                    gatePassPayload.body, platformChannelSpecifics,
                    payload: /*data["society"]*/ json.encode(society));
              } catch (e) {
                print(e);
              }
            } else {
              print('else showGuestNotification');
              if (isGuestEntryNotification) {
                print('else showGuestNotification');
                androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
                print('else showGuestNotification Alert');
                var iOSPlatformChannelSpecifics =
                    IOSNotificationDetails(sound: "alert.caf");
                var platformChannelSpecifics = NotificationDetails(
                    android:androidPlatformChannelSpecifics,
                    iOS:iOSPlatformChannelSpecifics);

                try {
                  print('else showGuestNotification TRY');
                  flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
                      gatePassPayload.body, platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
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
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
              var iOSPlatformChannelSpecifics =
                  IOSNotificationDetails(sound: "alert.caf");
              var platformChannelSpecifics = NotificationDetails(
                  android:androidPlatformChannelSpecifics, iOS:iOSPlatformChannelSpecifics);

              try {
                flutterLocalNotificationsPlugin.show(1, gatePassPayload.title,
                    gatePassPayload.body, platformChannelSpecifics,
                    payload: /*data["society"]*/ json.encode(society));
              } catch (e) {
                print(e);
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> navigate(GatePassPayload temp, BuildContext context) async {
    print('context : ' + context.toString());
    if (temp.tYPE == NotificationTypes.TYPE_COMPLAINT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD, false)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_ASSIGN_COMPLAINT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(temp.iD, true)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_MEETING) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('meetings'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_ANNOUNCEMENT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('announcement'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_EVENT) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('events'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_POLL) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('poll_survey'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_VISITOR ||
        temp.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_BILL) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyUnit(
                  AppLocalizations.of(context).translate('my_dues'))));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_RECEIPT) {
      String block = await GlobalFunctions.getBlock();
      String flat = await GlobalFunctions.getFlat();
      final result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseLedger(block,flat)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_FVISITOR) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    } else if (temp.tYPE == NotificationTypes.TYPE_SInApp) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),
                  temp.vID)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == NotificationTypes.TYPE_NEW_OFFER) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseNearByShopNotificationItemDetails(temp.iD)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == NotificationTypes.TYPE_INTERESTED_CUSTOMER) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseOwnerClassifiedNotificationItemDesc(temp.iD)));
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == NotificationTypes.TYPE_UserManagement) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseUserManagement()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (temp.tYPE == NotificationTypes.TYPE_Expense) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseExpenseSearchAdd()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
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
}
