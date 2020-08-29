import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/Activities/OtpWithMobile.dart';
import 'package:societyrun/Activities/Register.dart';
import 'package:societyrun/Activities/splashScreen.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:dio/dio.dart';
import 'Activities/DashBoard.dart';

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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<AppLanguage>(
      //builder : (BuildContext context) => appLanguage,
      create: (BuildContext context) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        print('model:' + model.toString());
        print('model applocale:' + model.appLocal.toString());
        return MaterialApp(
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
        );
      }),
    );
  }
  getThemeData() {
    return ThemeData(
        primaryColor: GlobalVariables.darkBlue,
        accentColor: GlobalVariables.white,
        primaryColorDark: GlobalVariables.darkBlue,
        cursorColor: GlobalVariables.mediumGreen);
  }
}
