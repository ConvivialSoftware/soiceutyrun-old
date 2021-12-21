import 'dart:io';

//import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/Admin.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/NearByShopNotificationItemDetails.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/Activities/OwnerClassifiedNotificationItemDesc.dart';
import 'package:societyrun/Activities/OwnerDiscover.dart';
import 'package:societyrun/Activities/UserManagement.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/SQLiteDatabase/SQLiteDbProvider.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HelpDesk.dart';
import 'base_stateful.dart';

class BaseNotifications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationsState();
  }
}

class NotificationsState extends State<BaseNotifications> {

  List<DBNotificationPayload> _dbNotificationList = <DBNotificationPayload>[];
  //var notificationFormatData='';

  @override
  void initState() {
    super.initState();
    getNotificationData();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
         /* actions: [
            AppIconButton(Icons.remove_red_eye,iconColor: GlobalVariables.white,onPressed: () async {
              notificationFormatData = await GlobalFunctions.getNotificationBackGroundData();
              setState(() {

              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: SingleChildScrollView(
                            child: InkWell(
                              onTap: (){
                                ClipboardManager.copyToClipBoard(
                                    notificationFormatData)
                                    .then((value) {
                                  GlobalFunctions.showToast(
                                      "Copied to Clipboard");
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: text(
                                  notificationFormatData,
                                  textColor: GlobalVariables.black,
                                  fontSize: GlobalVariables.textSizeMedium,
                                ),
                              ),
                            ),
                          ),
                        );
                      }));

            },)
          ],*/
          title: AppLocalizations.of(context).translate('notification')+" ("+GlobalVariables.notificationCounterValueNotifer.value.toString()+")",
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
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      width: 100,
                      child: AppButton(
                        textContent: AppLocalizations.of(context)
                            .translate('read_all'),
                        onPressed: () async {
                        await SQLiteDbProvider.db.updateUnReadNotification();
                        getNotificationData();
                      },

                      ),
                    ),
                  ),
                ),
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
          18,80, 18, 0),
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
    if(GlobalFunctions.isDateSameOrGrater(_dbNotificationList[position].DATE_TIME!)){
      print('isDateSameOrGrater True');
      displayDate = GlobalFunctions.convertDateFormat(_dbNotificationList[position].DATE_TIME!, 'dd MMM');
    }else{
      print('isDateSameOrGrater False');
      displayDate = GlobalFunctions.convertDateFormat(_dbNotificationList[position].DATE_TIME!, 'hh:mm aa');
    }

    var image  =  GlobalVariables.appLogoGreenIcon;
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
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 1,
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
                        child: image.toLowerCase().contains(".svg") ? AppAssetsImage(image,imageColor: GlobalVariables.primaryColor,):AppAssetsImage(image,imageColor: GlobalVariables.primaryColor,),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          5, 0, 0, 0), //alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dbNotificationList[position].read==0 ? Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: GlobalVariables
                                        .skyBlue,
                                    shape: BoxShape.circle),
                              ):Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              ),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: text(
                                      _dbNotificationList[position].title??'',
                                      maxLine: 3,
                                      textColor: GlobalVariables.primaryColor,
                                          fontSize: GlobalVariables.textSizeMedium,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(_dbNotificationList[position].read==0 ? 15 : 10, 0, 0, 0),
                            child: text(
                                _dbNotificationList[position].body??'',
                                // maxLine: 2,
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeSMedium
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(3, 5, 0, 0),
                      child: text(displayDate,fontSize: GlobalVariables.textSizeSmall,
    textColor: GlobalVariables.grey),
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
    if(_list!=null) {
      _dbNotificationList = List<DBNotificationPayload>.from(
          _list.map((i) => DBNotificationPayload.fromJson(i)));
      setState(() {});
    }

  }

  navigateToPage(DBNotificationPayload _dbNotificationPayload)  async {
    print('context : ' + context.toString());
    print('_dbNotificationPayload.ID : ' + _dbNotificationPayload.ID.toString());
    print('_dbNotificationPayload.VID : ' + _dbNotificationPayload.VID.toString());
    if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_COMPLAINT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(_dbNotificationPayload.ID!, false)));

    } else if (_dbNotificationPayload.TYPE== NotificationTypes.TYPE_ASSIGN_COMPLAINT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BaseComplaintInfoAndComments.ticketNo(_dbNotificationPayload.ID!, true)));

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

    } else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_Document) {
     Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyComplex(
                  AppLocalizations.of(context).translate('documents'))));

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
      String block = await GlobalFunctions.getBlock();
      String flat = await GlobalFunctions.getFlat();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseLedger(block,flat)));
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
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_NEW_OFFER) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseNearByShopNotificationItemDetails( _dbNotificationPayload.ID!)));
    }else if (_dbNotificationPayload.TYPE  == NotificationTypes.TYPE_INTERESTED_CUSTOMER) {
       Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseOwnerClassifiedNotificationItemDesc(_dbNotificationPayload.ID!)));
    }else if(_dbNotificationPayload.TYPE == NotificationTypes.TYPE_BROADCAST){
      FirebaseMessagingHandler().showDynamicAlert(context, _dbNotificationPayload);
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_UserManagement) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseUserManagement()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_MyHousehold) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAdmin()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_PaymentRequest) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAdmin()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_Expense) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseExpenseSearchAdd()))
          .then((value) {
        GlobalFunctions.setBaseContext(context);
      });
      if (result == null) {
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => BaseDashBoard()),
                (Route<dynamic> route) => false);
      }
    }else if (_dbNotificationPayload.TYPE == NotificationTypes.TYPE_WEB) {
      launch(GlobalVariables.appURL);
    }   else {
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => BaseDashBoard()),
              (Route<dynamic> route) => false);
    }
  }

}
