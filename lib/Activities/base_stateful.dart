import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:society_gatepass/society_gatepass.dart';
import 'package:societyrun/Activities/Admin.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
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
import 'package:societyrun/controllers/notification_controller.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
//import 'package:system_alert_window/system_alert_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Map<String, dynamic>? receivedMessage;
final String androidChannelIdVisitor = "1001";
final String androidChannelIdOther = "1002";
final String androidChannelName = "societyrun_channel_local";
final String androidChannelDesc = "channel_for_gatepass_feature";

//const String TYPE_MANUALLY_STATUS_UPDATE = "manually_status_update";

var androidPlatformChannelSpecificsForVisitor = AndroidNotificationDetails(
  androidChannelIdVisitor,
  androidChannelName,
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

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  GlobalVariables.isNewlyArrivedNotification = true;
  GatePassPayload gatePassPayload;

  Map data;

  GlobalFunctions.setNotificationBackGroundData(message.toString());
  data = message.data;
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
              ? !GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)
                  ? androidPlatformChannelSpecificsForVisitor
                  : androidPlatformChannelSpecifics
              : androidPlatformChannelSpecifics,
          iOS: (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
                  gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY)
              ? iOSPlatformChannelSpecificsForVisitor
              : iOSPlatformChannelSpecifics);
      GlobalVariables.isAlreadyTapped = false;

      if (gatePassPayload.tYPE == NotificationTypes.TYPE_REJECT_GATEPASS) {
        GatepassController.closeGatepassDialog();
        return;
      }
      
      if (gatePassPayload.tYPE != NotificationTypes.TYPE_VISITOR_VERIFY) {
        Random random = new Random();
        flutterLocalNotificationsPlugin.show(
            random.nextInt(20),
            gatePassPayload.title,
            gatePassPayload.body,
            platformChannelSpecifics,
            payload: json.encode(society));
      } else if (gatePassPayload.tYPE ==
          NotificationTypes.TYPE_VISITOR_VERIFY) {
        //show visitor verify notification

        GatepassController.showGatepassNotification(message.data);
      }
    }
  } catch (e) {
    print("ERROR >>> $e");
  }
  return Future<void>.value();
}

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
  final _fcm = FirebaseMessagingHandler();
  static BuildContext? _ctx;
  bool isDailyEntryNotification = false;
  bool isGuestEntryNotification = false;
  bool isInAppCallNotification = false;
  Random random = new Random();
  int randomNumber = 1;

  static BuildContext get getCtx => _ctx!;

  static void setCtx(BuildContext currentContext) {
    _ctx = currentContext;
  }

  void baseMethod() {}

  @override
  void initState() {
    super.initState();
    _ctx = this.context;
    firebaseCloudMessagingListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctx = this.context;
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
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      print("didNotificationLaunchApp :" + details.payload.toString());
      selectNotification(details.payload);
    }

    FirebaseMessaging.onMessage.listen((message) {
      randomNumber = random.nextInt(20);

      GlobalVariables.isNewlyArrivedNotification = true;
      GlobalVariables.isAlreadyTapped = false;

      _showNotification(message.data, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      GlobalVariables.isNewlyArrivedNotification = true;
      GlobalVariables.isAlreadyTapped = false;
      showDialogAlertOnOpen(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        showDialogAlertOnOpen(value.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }

  showDialogAlertOnOpen(Map<String, dynamic> message) {
    String payloadSData = message["society"];
    var society = json.decode(payloadSData.toString());
    GatePassPayload gatePassPayload = GatePassPayload.fromJson(society);
    if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
        gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
      if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
        //show dialog
        GatepassController.showGatepassDialog(
            payload: message, onRedirection: () => Get.back());
      }
    }
  }

  Future selectNotification(String? payload) async {
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
      } else {
        if (gatePassPayload.isBackGround!) {
          GlobalVariables.isAlreadyTapped = false;
        }
      }
      if (!GlobalVariables.isAlreadyTapped) {
        GlobalVariables.isAlreadyTapped = true;

        if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR ||
            gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
          if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
            if (isInAppCallNotification) {
              _fcm.showAlert(_ctx!, payload);
            } else {
              navigate(gatePassPayload, _ctx!);
            }
          } else {
            navigate(gatePassPayload, _ctx!);
          }
        } else if (gatePassPayload.tYPE == NotificationTypes.TYPE_BROADCAST) {
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
    isGuestEntryNotification =
        await GlobalFunctions.getGuestEntryNotification();
    isDailyEntryNotification =
        await GlobalFunctions.getDailyEntryNotification();
    isInAppCallNotification = await GlobalFunctions.getInAppCallNotification();
    GatePassPayload gatePassPayload;
    Map data;

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

      print('_showNotification isAlreadyTapped : ' +
          GlobalVariables.isAlreadyTapped.toString());
      print('_showNotification isBackGround : ' +
          gatePassPayload.isBackGround.toString());
      if (gatePassPayload.tYPE != NotificationTypes.TYPE_SInApp) {
        print('_showNotification isNewlyArrivedNotification : ' +
            GlobalVariables.isNewlyArrivedNotification.toString());
        print('If shouldRedirect: ' + shouldRedirect.toString());
        if (GlobalVariables.isNewlyArrivedNotification) {
          GlobalVariables.isNewlyArrivedNotification = false;
          DBNotificationPayload _dbNotificationPayload =
              DBNotificationPayload.fromJson(society);
          _dbNotificationPayload.nid = uuid;
          SQLiteDbProvider.db.insertUnReadNotification(_dbNotificationPayload);
        }
      }
      if (gatePassPayload.tYPE == NotificationTypes.TYPE_REJECT_GATEPASS) {
        GatepassController.closeGatepassDialog();
        return;
      }

      if (gatePassPayload.tYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
        if (!GlobalFunctions.isDateGrater(gatePassPayload.dATETIME!)) {
          GatepassController.showGatepassDialog(
              payload: message,
              onRedirection: () {
                Get.back();
              });

          return;
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
              if ((gatePassPayload.vSITORTYPE ==
                      GlobalVariables.GatePass_Taxi ||
                  gatePassPayload.vSITORTYPE ==
                      GlobalVariables.GatePass_Delivery)) {
                if (isInAppCallNotification) {
                  _fcm.showAlert(_ctx!, message);
                }
              } else {
                if (isGuestEntryNotification) {
                  if (isInAppCallNotification) {
                    _fcm.showAlert(_ctx!, message);
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
                if (showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(
                      randomNumber,
                      gatePassPayload.title,
                      gatePassPayload.body,
                      platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
                }
              } catch (e) {
                print(e);
              }
            } else if ((gatePassPayload.vSITORTYPE ==
                    GlobalVariables.GatePass_Taxi ||
                gatePassPayload.vSITORTYPE ==
                    GlobalVariables.GatePass_Delivery)) {
              var platformChannelSpecifics = NotificationDetails(
                  android: androidPlatformChannelSpecificsForVisitor,
                  iOS: iOSPlatformChannelSpecificsForVisitor);

              try {
                if (showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(
                      randomNumber,
                      gatePassPayload.title,
                      gatePassPayload.body,
                      platformChannelSpecifics,
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
                  if (showLocalNotification) {
                    flutterLocalNotificationsPlugin.show(
                        randomNumber,
                        gatePassPayload.title,
                        gatePassPayload.body,
                        platformChannelSpecifics,
                        payload: /*data["society"]*/ json.encode(society));
                  }
                } catch (e) {
                  print('else showGuestNotification CATCH');
                  print(e);
                }
              }
            }
          } else {
            if (isDailyEntryNotification) {
              print('if showDailyNotification');
              var platformChannelSpecifics = NotificationDetails(
                  android: androidPlatformChannelSpecifics,
                  iOS: iOSPlatformChannelSpecifics);

              try {
                if (showLocalNotification) {
                  flutterLocalNotificationsPlugin.show(
                      randomNumber,
                      gatePassPayload.title,
                      gatePassPayload.body,
                      platformChannelSpecifics,
                      payload: /*data["society"]*/ json.encode(society));
                }
              } catch (e) {
                print(e);
              }
            }
          }
        }
        //}
      } else {
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
    } else if (temp.tYPE == NotificationTypes.TYPE_Document) {
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
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
      /*final result = await */ Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseViewReceipt(temp.iD!, null, null, null)));
      /*if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
            (Route<dynamic> route) => false);
      }*/
    } else if (temp.tYPE == NotificationTypes.TYPE_FVISITOR) {
      Get.find<AppNotificationController>().goToMyGate();
    } else if (temp.tYPE == NotificationTypes.TYPE_SInApp) {
      /*final result = await */ Navigator.push(
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
    } else if (temp.tYPE == NotificationTypes.TYPE_NEW_OFFER) {
      /*final result = await */ Navigator.push(
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
    } else if (temp.tYPE == NotificationTypes.TYPE_INTERESTED_CUSTOMER) {
      /*final result = await */ Navigator.push(
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
    } else if (temp.tYPE == NotificationTypes.TYPE_UserManagement) {
      /*final result = await */ Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseUserManagement()))
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
    } else if (temp.tYPE == NotificationTypes.TYPE_MyHousehold) {
      /*final result = await */ Navigator.push(
              context, MaterialPageRoute(builder: (context) => BaseAdmin()))
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
    } else if (temp.tYPE == NotificationTypes.TYPE_PaymentRequest) {
      /*final result = await */ Navigator.push(
              context, MaterialPageRoute(builder: (context) => BaseAdmin()))
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
    } else if (temp.tYPE == NotificationTypes.TYPE_Expense) {
      /*final result = await */ Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseExpenseSearchAdd()))
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
    } else if (temp.tYPE == NotificationTypes.TYPE_WEB) {
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
