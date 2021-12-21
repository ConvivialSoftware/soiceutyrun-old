import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseOtp extends StatefulWidget {

  String expire_time, otp, username;

  BaseOtp(this.expire_time, this.otp, this.username);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // GlobalFunctions.showToast("OTP page");
    return OtpState();
  }

}

class OtpState extends State<BaseOtp> {

  String entered_pin = "";

  // String expire_time, otp, username;

//  OtpState(this.expire_time, this.otp, this.username);

  String? fcmToken;
  ProgressDialog? _progressDialog;

  Timer? _timer;
  int _start = 60;
  bool isResendEnable = false;
  var displayNumber = '';
  bool isEmail = false;


  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    print('expire_Time: ' + widget.expire_time.toString());
    print('OTP : ' + widget.otp.toString());
    print('MobileNo : ' + widget.username.toString());
    startTimer();
    if (widget.username.contains('@')) {
      displayNumber = widget.username.replaceRange(2, 8, "*" * 6);
      isEmail = true;
    } else {
      displayNumber = widget.username.replaceRange(2, 8, "*" * 6);
      isEmail = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //   GlobalFunctions.showToast("Otpstate page");
    //  var otp_mobile_text=AppLocalizations.of(context).translate('')

    return Builder(
      builder: (context) =>
          Scaffold(
            body: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              decoration: BoxDecoration(
                color: GlobalVariables.white,
              ),
              child: SingleChildScrollView(
                child
                    : Column(
                  children: <Widget>[
                    GlobalFunctions.getAppHeaderWidget(context),
                    Container(
                      margin: EdgeInsets.all(40),
                      child: RichText(text: TextSpan(
                          children: [
                            TextSpan(text: AppLocalizations.of(context)
                                .translate('otp_header_str'), style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium,
                                height: 1.5,
                                wordSpacing: 1.0
                            )),
                            TextSpan(text: ("    " +
                                AppLocalizations.of(context).translate(
                                    'otp_header_str_with_mobile') +
                                displayNumber.toString()), style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium,
                                wordSpacing: 1.0,
                                height: 1.5
                            )),
                          ]
                      )),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    //fieldWidth: 20,
                    style: TextStyle(fontSize: 17),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldStyle: FieldStyle.underline,
                    onCompleted: (pin) {
                          entered_pin = pin;
                        },
                      ),
                    ),
                    Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AppButton(
                      textContent:
                          AppLocalizations.of(context).translate('enter_otp'),
                          onPressed: () {
                            if (_timer != null) {
                          _timer!.cancel();
                              _start = 60;
                            }
                            verifyOTP();
                      }),
                    ),
                    Container(
                      margin: EdgeInsets.all(50),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                        child: text(
                            AppLocalizations.of(context)
                                .translate("not_received_otp"),
                            textColor: GlobalVariables.black,
                            fontSize: 15),
                          ),
                          InkWell(
                            onTap: () {
                              if (isResendEnable) {
                                isResendEnable = false;
                                _start = 60;
                                startTimer();
                                getResendOtp();
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: text(
                            AppLocalizations.of(context).translate("resend"),
                            textColor: isResendEnable
                                      ? GlobalVariables.primaryColor
                                      : GlobalVariables.grey,
                                  fontSize: GlobalVariables.textSizeNormal,
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: text(isResendEnable ? '' : ('00:' +
                                _start.toString()), textColor: GlobalVariables.black, fontSize: 15
                            ),
                          ),
                        ],
                      ),

                      /* child: RichText(text: TextSpan(
                      children: [
                        TextSpan(
                            text: AppLocalizations.of(context).translate("not_received_otp"),style: TextStyle(
                            color: GlobalVariables.black,fontSize: 15
                        )
                        ),
                        TextSpan(
                            text: ("          "+AppLocalizations.of(context).translate('resend')),style: TextStyle(
                            color: GlobalVariables.green,fontSize: 20,fontWeight: FontWeight.bold,height: 1.5
                        ),
                          recognizer: TapGestureRecognizer()..onTap=(){
                            verifyOTP();
                          }
                        ),
                      ],
                  )),*/
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void verifyOTP() {
    //GlobalFunctions.showToast(entered_pin);
    if (entered_pin.length == 6) {
      getOTPLogin();
    } else {
      GlobalFunctions.showToast("Please Enter Full OTP");
    }
  }

  Future<void> getOTPLogin() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    fcmToken = await GlobalFunctions.getFCMToken();
    _progressDialog!.show();
    restClient
            .getOTPLogin(
                widget.expire_time,
                widget.otp,
                entered_pin,
                isEmail ? "" : widget.username,
                isEmail ? widget.username : "",
                fcmToken!)
            .then((value) {
      print('add member Status value : ' + value.toString());
      _progressDialog!.dismiss();
      GlobalFunctions.showToast(value.message!);
      if (value.status!) {
        value.LoggedUsername = widget.username;
        GlobalFunctions.saveDataToSharedPreferences(value);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseChangePassword()));
      } else {
        setState(() {
          isResendEnable = true;
          _start = 60;
        });
      }
    }) /*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.dismiss();
          }
          break;
        default:
      }
    })*/;
  }


  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer!.cancel();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_start < 1) {
          timer.cancel();
          isResendEnable = true;
        } else {
          _start -= 1;
        }
      });
    });
  }

  Future<void> getResendOtp() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    // _progressDialog.show();
    restClient
            .getResendOTP(widget.otp, isEmail ? "" : widget.username,
                isEmail ? widget.username : "")
            .then((value) {
      print('get OTP value : ' + value.toString());
      // GlobalFunctions.showToast('otp : '+value.otp.toString());
      //     _progressDialog.dismiss();
      if (value.status!) {
        widget.expire_time = value.expire_time!;
        widget.otp = value.otp!;
      }
      GlobalFunctions.showToast(value.message!);
    }) /*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.dismiss();
          }
          break;
        default:
      }
    })*/
        ;
  }
  }
