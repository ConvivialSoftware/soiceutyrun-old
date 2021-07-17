//import 'package:custom_switch/custom_switch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseStaffDetails extends StatefulWidget {
  Staff _staff;

  BaseStaffDetails(this._staff);

  @override
  _BaseStaffDetailsState createState() => _BaseStaffDetailsState(_staff);
}

class _BaseStaffDetailsState extends State<BaseStaffDetails> {
  var userId = "",
      name = "",
      photo = "",
      societyId = "",
      flat = "",
      block = "",
      unit = '';
  var email = '', phone = '', consumerId = '', societyName = '';

  Staff _staff;

  ProgressDialog _progressDialog;

  _BaseStaffDetailsState(this._staff);

  double totalRate = 0.0;

  List<String> _assignFlatList = List<String>();
  List<String> _unitRateList = List<String>();
  bool isRattingDone = false;
  bool isRattingDoneFromLoggedPerson = false;
  bool isStaffAdded = false;

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();

    if (_staff.RATINGS.contains(':')) {
      isRattingDone = true;
    }
    if (isRattingDone) {
      _unitRateList = _staff.RATINGS.split(',');
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

    if (_staff.ASSIGN_FLATS.length > 0) {
      _assignFlatList = _staff.ASSIGN_FLATS.split(',');
      for (int i = 0; i < _assignFlatList.length; i++) {
        if (_assignFlatList[i].length == 0) {
          _assignFlatList.removeAt(i);
        }
      }
    }

    print('_assignFlatList.length : ' + _assignFlatList.length.toString());
    print('isStaffAdded : ' + isStaffAdded.toString());
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
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
            AppLocalizations.of(context).translate('staff_info'),
            textColor: GlobalVariables.white,
          ),
        ),
        body: getBaseLayout(),
        //bottomNavigationBar: addToHouseHoldLayout(),
      ),
    );
  }

  getBaseLayout() {
    return WillPopScope(
      onWillPop: () {
        /* if(isStaffAdded || !isStaffAdded){
          Navigator.of(context).pop('back');
        }
        if(isRattingDone){*/
        Navigator.of(context).pop('back');
        /*}else{
          Navigator.of(context).pop();
        }*/
        return;
      },
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
              context, 150.0),
          getStaffDetailsLayout(),
          addToHouseHoldLayout(),
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
    unit = block + ' ' + flat;

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('unit : ' + unit);
    for (int i = 0; i < _assignFlatList.length; i++) {
      if (unit == _assignFlatList[i]) {
        isStaffAdded = true;
        break;
      }
    }
    if (isRattingDone) {
      for (int i = 0; i < _unitRateList.length; i++) {
        List<String> _rate = List<String>();
        _rate = _unitRateList[i].split(':');
        if (unit == _rate[0]) {
          isRattingDoneFromLoggedPerson = true;
        }
      }
    }
    setState(() {});
  }

  getStaffDetailsLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Column(
          children: [
            staffPersonalDetails(),
            isRattingDone ? staffRateDetails() : Container(),
            staffWorkHouse(),
          ],
        ),
      ),
    );
  }

  staffPersonalDetails() {
    return AppContainer(
      //width: MediaQuery.of(context).size.width / 1.1,
      // padding: EdgeInsets.all(10),
      // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  // padding: EdgeInsets.only(left: 10),
                  // alignment: Alignment.center,
                  /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                  child: _staff.IMAGE.length == 0
                      ? Image.asset(
                          GlobalVariables.componentUserProfilePath,
                          width: 70,
                          height: 70,
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(_staff.IMAGE),
                                  fit: BoxFit.cover),
                              border: Border.all(
                                  color: GlobalVariables.grey, width: 2.0)),
                        )),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  //margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: primaryText(
                          _staff.STAFF_NAME,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: text(
                                _staff.CONTACT,
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Visibility(
            visible: _staff.CONTACT.length > 0 ? true : false,
            child: Container(
              //margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: AppIconButton(
                          Icons.call,
                          iconColor: GlobalVariables.green,
                          onPressed: () {
                            launch("tel:" + _staff.CONTACT);
                          },
                        ),
                      ),
                    ),
                    VerticalDivider(),
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: AppIconButton(
                          Icons.share,
                          iconColor: GlobalVariables.grey,
                          onPressed: () {
                            GlobalFunctions.shareData(
                                _staff.STAFF_NAME,
                                'Name : ' +
                                    _staff.STAFF_NAME +
                                    '\nContact : ' +
                                    _staff.CONTACT);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  staffRateDetails() {
    return AppContainer(
      isListItem: true,
      //padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                showRatting(),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: text(
                    totalRate.toStringAsFixed(1).toString(),
                    textColor: GlobalVariables.skyBlue,
                    fontSize: GlobalVariables.textSizeLargeMedium,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                /*Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: GlobalVariables.lightGreen,
                          width: 3.0,
                        )),
                    child: Text('View All')),*/
              ],
            ),
          ),
          /*Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Divider(
              thickness: 1,
              color: GlobalVariables.lightGray,
            ),
          ),*/
        ],
      ),
    );
  }

  staffWorkHouse() {
    return AppContainer(
      child: Column(
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: SvgPicture.asset(
                    GlobalVariables.bottomHomeIconPath,
                    width: 20,
                    height: 20,
                    color: GlobalVariables.grey,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: primaryText(
                      'Works In ' +
                          _assignFlatList.length.toString() +
                          ' House',
                    ),
                  ),
                ),
                isStaffAdded
                    ? InkWell(
                        onTap: () {
                          removeHouseHold();
                        },
                        child: Container(
                          child: AppIcon(
                            Icons.delete,
                            iconColor: GlobalVariables.green,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Divider(),
          Container(
              width: MediaQuery.of(context).size.width / 1.1,
              child: Container(
                  //: MediaQuery.of(context).size.width / 1.1,
                  child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: MediaQuery.of(context).size.width / 150.0,
                children: List.generate(
                  _assignFlatList.length,
                  (index) {
                    return Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.grey,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.white,
                              width: 1.0,
                            )),
                        child: Container(
                          alignment: Alignment.center,
                          child: text(
                            _assignFlatList[index],
                            textColor: GlobalVariables.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ));
                  },
                ),
              ))),
        ],
      ),
    );
  }

  addToHouseHoldLayout() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: GlobalVariables.veryLightGray,
        padding: EdgeInsets.all(10),
        child: Container(
          height: 60,
          width: 250,
          alignment: Alignment.center,
          child: isStaffAdded
              ? Container(
                  child: isRattingDoneFromLoggedPerson
                      ? Container()
                      : Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                              color: GlobalVariables.green,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: GlobalVariables.transparent,
                                width: 3.0,
                              )),
                          child: InkWell(
                              onTap: () {
                                myRate = 0.0;
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              child:
                                                  showMyRattingBar(setState));
                                        }));
                              },
                              child: text('Add Your Ratting',
                                  textColor: GlobalVariables.white,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textStyleHeight: 1.0)),
                        ),
                )
              : Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                      color: GlobalVariables.green,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.transparent,
                        width: 3.0,
                      )),
                  child: InkWell(
                      onTap: () {
                        addHouseHold();
                      },
                      child: text('Add to Household',
                          textColor: GlobalVariables.white,
                          fontSize: GlobalVariables.textSizeSMedium,
                          textStyleHeight: 1.0)),
                ),
        ),
      ),
    );
  }

  showRatting() {
    print('rate : ' + totalRate.toString());
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
      child: RatingBar.builder(
        initialRating: totalRate,
        itemCount: 5,
        allowHalfRating: true,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return AppIcon(
                Icons.sentiment_very_dissatisfied,
                iconColor: Colors.red,
              );
            case 1:
              return AppIcon(
                Icons.sentiment_dissatisfied,
                iconColor: Colors.redAccent,
              );
            case 2:
              return AppIcon(
                Icons.sentiment_neutral,
                iconColor: Colors.amber,
              );
            case 3:
              return AppIcon(
                Icons.sentiment_satisfied,
                iconColor: Colors.lightGreen,
              );
            case 4:
              return AppIcon(
                Icons.sentiment_very_satisfied,
                iconColor: Colors.green,
              );
            default:
              return Container();
          }
        },
        /* onRatingUpdate: (rating) {
          print(rating);
          setState(() {
            totalRate = rating;
          });
        },*/
      ),
    );
  }

  double myRate = 0.0;

  showMyRattingBar(StateSetter _setState) {
    print('after setstate : ' + myRate.toString());
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: RatingBar.builder(
                  initialRating: myRate,
                  itemCount: 5,
                  allowHalfRating: true,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return AppIcon(
                          Icons.sentiment_very_dissatisfied,
                          iconColor: Colors.red,
                        );
                      case 1:
                        return AppIcon(
                          Icons.sentiment_dissatisfied,
                          iconColor: Colors.redAccent,
                        );
                      case 2:
                        return AppIcon(
                          Icons.sentiment_neutral,
                          iconColor: Colors.amber,
                        );
                      case 3:
                        return AppIcon(
                          Icons.sentiment_satisfied,
                          iconColor: Colors.lightGreen,
                        );
                      case 4:
                        return AppIcon(
                          Icons.sentiment_very_satisfied,
                          iconColor: Colors.green,
                        );
                      default:
                        return Container();
                    }
                  },
                  onRatingUpdate: (rating) {
                    print(rating);
                    myRate = rating;
                    _setState(() {
                      print('before setstate : ' + myRate.toString());
                    });
                  },
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: text(
                  myRate.toStringAsFixed(1).toString(),
                  textColor: GlobalVariables.skyBlue,
                  fontSize: GlobalVariables.textSizeNormal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              if (myRate > 0) {
                Navigator.of(context).pop();
                addStaffRatting();
              } else {
                GlobalFunctions.showToast(
                    'Please Select Rate at least grater that Zero');
              }
            },
            child: Container(
              height: 50,
              width: 200,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: GlobalVariables.transparent,
                    width: 3.0,
                  )),
              child: FlatButton(
                  onPressed: () {},
                  child: text(
                    'Submit',
                    textColor: GlobalVariables.white,
                  )),
            ),
          )
        ],
      ),
    );
  }

  Future<void> addStaffRatting() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    double _rate = 0.0;
    double otherMemberRate = 0.0;
    if (_staff.RATINGS.contains(':')) {
      _unitRateList = _staff.RATINGS.split(',');
      for (int i = 0; i < _unitRateList.length; i++) {
        List<String> _rate = List<String>();
        _rate = _unitRateList[i].split(':');
        print('_rate[1] : ' + _rate[1]);
        otherMemberRate += double.parse(_rate[1]);
        print('totalRate : ' + totalRate.toString());
      }
    }
    _rate = otherMemberRate + myRate;
    totalRate = _rate / (_unitRateList.length + 1);
    isRattingDoneFromLoggedPerson = true;
    isRattingDone = true;
    restClient
        .addStaffRatting(societyId, block, flat, _staff.SID,
            totalRate.toStringAsFixed(1).toString())
        .then((value) {
      _progressDialog.hide();
      if (value.status) {
        //if (isRattingDone) {

        //  }
        setState(() {
          print('otherMemberRate rate : ' + otherMemberRate.toString());
          print('myRate rate : ' + myRate.toString());
          print('Total rate : ' + totalRate.toString());
        });
      }
      GlobalFunctions.showToast(value.message);
    });
  }

  Future<void> addHouseHold() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient.addHouseHold(societyId, block, flat, _staff.SID).then((value) {
      _progressDialog.hide();
      if (value.status) {
        _assignFlatList.add(unit);
        isStaffAdded = true;
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
    });
  }

  Future<void> removeHouseHold() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient
        .removeHouseHold(societyId, block, flat, _staff.SID)
        .then((value) {
      _progressDialog.hide();
      if (value.status) {
        for (int i = 0; i < _assignFlatList.length; i++) {
          if (_assignFlatList[i] == unit) {
            _assignFlatList.removeAt(i);
            break;
          }
        }
        isStaffAdded = false;
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
    });
  }
}
