import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/OTP.dart';
import 'package:societyrun/Activities/Register.dart';
import 'package:societyrun/GlobalClasses/AppLanguage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseOtpWithMobile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OtpWithMobileState();
  }
}

class OtpWithMobileState extends State<BaseOtpWithMobile> {

  TextEditingController _mobileController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: GlobalVariables.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GlobalFunctions.getAppHeaderWidget(context),
                  Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(20, 25, 15, 15),
                        child: RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                              child: SvgPicture.asset(
                                  GlobalVariables.loginIconPath)),
                          TextSpan(
                              text: " " +
                                  AppLocalizations.of(context)
                                      .translate('login'),
                              style: TextStyle(
                                  fontSize: 18, color: GlobalVariables.green)),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('with_otp'),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: GlobalVariables.lightGray))
                        ])),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        margin: EdgeInsets.fromLTRB(25, 25, 25, 10),
                        child: TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: GlobalVariables.black),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('enter_mobile_no'),
                            hintStyle: TextStyle(
                              color: GlobalVariables.lightGray,
                            ),
                            suffixIcon: Icon(
                              Icons.phone_android,
                              color: GlobalVariables.lightGreen,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalVariables.green,
                                  width: 2.0,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GlobalVariables.green, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 45,
                                margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
                                child: ButtonTheme(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 2,
                                  child: RaisedButton(
                                    color: GlobalVariables.green,
                                    onPressed: () {
                                      verifyNumber();
                                    },
                                    textColor: GlobalVariables.white,
                                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color: GlobalVariables.green)),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('enter'),
                                      style: TextStyle(
                                          fontSize: GlobalVariables.largeText),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                //  height: 45,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                          AppLocalizations.of(context)
                                              .translate("don't_hv_acc"),
                                          style: TextStyle(
                                              color: GlobalVariables.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BaseRegister()));
                                      },
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                            AppLocalizations.of(context)
                                                .translate('register'),
                                            style: TextStyle(
                                                color: GlobalVariables.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/4, 0, 5),
                    //color: GlobalVariables.orangeAccent,
                    //margin: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          //   color: GlobalVariables.lightGreen,
                          decoration: BoxDecoration(
                              color: GlobalVariables.lightGreen,
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.fromLTRB(20,30,20,30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: SvgPicture.asset(
                                    GlobalVariables.classifiedBigIconPath),
                              ),
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: RichText(
                                          text: TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .translate('classified_ads'),
                                              style: TextStyle(
                                                  color: GlobalVariables.green,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold))),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: RichText(
                                          text: TextSpan(
                                              text: AppLocalizations.of(context)
                                                  .translate('classified_str'),
                                              style: TextStyle(
                                                  color: GlobalVariables.black,
                                                  fontSize: 15))),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('pre_terms_conn'),
                                style: TextStyle(color: GlobalVariables.black)),
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('terms_conn'),
                                style: TextStyle(color: GlobalVariables.green)),
                          ])),
                        ),
                        Container(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('pre_privacy_statement'),
                                style: TextStyle(color: GlobalVariables.black)),
                            TextSpan(
                                text: AppLocalizations.of(context)
                                    .translate('privacy_statement'),
                                style: TextStyle(color: GlobalVariables.green)),
                          ])),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  void verifyNumber() {

    if(_mobileController.text.length>0){

      getOtp();

     /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseOtp()));*/
    }else{

      GlobalFunctions.showToast("Please Enter mobile Number");
    }


  }

  Future<void> getOtp() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    _progressDialog.show();
    restClient.getOTP(_mobileController.text, "").then((value) {
      print('get OTP value : '+value.toString());
      _progressDialog.hide();
      if(value.status){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseOtp(value.expire_time,value.otp,_mobileController.text)));
      }
      GlobalFunctions.showToast(value.message);

    })/*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.hide();
          }
          break;
        default:
      }
    })*/;

  }
}


