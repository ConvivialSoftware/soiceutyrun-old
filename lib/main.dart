import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/SplashScreen.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BroadcastResponse.dart';
import 'package:societyrun/Models/ClassifiedResponse.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MyComplexResponse.dart';
import 'package:societyrun/Models/NearByShopResponse.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

callbackNotificationDispatcher() {
  print('Call callbackLocationDispatcher Done');

  Workmanager.executeTask((task) async {
    // print("Native called background task: $backgroundTask"); //simpleTask will be emitted here.
    //print('Input Data : '+inputData.toString());
    switch (task) {
      case Workmanager.iOSBackgroundTask:
        {
          print('iOSBackgroundTask');
          showLocalNotification();
        }
        break;
      case GlobalVariables.fetchNotificationBackground:
        print(GlobalVariables.fetchNotificationBackground);
        showLocalNotification();
        break;
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  flutterDownloadInitialize();
  Workmanager.initialize(
    callbackNotificationDispatcher,
    isInDebugMode: false,
  );
  Workmanager.registerPeriodicTask(
    "1",
    GlobalVariables.fetchNotificationBackground,
    frequency: Duration(hours: 8),
  );

  runApp(BaseAppStart());
}

Future<void> flutterDownloadInitialize() async {
  await FlutterDownloader.initialize(debug: true);
}

Future<void> showLocalNotification() async {
  print('showLocalNotification');
  // var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 10));
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '1003',
    'societyrun_channel_schedule',
    'channel_for_bill_reminder',
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
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  /*await flutterLocalNotificationsPlugin.schedule(
      0,
      'scheduled title',
      'scheduled body',
      scheduledNotificationDateTime,
      platformChannelSpecifics);*/
  tz.initializeTimeZones();
  var dateTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 00, 0);

  GlobalFunctions.getSharedPreferenceDuesData().then((map) async {
    Map<String, String> _duesMap = map;
    //duesRs = _duesMap[GlobalVariables.keyDuesRs];
    String duesDate = _duesMap[GlobalVariables.keyDuesDate];
    String dues = _duesMap[GlobalVariables.keyDuesRs];
    String societyName = await GlobalFunctions.getSocietyName();

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(duesDate);
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);
    print('days : ' + days.toString());

    if (days == 0 || days == -1 || days == -2) {

      String day ;
      if(days==0){
        day = 'Today';
      }else if(days==-1){
        day = days.abs().toString()+' Day';
      }else if(days==-2){
        day = days.abs().toString()+' Days';
      }

      print('dues condition true');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        societyName +' '+GlobalFunctions.getCurrencyFormat(dues),
        'Due in '+day,
        tz.TZDateTime.from(dateTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }else{
      flutterLocalNotificationsPlugin.cancel(0);
    }
  });

}

class BaseAppStart extends StatelessWidget {
  AppLanguage appLanguage = AppLanguage();
  final classifiedResponse = ClassifiedResponse();
  final ownerClassifiedResponse = OwnerClassifiedResponse();
  final nearByShopResponse = NearByShopResponse();
  final servicesResponse = ServicesResponse();
  final helpDeskResponse = HelpDeskResponse();
  final myComplexResponse = MyComplexResponse();

  // final myUnitResponse = MyUnitResponse();
  final gatePassResponse = GatePass();
  final loginDashboardResponse = LoginDashBoardResponse();
  final broadcastResponse = BroadcastResponse();
  final userManagementResponse = UserManagementResponse();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<AppLanguage>(
      //builder : (BuildContext context) => appLanguage,
      create: (BuildContext context) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        print('model:' + model.toString());
        print('model applocale:' + model.appLocal.toString());
        return MultiProvider(
          providers: [
            // ChangeNotifierProvider(create: (context) => ClassifiedResponse()),
            //ChangeNotifierProvider<ClassifiedResponse>.value(value: classifiedResponse),
            ChangeNotifierProvider<ClassifiedResponse>.value(
                value: classifiedResponse),
            ChangeNotifierProvider<OwnerClassifiedResponse>.value(
                value: ownerClassifiedResponse),
            ChangeNotifierProvider<NearByShopResponse>.value(
                value: nearByShopResponse),
            ChangeNotifierProvider<ServicesResponse>.value(
                value: servicesResponse),
            ChangeNotifierProvider<HelpDeskResponse>.value(
                value: helpDeskResponse),
            ChangeNotifierProvider<MyComplexResponse>.value(
                value: myComplexResponse),
            //ChangeNotifierProvider<MyUnitResponse>.value(value: myUnitResponse),
            ChangeNotifierProvider<GatePass>.value(value: gatePassResponse),
            ChangeNotifierProvider<LoginDashBoardResponse>.value(
                value: loginDashboardResponse),
            ChangeNotifierProvider<BroadcastResponse>.value(
                value: broadcastResponse),
            ChangeNotifierProvider<UserManagementResponse>.value(
                value: userManagementResponse),
          ],
          child: MaterialApp(
            theme: getThemeData(),
            title: "SocietyRun",
            locale: model.appLocal,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('hi', ''),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: SplashScreen(),
          ),
        );
      }),
    );
  }

  getThemeData() {
    return ThemeData(
        primaryColor: GlobalVariables.primaryColor,
        accentColor: GlobalVariables.white,
        primaryColorDark: GlobalVariables.primaryColor,
        cursorColor: GlobalVariables.secondaryColor);
  }
}
