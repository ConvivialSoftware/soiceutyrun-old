import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/SQLiteDatabase/SQLiteDbProvider.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';

import 'HelpDesk.dart';
import 'base_stateful.dart';

class BaseNotifications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationsState();
  }
}

class NotificationsState extends BaseStatefulState<BaseNotifications> {

  ProgressDialog _progressDialog;

  List<DBNotificationPayload> _dbNotificationList = List<DBNotificationPayload>();

  @override
  void initState() {
    super.initState();
    getNotificationData();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
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
            AppLocalizations.of(context).translate('notification')+" ("+GlobalVariables.notificationCounterValueNotifer.value.toString()+")",
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                getNotificationsLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNotificationsLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: _dbNotificationList.length,
            itemBuilder: (context, position) {
              return getNotificationsListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }


  getNotificationsListItemLayout(int position) {
    var displayDate='';
    print(_dbNotificationList[position].DATE_TIME);
    if(GlobalFunctions.isDateSameOrGrater(_dbNotificationList[position].DATE_TIME)){
      print('isDateSameOrGrater True');
      displayDate = GlobalFunctions.convertDateFormat(_dbNotificationList[position].DATE_TIME, 'dd MMM');
    }else{
      print('isDateSameOrGrater False');
      displayDate = GlobalFunctions.convertDateFormat(_dbNotificationList[position].DATE_TIME, 'hh:mm aa');
    }

    var image  =  GlobalVariables.drawerImagePath;
    if(_dbNotificationList[position].TYPE == NotificationTypes.TYPE_VISITOR ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_FVISITOR ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_SInApp ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_VISITOR_VERIFY ){

      image = GlobalVariables.myGateIconPath;

    }else if(_dbNotificationList[position].TYPE == NotificationTypes.TYPE_ANNOUNCEMENT ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_MEETING ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_EVENT ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_POLL ){

      image = GlobalVariables.myBuildingIconPath;

    }else if(_dbNotificationList[position].TYPE == NotificationTypes.TYPE_COMPLAINT ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_ASSIGN_COMPLAINT ){

      image = GlobalVariables.myServiceIconPath;

    }else if(_dbNotificationList[position].TYPE == NotificationTypes.TYPE_BILL ||
        _dbNotificationList[position].TYPE == NotificationTypes.TYPE_RECEIPT ){

      image = GlobalVariables.expenseIconPath;

    }


    return InkWell(
      onTap: () {
        setState(() {
          DBNotificationPayload dbNotificationPayload = _dbNotificationList[position];
          dbNotificationPayload.read=1;
          SQLiteDbProvider.db.updateReadNotification(dbNotificationPayload);
        });
        if(GlobalVariables.notificationCounterValueNotifer.value>0) {
          GlobalVariables.notificationCounterValueNotifer.value--;
        }
        navigateToPage(_dbNotificationList[position]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[

            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Visibility(
                      visible: true,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        width:50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: GlobalVariables.transparent,
                            shape: BoxShape.circle
                        ),
                        child: SvgPicture.asset(image),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          5, 0, 0, 0), //alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: [
                              _dbNotificationList[position].read==0 ? Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: GlobalVariables
                                        .skyBlue,
                                    shape: BoxShape.circle),
                              ):Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                    _dbNotificationList[position].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(_dbNotificationList[position].read==0 ? 15 : 10, 10, 0, 0),
                            child: Text(
                              _dbNotificationList[position].body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                              TextStyle(color: GlobalVariables.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                      child: Text(displayDate,
                          style: TextStyle(color: GlobalVariables.grey)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getNotificationData() async {
    String userId = await GlobalFunctions.getUserId();
    var _list =  await SQLiteDbProvider.db.getUnReadNotification(userId);
    _dbNotificationList = List<DBNotificationPayload>.from(_list.map((i)=>DBNotificationPayload.fromJson(i)));
    setState(() {});

  }

  navigateToPage(DBNotificationPayload _dbNotificationPayload)  {
    print('context : ' + context.toString());
    print('_dbNotificationPayload.ID : ' + _dbNotificationPayload.ID.toString());
    print('_dbNotificationPayload.VID : ' + _dbNotificationPayload.VID.toString());
    if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_COMPLAINT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(_dbNotificationPayload.ID, false)));

    } else if (_dbNotificationPayload.TYPE== NotificationTypes.TYPE_ASSIGN_COMPLAINT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(_dbNotificationPayload.ID, true)));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_MEETING) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('meetings'))));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_ANNOUNCEMENT) {
     Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('announcement'))));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_EVENT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('events'))));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_POLL) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('poll_survey'))));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_VISITOR || _dbNotificationPayload.TYPE == NotificationTypes.TYPE_VISITOR_VERIFY) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),_dbNotificationPayload.VID)));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_BILL) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyUnit(
                  AppLocalizations.of(context).translate('my_dues'))));

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_RECEIPT) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseLedger()));
    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_FVISITOR) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),_dbNotificationPayload.VID)));
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_SInApp) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_gate'),_dbNotificationPayload.VID)));
    }else if(_dbNotificationPayload.TYPE == NotificationTypes.TYPE_BROADCAST){
      FirebaseMessagingHandler().showDynamicAlert(context, _dbNotificationPayload);
    }  else {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
              (Route<dynamic> route) => false);
    }
  }

}
