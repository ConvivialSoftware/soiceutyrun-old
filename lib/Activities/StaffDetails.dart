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
      for(int i=0;i<_assignFlatList.length;i++){
        if(_assignFlatList[i].length==0){
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
            AppLocalizations.of(context).translate('staff_info'),
            style: TextStyle(color: GlobalVariables.white),
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
      child: Container(
        width: MediaQuery.of(context).size.width,
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
                  GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                      context, 150.0),
                  getStaffDetailsLayout(),
                  addToHouseHoldLayout(),
                ],
              ),
            ),
          ],
        ),
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
        margin: EdgeInsets.fromLTRB(
            10, MediaQuery.of(context).size.height / 20, 10, 0),
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
    return Container(
      //width: MediaQuery.of(context).size.width / 1.1,
      // padding: EdgeInsets.all(10),
      // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Row(
        children: [
          //profileLayout(),
          Container(
              padding: EdgeInsets.all(10),
              // alignment: Alignment.center,
              /* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),*/
              child: _staff.IMAGE.length == 0
                  ? Image.asset(
                      GlobalVariables.componentUserProfilePath,
                      width: 80,
                      height: 80,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(_staff.IMAGE),
                              fit: BoxFit.cover),
                          border: Border.all(
                              color: GlobalVariables.mediumGreen, width: 2.0)),
                    )),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      _staff.STAFF_NAME,
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
                          child: Text(
                            _staff.CONTACT,
                            style: TextStyle(
                              color: GlobalVariables.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _staff.CONTACT.length > 0 ? true : false,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              launch("tel:"+_staff.CONTACT);
                            },
                            child: Container(
                              child: Icon(
                                Icons.call,
                                color: GlobalVariables.green,
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              //TODO: Divider
                              height: 30,
                              width: 8,
                              child: VerticalDivider(
                                thickness: 1,
                                color: GlobalVariables.grey,
                              )),
                          InkWell(
                            onTap: () {
                              GlobalFunctions.shareData(
                                  _staff.STAFF_NAME,
                                  'Name : ' +
                                      _staff.STAFF_NAME +
                                      '\nContact : ' +
                                      _staff.CONTACT);
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Icon(
                                Icons.share,
                                color: GlobalVariables.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  staffRateDetails() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        shape:
            (RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
        elevation: 2.0,
        // shadowColor: GlobalVariables.green.withOpacity(0.3),
        //margin: EdgeInsets.all(15),
        color: GlobalVariables.white,
        child: Container(
          padding: EdgeInsets.all(15),
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
                      child: Text(
                        totalRate.toStringAsFixed(1).toString(),
                        style: TextStyle(
                            color: GlobalVariables.skyBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
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
        ),
      ),
    );
  }

  staffWorkHouse() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        shape:
            (RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
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
                        GlobalVariables.bottomHomeIconPath,
                        width: 30,
                        height: 30,
                        color: GlobalVariables.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(
                          'Work In ' +
                              _assignFlatList.length.toString() +
                              ' House',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    isStaffAdded
                        ? InkWell(
                            onTap: () {
                              removeHouseHold();
                            },
                            child: Container(
                              child: Icon(
                                Icons.delete,
                                color: GlobalVariables.green,
                              ),
                            ),
                          )
                        : Container(),
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
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    childAspectRatio: MediaQuery.of(context).size.width / 200.0,
                    children: List.generate(
                      _assignFlatList.length,
                      (index) {
                        return Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                                color: GlobalVariables.green,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: GlobalVariables.transparent,
                                  width: 3.0,
                                )),
                            child: Text(
                              _assignFlatList[index],
                              style: TextStyle(
                                  color: GlobalVariables.white,
                                  fontWeight: FontWeight.w500),
                            ));
                      },
                    ),
                  )),
            ],
          ),
        ),
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
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                              color: GlobalVariables.green,
                              borderRadius: BorderRadius.circular(30),
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
                                                          25.0)),
                                              child:
                                                  showMyRattingBar(setState));
                                        }));
                              },
                              child: Text(
                                'Add Your Ratting',
                                style: TextStyle(color: GlobalVariables.white),
                              )),
                        ),
                )
              : Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                      color: GlobalVariables.green,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: GlobalVariables.transparent,
                        width: 3.0,
                      )),
                  child: InkWell(
                      onTap: () {
                        addHouseHold();
                      },
                      child: Text(
                        'Add to Household',
                        style: TextStyle(color: GlobalVariables.white),
                      )),
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
              return Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
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
                        return Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      case 4:
                        return Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
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
                child: Text(
                  myRate.toStringAsFixed(1).toString(),
                  style: TextStyle(
                      color: GlobalVariables.skyBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
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
                  child: Text(
                    'Submit',
                    style: TextStyle(color: GlobalVariables.white),
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
    restClient
        .addStaffRatting(societyId, block, flat, _staff.SID,
            myRate.toStringAsFixed(1).toString())
        .then((value) {
      _progressDialog.hide();
      if (value.status) {
        //if (isRattingDone) {
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
