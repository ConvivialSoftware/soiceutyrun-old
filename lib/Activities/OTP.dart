
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'base_stateful.dart';

class BaseOtp extends StatefulWidget{

  String expire_time,otp,username;

  BaseOtp(this.expire_time,this.otp, this.username);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   // GlobalFunctions.showToast("OTP page");
    return OtpState(expire_time,otp,username);
  }

}

class OtpState extends BaseStatefulState<BaseOtp>{

  String entered_pin="";
  String expire_time,otp,username;
  OtpState(this.expire_time, this.otp,this.username);
  String fcmToken;
  ProgressDialog _progressDialog;

  Timer _timer;
  int _start=60;
  bool isResendEnable=false;
  var displayNumber='';
  bool isEmail=false;


  @override
  void initState() {
      super.initState();
      print('expire_Time: '+expire_time.toString());
      print('OTP : '+otp.toString());
      print('MobileNo : '+username.toString());
      startTimer();
      if(username.contains('@')){
        displayNumber = username.replaceRange(2, 8, "*" * 6);
        isEmail=true;
      }else {
        displayNumber = username.replaceRange(2, 8, "*" * 6);
        isEmail=false;
      }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
 //   GlobalFunctions.showToast("Otpstate page");
  //  var otp_mobile_text=AppLocalizations.of(context).translate('')
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
            child
                : Column(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidget(context),
                Container(
                  margin: EdgeInsets.all(40),
                  child: RichText(text: TextSpan(
                    children: [
                      TextSpan(text: AppLocalizations.of(context).translate('otp_header_str'),style: TextStyle(
                        color: GlobalVariables.black,fontSize: 16,height: 1.5,
                        wordSpacing: 1.0
                      )),
                      TextSpan(text: ("    "+AppLocalizations.of(context).translate('otp_header_str_with_mobile')+displayNumber.toString()),style: TextStyle(
                          color: GlobalVariables.black,fontSize: 16,wordSpacing: 1.0,height: 1.5
                      )),
                    ]
                  )),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: PinEntryTextField(
                    showFieldAsBox: true,
                    fields: 6,
                    isTextObscure: false,
                    fieldWidth: 50.0,
                    fontSize: 18.0,
                    onSubmit: (String pin){
                      entered_pin=pin;
                     // GlobalFunctions.showToast(entered_pin);
                    },
                  ),
                ),
                Container(
                  height: 45,
                  margin: EdgeInsets.fromLTRB(30, 50, 25, 10),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width/2,
                    child: RaisedButton(
                      color: GlobalVariables.green,
                      onPressed: () {

                        if(_timer!=null){
                          _timer.cancel();
                          _start=60;
                        }
                        verifyOTP();

                      },
                      textColor: GlobalVariables.white,
                      //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                      ),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('enter_otp'),
                        style: TextStyle(
                            fontSize: GlobalVariables.largeText),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(50),
                 child: Column(
                   children: <Widget>[
                     Container(
                       alignment: Alignment.center,
                       child: Text(AppLocalizations.of(context).translate("not_received_otp"),style: TextStyle(
                           color: GlobalVariables.black,fontSize: 15
                       )),
                     ),
                     InkWell(
                       onTap: (){
                         if(isResendEnable) {
                           isResendEnable=false;
                           _start=60;
                           startTimer();
                           getResendOtp();
                         }
                       },
                       child: Container(
                         alignment: Alignment.center,
                         child: Text(AppLocalizations.of(context).translate("resend"),style: TextStyle(
                             color: isResendEnable ? GlobalVariables.green : GlobalVariables.grey,fontSize: 20,fontWeight: FontWeight.bold,height: 1.5
                         )),
                       ),
                     ),
                     Container(
                       alignment: Alignment.center,
                       child: Text(isResendEnable ? '': ('00:'+_start.toString()),style: TextStyle(
                           color: GlobalVariables.black,fontSize: 15
                       )),
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
    if(entered_pin.length==6){
      getOTPLogin();
    }else{
      GlobalFunctions.showToast("Please Enter Full OTP");
    }

  }

  Future<void> getOTPLogin() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    fcmToken = await GlobalFunctions.getFCMToken();
    _progressDialog.show();
    restClient.getOTPLogin(expire_time, otp, entered_pin, isEmail?"":username,isEmail? username:"",fcmToken).then((value) {
      print('add member Status value : '+value.toString());
      _progressDialog.hide();
      GlobalFunctions.showToast(value.message);
      if (value.status) {
        value.LoggedUsername = username;
        GlobalFunctions.saveDataToSharedPreferences(value);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>BaseChangePassword()));
      }else{
        setState(() {
          isResendEnable=true;
          _start=60;
        });
      }



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


  @override
  void dispose() {
    super.dispose();
    if(_timer!=null)
      _timer.cancel();

  }

  void startTimer(){
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if(_start<1){
          timer.cancel();
          isResendEnable=true;
        }else{
          _start-=1;
        }
      });

    });

  }

  Future<void> getResendOtp() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);

   // _progressDialog.show();
    restClient.getResendOTP(otp,isEmail ? "" : username,isEmail ? username : "").then((value) {
      print('get OTP value : '+value.toString());
     // GlobalFunctions.showToast('otp : '+value.otp.toString());
 //     _progressDialog.hide();
      if(value.status){
        expire_time=value.expire_time;
        otp=value.otp;
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