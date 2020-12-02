import 'package:custom_switch/custom_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseAppNotificationSettings extends StatefulWidget {
  @override
  _BaseAppNotificationSettingsState createState() => _BaseAppNotificationSettingsState();
}

class _BaseAppNotificationSettingsState extends State<BaseAppNotificationSettings> {

  var userId = "",
      name = "",
      photo = "",
      societyId="",
      flat="",
      block="";
  var email = '', phone = '', consumerId = '', societyName = '';

  bool isInAppCall= false;
  bool isDailyEntryNotification= false;
  bool isDailyExitNotification= false;
  bool isGuestEntryNotification= false;
  bool isGuestExitNotification= false;


  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=>Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('app_notification_settings'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context)
          .size
          .width,
      //height: double.maxFinite,
      //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
                getAppNotificationSettingsLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    setState(() {});
  }

  getAppNotificationSettingsLayout() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
           children: [
             inAppCall(),
             dailyHelps(),
             yourGuest(),
           ],
        ),
      ),
    );
  }

  inAppCall() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 30, 0, 0),
      child: Card(
        shape: (RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0))),
        elevation: 2.0,
       // shadowColor: GlobalVariables.green.withOpacity(0.3),
        margin: EdgeInsets.all(15),
        color: GlobalVariables.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: SvgPicture.asset(GlobalVariables.inAppCallIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text(AppLocalizations.of(context).translate('in_app_call'),style: TextStyle(
                          fontSize: 16,fontWeight: FontWeight.w600
                      ),),
                    ),
                  ),
                  Container(
                    child: CustomSwitch(
                      activeColor: GlobalVariables.green,
                      value: isInAppCall,
                      onChanged: (value) {
                        print("VALUE : $value");
                        setState(() {
                          isInAppCall = value;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.fromLTRB(20, 0, 0, 20),
              child: Text(AppLocalizations.of(context).translate('in_app_call_text'),style: TextStyle(
                  fontSize: 14,fontWeight: FontWeight.normal
              ),),
            )
          ],
        ),
      ),
    );
  }

  dailyHelps() {
    return Container(
      //margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 30, 0, 0),
      child: Card(
        shape: (RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0))),
        elevation: 2.0,
       // shadowColor: GlobalVariables.green.withOpacity(0.3),
        margin: EdgeInsets.all(15),
        color: GlobalVariables.white,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.dailyHelpsIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('daily_helps'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('daily_helps_example'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Divider(
                  thickness: 1,
                  color: GlobalVariables.lightGray,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.loginIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('entry_notification'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                      child: CustomSwitch(
                        activeColor: GlobalVariables.green,
                        value: isDailyEntryNotification,
                        onChanged: (value) {
                          print("VALUE : $value");
                          setState(() {
                            isDailyEntryNotification = value;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.logoutIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('exit_notification'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                      child: CustomSwitch(
                        activeColor: GlobalVariables.green,
                        value: isDailyExitNotification,
                        onChanged: (value) {
                          print("VALUE : $value");
                          setState(() {
                            isDailyExitNotification = value;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  yourGuest() {
    return Container(
      //margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 30, 0, 0),
      child: Card(
        shape: (RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0))),
        elevation: 2.0,
       // shadowColor: GlobalVariables.green.withOpacity(0.3),
        margin: EdgeInsets.all(15),
        color: GlobalVariables.white,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.guestIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('your_guest'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Divider(
                  thickness: 1,
                  color: GlobalVariables.lightGray,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.loginIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('entry_notification'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                      child: CustomSwitch(
                        activeColor: GlobalVariables.green,
                        value: isGuestEntryNotification,
                        onChanged: (value) {
                          print("VALUE : $value");
                          setState(() {
                            isGuestEntryNotification = value;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(GlobalVariables.logoutIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(AppLocalizations.of(context).translate('exit_notification'),style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                      child: CustomSwitch(
                        activeColor: GlobalVariables.green,
                        value: isGuestExitNotification,
                        onChanged: (value) {
                          print("VALUE : $value");
                          setState(() {
                            isGuestExitNotification = value;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

