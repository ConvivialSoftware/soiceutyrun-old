import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isLogin = false;
  AppLanguage appLanguage = AppLanguage();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      body: Center(
        child: Container(
          child: SvgPicture.asset(GlobalVariables.appIconPath),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), ()=>navigateToPage(context));
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