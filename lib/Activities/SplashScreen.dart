import 'dart:async';

import 'package:flutter/material.dart';
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
      backgroundColor: GlobalVariables.primaryColor,
      body: Center(
        child: Container(
          child: Image.asset(GlobalVariables.splashIconPath,width: MediaQuery.of(context).size.width/2,),
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
      }else{
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    BaseLoginPage()),
                (Route<dynamic> route) => false);
      }
    });
  }

}
