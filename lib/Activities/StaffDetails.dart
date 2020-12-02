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

class BaseStaffDetails extends StatefulWidget {
  @override
  _BaseStaffDetailsState createState() => _BaseStaffDetailsState();
}

class _BaseStaffDetailsState extends State<BaseStaffDetails> {

  var userId = "",
      name = "",
      photo = "",
      societyId="",
      flat="",
      block="";
  var email = '', phone = '', consumerId = '', societyName = '';



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
            AppLocalizations.of(context).translate('staff_info'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
        bottomNavigationBar: addToHouseHoldLayout(),
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
                getStaffDetailsLayout(),
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

  getStaffDetailsLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            10, MediaQuery.of(context).size.height / 20, 10, 0),
        child: Column(
           children: [
             staffPersonalDetails(),
             staffRateDetails(),
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
              child: photo.length == 0
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
                        image: NetworkImage(photo),
                        fit: BoxFit.cover),
                    border: Border.all(
                        color:
                        GlobalVariables.mediumGreen,
                        width: 2.0)),
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
                      'Archana Nilesh Suryavanshi',
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
                            '9999999999',
                            style: TextStyle(
                              color: GlobalVariables.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.call,
                            color: GlobalVariables.green,
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
                            )
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Icon(
                            Icons.share,
                            color: GlobalVariables.grey,
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
    );
  }

  staffRateDetails() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        shape: (RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0))),
        elevation: 2.0,
       // shadowColor: GlobalVariables.green.withOpacity(0.3),
        //margin: EdgeInsets.all(15),
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
                        child: Icon(
                          Icons.star,
                          color: GlobalVariables.skyBlue,
                          size: 15,
                        )
                    ),
                    Container(
                        child: Icon(
                          Icons.star,
                          color: GlobalVariables.skyBlue,
                          size: 15,
                        )
                    ),
                    Container(
                        child: Icon(
                          Icons.star,
                          color: GlobalVariables.skyBlue,
                          size: 15,
                        )
                    ),
                    Container(
                        child: Icon(
                          Icons.star,
                          color: GlobalVariables.skyBlue,
                          size: 15,
                        )
                    ),
                    Container(
                        child: Icon(
                          Icons.star,
                          color: GlobalVariables.skyBlue,
                          size: 15,
                        )
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text('5.0',style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GlobalVariables.lightGreen,
                              width: 3.0,
                            )),
                        child: Text('View All')
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
        shape: (RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0))),
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
                      child: SvgPicture.asset(GlobalVariables.bottomHomeIconPath,width: 30,height: 30,color: GlobalVariables.grey,),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text('Work In 3 House',style: TextStyle(
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
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: GlobalVariables.lightGreen,
                            width: 3.0,
                          )),
                      child: Text('C 102')
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GlobalVariables.lightGreen,
                              width: 3.0,
                            )),
                        child: Text('C 103')
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GlobalVariables.lightGreen,
                              width: 3.0,
                            )),
                        child: Text('C 104')
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addToHouseHoldLayout() {
    return Container(
      color: GlobalVariables.veryLightGray,
      padding: EdgeInsets.all(10),
      width: 100,
      height: 60,
      child: RaisedButton(
          child: Text('Add to Household',style: TextStyle(color: GlobalVariables.white),)
      ),
    );
  }
}

