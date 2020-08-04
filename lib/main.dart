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

  runApp(BaseSplashScreen());
}



Future<void> flutterDownloadInitialize() async {
  await FlutterDownloader.initialize(debug: true);
}

class BaseSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SplashScreen();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;
  AppLanguage appLanguage = AppLanguage();
  Timer _timer;


  @override
  void dispose() {

    super.dispose();
    if(_timer!=null)
      _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
  }

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
          home: Builder(builder: (context) {
            startTimer(context);
            return Builder(
              builder: (context) => Scaffold(
                body:   Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: GlobalVariables.green,
                  child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(GlobalVariables.appIconPath),
                  ),
                ),
              ),
            );
          }),
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

   startTimer(BuildContext context) {

    var duration = Duration(seconds: 5);
    _timer = Timer(duration, navigateToPage(context));
    return _timer;

  }

   navigateToPage(BuildContext context) {

    GlobalFunctions.getLoginValue().then((val) {
      print('bool value : ' + val.toString());
      isLogin = val;
      if (isLogin) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseDashBoard()),
                (Route<dynamic> route) => false);
       /* SchedulerBinding.instance.addPostFrameCallback((_) {

        });*/
      }else{
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseLoginPage()),
                (Route<dynamic> route) => false);
        /*SchedulerBinding.instance.addPostFrameCallback((_) {

        });*/
      }
    });
  }
}
