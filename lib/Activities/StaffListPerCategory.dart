import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseStaffListPerCategory extends StatefulWidget {
  String _roleName;

  BaseStaffListPerCategory(this._roleName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StaffListPerCategoryState(_roleName);
  }
}

class StaffListPerCategoryState
    extends BaseStatefulState<BaseStaffListPerCategory> {
  ProgressDialog _progressDialog;
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '';
  String _roleName;

  StaffListPerCategoryState(this._roleName);

  List<Staff> _staffList = List<Staff>();

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getStaffRoleDetailsData();
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
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
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
            _roleName,
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getStaffListPerCategoryLayout(),
      ),
    );
  }

  getStaffListPerCategoryLayout() {
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
                    context, 180.0),
                getStaffListPerCategoryListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getStaffListPerCategoryListDataLayout() {
    return _staffList.length > 0
        ? Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 20, 10, 0),
            padding: EdgeInsets.all(20),
            // height: MediaQuery.of(context).size.height / 0.5,
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(20)),

            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: _staffList.length,
                      itemBuilder: (context, position) {
                        return getStaffListPerCategoryListItemLayout(position);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : Container();
  }

  getStaffListPerCategoryListItemLayout(int position) {
    List<String> _workHouseList = _staffList[position].ASSIGN_FLATS.split(',');
    for (int i = 0; i < _workHouseList.length; i++) {
      if (_workHouseList[i].length == 0) {
        _workHouseList.removeAt(i);
      }
    }

    var staffImage = _staffList[position].IMAGE;

    var rates = _staffList[position].RATINGS;
    bool isRattingDone = false;
    double totalRate = 0.0;

    List<String> _unitRateList = List<String>();

    if (rates.contains(':')) {
      isRattingDone = true;
    }
    if (isRattingDone) {
      _unitRateList = _staffList[position].RATINGS.split(',');
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
                builder: (context) => BaseStaffDetails(_staffList[position])));
        if (result == 'back') {
          getStaffRoleDetailsData();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        // padding: EdgeInsets.all(10),
        // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              children: [
                //profileLayout(),
                Container(
                    padding: EdgeInsets.all(10),
                    // alignment: Alignment.center,
                    /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                    child: staffImage.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                      imageWidth:70.0,
                      imageHeight:70.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 2.0,
                            fit: BoxFit.cover,
                            radius: 35.0,
                          )
                        : AppNetworkImage(
                            staffImage,
                      imageWidth:70.0,
                      imageHeight:70.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 2.0,
                            fit: BoxFit.cover,
                            radius: 35.0,
                          )
                    ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            _staffList[position].STAFF_NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  child: Icon(
                                Icons.star,
                                color: GlobalVariables.skyBlue,
                                size: 15,
                              )),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  totalRate.toStringAsFixed(1).toString(),
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    color: GlobalVariables.orangeYellow,
                                    size: 10,
                                  )),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  _workHouseList.length.toString() + ' House',
                                  style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: GlobalVariables.lightGray,
                  ),
                ),
              ],
            ),
            position != _staffList.length - 1
                ? Container(
                    //color: GlobalVariables.black,
                    //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Divider(
                      thickness: 1,
                      color: GlobalVariables.lightGray,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
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

  Future<void> getStaffRoleDetailsData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClient.staffRoleDetails(societyId, _roleName).then((value) {
      _progressDialog.hide();
      List<dynamic> _list = value.data;
      _staffList = List<Staff>.from(_list.map((i) => Staff.fromJson(i)));
      if (mounted) {
        setState(() {
          print('setState');
        });
      }
    });
  }
}
