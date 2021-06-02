import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/SplashScreen.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BroadcastResponse.dart';
import 'package:societyrun/Models/ClassifiedResponse.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/MyComplexResponse.dart';
//import 'package:societyrun/Models/MyUnitResponse.dart';
import 'package:societyrun/Models/NearByShopResponse.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';

void main() {


  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  flutterDownloadInitialize();

  runApp(BaseAppStart());
}



Future<void> flutterDownloadInitialize() async {
  await FlutterDownloader.initialize(debug: true);
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
            ChangeNotifierProvider<ClassifiedResponse>.value(value: classifiedResponse),
            ChangeNotifierProvider<OwnerClassifiedResponse>.value(value: ownerClassifiedResponse),
            ChangeNotifierProvider<NearByShopResponse>.value(value: nearByShopResponse),
            ChangeNotifierProvider<ServicesResponse>.value(value: servicesResponse),
            ChangeNotifierProvider<HelpDeskResponse>.value(value: helpDeskResponse),
            ChangeNotifierProvider<MyComplexResponse>.value(value: myComplexResponse),
            //ChangeNotifierProvider<MyUnitResponse>.value(value: myUnitResponse),
            ChangeNotifierProvider<GatePass>.value(value: gatePassResponse),
            ChangeNotifierProvider<LoginDashBoardResponse>.value(value: loginDashboardResponse),
            ChangeNotifierProvider<BroadcastResponse>.value(value: broadcastResponse),
            ChangeNotifierProvider<UserManagementResponse>.value(value: userManagementResponse),
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
        primaryColor: GlobalVariables.green,
        accentColor: GlobalVariables.white,
        primaryColorDark: GlobalVariables.green,
        cursorColor: GlobalVariables.mediumGreen);
  }
}
