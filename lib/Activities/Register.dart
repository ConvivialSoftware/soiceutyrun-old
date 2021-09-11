
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/AddSociety.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseRegister extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // GlobalFunctions.showToast("OTP page");
    return RegisterState();
  }
}

class RegisterState extends State<BaseRegister> {
  TextEditingController name = new TextEditingController();
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();
  TextEditingController mobile = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //   GlobalFunctions.showToast("Otpstate page");
    //  var otp_mobile_text=AppLocalizations.of(context).translate('')
    return Builder(
      builder: (context) => Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: GlobalVariables.white,
          ),
          child: Column(
            children: <Widget>[
              GlobalFunctions.getAppHeaderWidget(context),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(20),
                child: RichText(
                    text: TextSpan(children: [
                  WidgetSpan(
                      child: SvgPicture.asset(GlobalVariables.loginIconPath)),
                  TextSpan(
                      text: " " +
                          AppLocalizations.of(context).translate('register'),
                      style: TextStyle(fontSize: GlobalVariables.textSizeLargeMedium, color: GlobalVariables.primaryColor)),
                  TextSpan(
                      text: AppLocalizations.of(context).translate('with_us'),
                      style: TextStyle(
                          fontSize: GlobalVariables.textSizeLargeMedium, color: GlobalVariables.lightGray))
                ])),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: TextField(
                  controller: name,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: GlobalVariables.black),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('name'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GlobalVariables.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: TextField(
                  controller: username,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: GlobalVariables.black),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).translate('username'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GlobalVariables.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  style: TextStyle(
                    color: GlobalVariables.black,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).translate('password'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: TextField(
                  controller: confirmPassword,
                  obscureText: true,
                  style: TextStyle(
                    color: GlobalVariables.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate('confirm_password'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.1,
                margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: TextField(
                  controller: mobile,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: GlobalVariables.black),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('mobile'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GlobalVariables.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GlobalVariables.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 45,
                      margin: EdgeInsets.fromLTRB(30, 50, 25, 10),
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width / 2,
                        child: RaisedButton(
                          color: GlobalVariables.primaryColor,
                          onPressed: () {

                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    BaseAddSociety()));

                          },
                          textColor: GlobalVariables.white,
                          //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: GlobalVariables.primaryColor)),
                          child: text(
                            AppLocalizations.of(context).translate('register'),
                            fontSize: GlobalVariables.textSizeMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 45,
                      margin: EdgeInsets.fromLTRB(30, 50, 25, 10),
                      child: RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate("already_acc"),
                              style:
                                  TextStyle(color: GlobalVariables.black, fontSize: 15)),
                          TextSpan(
                              text: ("          " +
                                  AppLocalizations.of(context)
                                      .translate('sign_in')),
                              recognizer: TapGestureRecognizer()..onTap=(){
                                Navigator.of(context).pop();
                              },
                              style: TextStyle(
                                  color: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeNormal,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5)),
                        ],
                      )),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  //color: GlobalVariables.orangeAccent,
                  //margin: EdgeInsets.all(20),
                  child:Column(
                    children: <Widget>[
                      Container(
                        child: RichText(text: TextSpan(
                            children: [
                              TextSpan(
                                  text: AppLocalizations.of(context).translate('pre_terms_conn'),style: TextStyle(
                                  color: GlobalVariables.black
                              )
                              ),
                              TextSpan(
                                  text: AppLocalizations.of(context).translate('terms_conn'),style: TextStyle(
                                  color: GlobalVariables.primaryColor
                              )
                              ),
                            ]
                        )),
                      ),
                      Container(
                        child: RichText(text: TextSpan(
                            children: [
                              TextSpan(
                                  text: AppLocalizations.of(context).translate('pre_privacy_statement'),
                                  style: TextStyle(
                                      color: GlobalVariables.black
                                  )
                              ),
                              TextSpan(
                                  text: AppLocalizations.of(context).translate('privacy_statement'),style: TextStyle(
                                  color: GlobalVariables.primaryColor
                              )
                              ),
                            ]
                        )),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
