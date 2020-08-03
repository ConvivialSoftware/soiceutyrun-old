import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseDescriptionOfHomeService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DescriptionOfHomeServiceState();
  }
}

class DescriptionOfHomeServiceState
    extends State<BaseDescriptionOfHomeService> {
  List<HomeCareDescription> _homeCareList = List<HomeCareDescription>();

  var name="",mobile="",mail="";

  @override
  void initState() {
    super.initState();
    getSharedPrefData();
    getHomeCareDescriptionList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
            AppLocalizations.of(context).translate('home_services'),
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
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      getHomeCareDescriptionListDataLayout(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getHomeCareDescriptionListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 50, 10, 0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              _homeCareList[0].title,
              style: TextStyle(
                  color: GlobalVariables.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              _homeCareList[0].subDesc,
              style: TextStyle(
                color: GlobalVariables.lightGray,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Service Description',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    _homeCareList[0].serviceDesc,
                    style: TextStyle(
                      color: GlobalVariables.lightGray,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  // color: GlobalVariables.grey,
                  child: Builder(
                      builder: (context) => GridView.builder(
                          itemCount: _homeCareList[0].serviceList.length,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 7),
                          itemBuilder: (BuildContext context, int position) {
                            return getHomeCareDescriptionListItemLayout(
                                position);
                          })),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Charges',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Builder(
                      builder: (context) => ListView.builder(
                          itemCount: _homeCareList[0].chargesList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext contect, int position) {
                            return getHomeCareChargesListItemLayout(position);
                          })),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Tell us your requirment',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  height: 80,
                  child: TextField(
                    //maxLines: 99,
                    decoration: InputDecoration(
                      hintText: 'Write to us about your requirment',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Requester Details',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  /*decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: GlobalVariables.mediumGreen, width: 3.0)),*/
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Image.asset(
                            GlobalVariables.componentUserProfilePath,
                            width: 26,
                            height: 26,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          mail,
                                          style: TextStyle(
                                            color: GlobalVariables.lightGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        width: 1,
                                        color: GlobalVariables.lightGray,
                                        child: Divider(
                                          height: 10,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          mobile,
                                          style: TextStyle(
                                            color: GlobalVariables.lightGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration: BoxDecoration(
                                color:GlobalVariables.green,
                                borderRadius: BorderRadius.circular(30)),
                            child:Icon(Icons.edit,color: GlobalVariables.white,size: 20,)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            height: 45,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: ButtonTheme(
              // minWidth: MediaQuery.of(context).size.width/2,
              child: RaisedButton(
                color: GlobalVariables.green,
                onPressed: () {},
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.green)),
                child: Text(
                  AppLocalizations.of(context).translate('submit'),
                  style: TextStyle(fontSize: GlobalVariables.largeText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getHomeCareDescriptionListItemLayout(int position) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0), // width: 100,
      // color: GlobalVariables.grey,
      child: Container(
        // height: 50,
        child: Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: GlobalVariables.mediumGreen,
                  borderRadius: BorderRadius.circular(50)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(
                _homeCareList[0].serviceList[position].serviceName,
                style: TextStyle(color: GlobalVariables.green),
              ),
            )
          ],
        ),
      ),
    );
  }

  getHomeCareChargesListItemLayout(int position) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0), // width: 100,
      // color: GlobalVariables.grey,
      child: Column(
        children: <Widget>[
          Container(
            // height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: GlobalVariables.mediumGreen,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          _homeCareList[0].chargesList[position].chargesName,
                          style: TextStyle(color: GlobalVariables.green),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _homeCareList[0].chargesList[position].chargesPrice,
                    style: TextStyle(color: GlobalVariables.mediumGreen),
                  ),
                )
              ],
            ),
          ),
          _homeCareList[0].chargesList.length-1!=position ? Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Divider(
              color: GlobalVariables.grey,
              height: 3,
            ),
          ):Container()
        ],
      ),
    );
  }

  getHomeCareDescriptionList() {
    _homeCareList = [
      HomeCareDescription(
          title: "Siddhivinayak Traders",
          subDesc: "AC Repair and Maintanance",
          serviceDesc:
              "Fast and reliable Air-conditioner repair service provider at your door step. Repair Service. "
              "Best Repair Service and installation near you.",
          serviceList: [
            Services(serviceName: "Window AC Servicing"),
            Services(serviceName: "AC Installation"),
            Services(serviceName: "Split AC Repairing"),
            Services(serviceName: "Yearly Maintanance"),
            Services(serviceName: "Ducted AC Repairing"),
          ],
          chargesList: [
            Charges(
                chargesName: "AC Servicing", chargesPrice: "Start from Rs.500"),
            Charges(
                chargesName: "Yearly AMC", chargesPrice: "Start from Rs.1,500"),
            Charges(
                chargesName: "AC Installation",
                chargesPrice: "Start from Rs.1,000"),
          ])
    ];
  }


  void getSharedPrefData() {
    GlobalFunctions.getDisplayName().then((displayName) {
      name = displayName;
      GlobalFunctions.getUserName().then((displayMail) {
        mail = displayMail;
        GlobalFunctions.getMobile().then((displayMobile) {
          mobile = displayMobile;
          setState(() {});
        });
      });
    });
  }
}

class HomeCareDescription {
  String title, subDesc, serviceDesc;
  List<Services> serviceList;
  List<Charges> chargesList;

  HomeCareDescription(
      {this.title,
      this.subDesc,
      this.serviceDesc,
      this.serviceList,
      this.chargesList});
}

class Services {
  String serviceName;
  Services({this.serviceName});
}

class Charges {
  String chargesName, chargesPrice;
  Charges({this.chargesName, this.chargesPrice});
}
