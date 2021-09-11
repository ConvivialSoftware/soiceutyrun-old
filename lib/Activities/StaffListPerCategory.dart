import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseStaffListPerCategory extends StatefulWidget {
  String _roleName;
  String type;
  bool isAdmin;

  BaseStaffListPerCategory(this._roleName,this.type,{this.isAdmin=false});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffListPerCategoryState(_roleName);
  }
}

class StaffListPerCategoryState
    extends State<BaseStaffListPerCategory> {
  ProgressDialog _progressDialog;
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '';
  String _roleName;

  StaffListPerCategoryState(this._roleName);

 // List<Staff> value.staffList = List<Staff>();

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        Provider.of<GatePass>(context,listen: false).getStaffRoleDetailsData(widget._roleName,widget.type);
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<GatePass>.value(
        value: Provider.of<GatePass>(context),
      child: Consumer<GatePass>(builder: (context,value,child){
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            //resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: GlobalVariables.primaryColor,
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: AppIcon(
                  Icons.arrow_back,
                  iconColor: GlobalVariables.white,
                ),
              ),
              title: text(
                _roleName,
                  textColor: GlobalVariables.white,
              ),
            ),
            body: getStaffListPerCategoryLayout(value),
          ),
        );
      }),
    );
  }

  getStaffListPerCategoryLayout(GatePass value) {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 180.0),
        value.isLoading? GlobalFunctions.loadingWidget(context):  getStaffListPerCategoryListDataLayout(value),
      ],
    );
  }

  getStaffListPerCategoryListDataLayout(GatePass value) {
    return value.staffList.length > 0
        ? Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(0,16, 0, 0),
           // padding: EdgeInsets.all(10),
            // height: MediaQuery.of(context).size.height / 0.5,
          /*  decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),*/

            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: value.staffList.length,
                      itemBuilder: (context, position) {
                        return getStaffListPerCategoryListItemLayout(position,value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : Container();
  }

  getStaffListPerCategoryListItemLayout(int position, GatePass value) {

    if(widget.type=="Staff" || widget.type=="Helper") {
      List<String> _workHouseList = value.staffList[position].ASSIGN_FLATS
          .split(',');
      for (int i = 0; i < _workHouseList.length; i++) {
        if (_workHouseList[i].length == 0) {
          _workHouseList.removeAt(i);
        }
      }

      var staffImage = value.staffList[position].IMAGE;

      var rates = value.staffList[position].RATINGS;
      bool isRattingDone = false;
      double totalRate = 0.0;

      List<String> _unitRateList = List<String>();

      if (rates.contains(':')) {
        isRattingDone = true;
      }
      if (isRattingDone) {
        _unitRateList = value.staffList[position].RATINGS.split(',');
        for (int i = 0; i < _unitRateList.length; i++) {
          List<String> _rate = List<String>();
          _rate = _unitRateList[i].split(':');
          if (_rate.length == 2) {
            print('_rate[1] : ' + _rate[1]);
            if (_rate[1].isEmpty) _rate[1] = '0.0';
            totalRate += double.parse(_rate[1]);
            print('totalRate : ' + totalRate.toString());
          }
        }
        totalRate = totalRate / _unitRateList.length;
      }

      return InkWell(
        onTap: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseStaffDetails(value.staffList[position])));
          if (result == 'back') {
            Provider.of<GatePass>(context, listen: false)
                .getStaffRoleDetailsData(widget._roleName,widget.type);
          }
        },
        child: AppContainer(
          isListItem: true,
          width: MediaQuery
              .of(context)
              .size
              .width / 1.1,
          // padding: EdgeInsets.all(10),
          // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          /* decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),*/
          child: Column(
            children: [
              Row(
                children: [
                  //profileLayout(),
                  Container(
                    //padding: EdgeInsets.all(10),
                    // alignment: Alignment.center,
                    /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                      child: staffImage.isEmpty
                          ? AppAssetsImage(
                        GlobalVariables.componentUserProfilePath,
                        imageWidth: 70.0,
                        imageHeight: 70.0,
                        borderColor: GlobalVariables.grey,
                        borderWidth: 1.0,
                        fit: BoxFit.cover,
                        radius: 35.0,
                      )
                          : AppNetworkImage(
                        staffImage,
                        imageWidth: 70.0,
                        imageHeight: 70.0,
                        borderColor: GlobalVariables.grey,
                        borderWidth: 1.0,
                        fit: BoxFit.cover,
                        radius: 35.0,
                      )
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: primaryText(
                                  value.staffList[position].STAFF_NAME,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    child: AppIcon(
                                      Icons.star,
                                      iconColor: GlobalVariables.skyBlue,
                                      iconSize: 15,
                                    )),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: text(
                                    totalRate.toStringAsFixed(1).toString(),
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: AppIcon(
                                      Icons.fiber_manual_record,
                                      iconColor: GlobalVariables.orangeYellow,
                                      iconSize: 10,
                                    )),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: text(
                                    _workHouseList.length.toString() + ' House',
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  widget.isAdmin ?   Container(
                      alignment: Alignment.topRight,
                      child: AppIconButton(
                        Icons.delete,
                        iconColor: GlobalVariables.primaryColor,
                        onPressed: (){

                          showDialog(
                              context: context,
                              builder: (BuildContext context) => StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0)),
                                      child: displayDeleteLayout(value.staffList[position].SID),
                                    );
                                  }));
                        },
                      )):SizedBox(),
                 /* Container(
                    child: AppIcon(
                      Icons.arrow_forward_ios,
                      iconColor: GlobalVariables.lightGray,
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        ),
      );
    }else{
      return AppContainer(
          isListItem: true,
          width: MediaQuery
          .of(context)
          .size
          .width / 1.1,
        child: Column(
          children: [
            Row(
              children: [
                //profileLayout(),
                Container(
                  //padding: EdgeInsets.all(10),
                  // alignment: Alignment.center,
                  /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                    child: value.staffList[position].PHOTO.isEmpty
                        ? AppAssetsImage(
                      GlobalVariables.componentUserProfilePath,
                      imageWidth: 70.0,
                      imageHeight: 70.0,
                      borderColor: GlobalVariables.grey,
                      borderWidth: 1.0,
                      fit: BoxFit.cover,
                      radius: 35.0,
                    )
                        : AppNetworkImage(
                      value.staffList[position].PHOTO,
                      imageWidth: 70.0,
                      imageHeight: 70.0,
                      borderColor: GlobalVariables.grey,
                      borderWidth: 1.0,
                      fit: BoxFit.cover,
                      radius: 35.0,
                    )
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: primaryText(
                                value.staffList[position].NAME,
                              ),
                            ),
                            Container(
                                child: AppIconButton(
                                  Icons.delete,
                                  iconColor: GlobalVariables.primaryColor,
                                  onPressed: (){
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) => StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0)),
                                                child: displayDeleteLayout(value.staffList[position].ID),
                                              );
                                            }));
                                  },
                                )),
                          ],
                        ),
                        Container(
                          child: text(
                            value.staffList[position].EMAIL,fontSize: GlobalVariables.textSizeSMedium
                          ),
                        ),
                        Container(
                          child: text(
                            value.staffList[position].PHONE,fontSize: GlobalVariables.textSizeSMedium
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*Container(
                  child: AppIcon(
                    Icons.arrow_forward_ios,
                    iconColor: GlobalVariables.lightGray,
                  ),
                ),*/
              ],
            ),
          ],
        ),

      );
    }
  }

  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    // photo = await GlobalFunctions.getPhoto();
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

  displayDeleteLayout(String id) {

   return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
                AppLocalizations.of(context).translate('sure_delete'),
                fontSize: GlobalVariables.textSizeLargeMedium,
                textColor: GlobalVariables.black,
                fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _progressDialog.show();
                      Provider.of<GatePass>(context,listen: false).getStaffDelete(id,widget.type).then((value) {
                        _progressDialog.hide();
                        GlobalFunctions.showToast(value.message);
                        if(value.status) {
                          Provider.of<GatePass>(
                              context, listen: false)
                              .getStaffRoleDetailsData(
                              widget._roleName, widget.type);
                        }
                      });
                    },
                    child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: text(
                        AppLocalizations.of(context).translate('no'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );


  }

  
}
