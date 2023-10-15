//import 'package:custom_switch/custom_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_custom_switch/flutter_custom_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import '../controllers/notification_controller.dart';

class BaseAppNotificationSettings extends StatefulWidget {
  @override
  _BaseAppNotificationSettingsState createState() =>
      _BaseAppNotificationSettingsState();
}

class _BaseAppNotificationSettingsState
    extends State<BaseAppNotificationSettings> {
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '';

  final AppNotificationController controller = Get.find<AppNotificationController>();

  bool isInAppCallNotification = true;
  bool isDailyEntryNotification = true;

  //bool isDailyExitNotification= false;
  bool isGuestEntryNotification = true;

  //bool isGuestExitNotification= false;

  bool isBusy = false;

  void setBusy(value) {
    setState(() {
      isBusy = value;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
            title:AppLocalizations.of(context).translate('app_notification_settings'),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        getAppNotificationSettingsLayout(),
      ],
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
    isDailyEntryNotification =
        await GlobalFunctions.getDailyEntryNotification();
    isGuestEntryNotification =
        await GlobalFunctions.getGuestEntryNotification();
    isInAppCallNotification = await GlobalFunctions.getInAppCallNotification();
    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('isDailyEntryNotification : ' + isDailyEntryNotification.toString());
    print('isGuestEntryNotification : ' + isGuestEntryNotification.toString());
    print('isInAppCallyNotification : ' + isInAppCallNotification.toString());
    setState(() {});
  }

  getAppNotificationSettingsLayout() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            inAppCall(),
            dailyHelps(),
            // yourGuest(),
            _checkNotificationPermissions(),
            _displayTestNotification(),
            _resetGCMId(),
          ],
        ),
      ),
    );
  }

  inAppCall() {
    return Container(
      margin:
          EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        shape:
            (RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
        elevation: 2.0,
        // shadowColor: GlobalVariables.green.withOpacity(0.3),
        //margin: EdgeInsets.all(15),
        color: GlobalVariables.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: SvgPicture.asset(
                      GlobalVariables.inAppCallIconPath,
                      width: 30,
                      height: 30,
                      color: GlobalVariables.grey,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: text(
                          AppLocalizations.of(context).translate('in_app_call'),
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
                          textColor: GlobalVariables.primaryColor),
                    ),
                  ),
                  Container(
                    child: FlutterSwitch(
                      activeColor: GlobalVariables.primaryColor,
                      value: isInAppCallNotification,
                      onToggle: (value) {
                        print("VALUE : $value");
                        setState(() {
                          isInAppCallNotification = value;
                          GlobalFunctions.setInAppCallNotification(
                              isInAppCallNotification);
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
              child: text(
                AppLocalizations.of(context).translate('in_app_call_text'),
                fontSize: GlobalVariables.textSizeSMedium,
                textColor: GlobalVariables.grey,
              ),
            )
          ],
        ),
      ),
    );
  }

  dailyHelps() {
    print('isDailyEntryNotification1 : ' + isDailyEntryNotification.toString());
    return Container(
      margin:
      EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        shape:
            (RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
        elevation: 2.0,
        // shadowColor: GlobalVariables.green.withOpacity(0.3),
       // margin: EdgeInsets.all(15),
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
                      child: SvgPicture.asset(
                        GlobalVariables.dailyHelpsIconPath,
                        width: 30,
                        height: 30,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('daily_helps'),
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            textColor: GlobalVariables.primaryColor),
                      ),
                    ),
                    Container(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('daily_helps_example'),
                            fontSize: GlobalVariables.textSizeSMedium,
                            textColor: GlobalVariables.grey),
                      ),
                    )
                  ],
                ),
              ),
              divider(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: SvgPicture.asset(
                        GlobalVariables.loginIconPath,
                        width: 25,
                        height: 25,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('entry_notification'),
                            fontSize: GlobalVariables.textSizeMedium,
                            textColor: GlobalVariables.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: FlutterSwitch(
                        activeColor: GlobalVariables.primaryColor,
                        value: isDailyEntryNotification,
                        onToggle: (value)async {
                          print("VALUE : $value");
                          setState(() {
                            isDailyEntryNotification = value;
                            GlobalFunctions.setDailyEntryNotification(
                                isDailyEntryNotification);
                          });
                          await onNotifcationUpdate('Staff', value);
                        },
                      ),
                    )
                  ],
                ),
              ),
              /*Container(
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
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  yourGuest() {
    print('isGuestEntryNotification1 : ' + isGuestEntryNotification.toString());
    return Container(
      margin:
      EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        shape:
            (RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
        elevation: 2.0,
        // shadowColor: GlobalVariables.green.withOpacity(0.3),
       // margin: EdgeInsets.all(15),
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
                      child: SvgPicture.asset(
                        GlobalVariables.guestIconPath,
                        width: 30,
                        height: 30,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('your_guest'),
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            textColor: GlobalVariables.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              divider(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: SvgPicture.asset(
                        GlobalVariables.loginIconPath,
                        width: 25,
                        height: 25,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('entry_notification'),
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.w500,
                            textColor: GlobalVariables.grey),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: FlutterSwitch(
                        activeColor: GlobalVariables.primaryColor,
                        value: isGuestEntryNotification,
                        onToggle: (value)async{
                          print("VALUE : $value");
                          setState(() {
                            isGuestEntryNotification = value;
                            GlobalFunctions.setGuestEntryNotification(
                                isGuestEntryNotification);
                          });
                          await onNotifcationUpdate(
                              'IN_APP_NOTIFICATION', value);
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

  Widget _checkNotificationPermissions() => InkWell(
        onTap: () => controller.showNotificationPermission(),
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 2.0,
            color: GlobalVariables.white,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(
                        GlobalVariables.settingsIconPath,
                        width: 30,
                        height: 30,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: text('Check notification permissions',
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            textColor: GlobalVariables.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  Widget _displayTestNotification() => InkWell(
        onTap: () => controller.showTestNotification(),
        // onTap: () => Get.find<TtsController>().readUpiDialog("2000"),
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 2.0,
            color: GlobalVariables.white,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: SvgPicture.asset(
                        GlobalVariables.inAppCallIconPath,
                        width: 30,
                        height: 30,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: text('See how notifiation works',
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            textColor: GlobalVariables.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  Widget _resetGCMId() => InkWell(
      onTap: () => controller.updateFCMToken(),
      child: Obx(
        () => controller.isBusy.value
            ? CupertinoActivityIndicator()
            : Container(
                margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Card(
                  shape: (RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                  elevation: 2.0,
                  color: GlobalVariables.white,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: SvgPicture.asset(
                              GlobalVariables.appSettingsIconPath,
                              width: 30,
                              height: 30,
                              color: GlobalVariables.grey,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: text('Reset notification',
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                  textColor: GlobalVariables.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ));

  Future<void> onNotifcationUpdate(String type, bool value) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);
    setBusy(true);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String updateValue = value ? 'Yes' : 'No';

    await restClient.updateNotificationStatus(
        societyId, userId, type, updateValue);
    setBusy(false);
  }
}
