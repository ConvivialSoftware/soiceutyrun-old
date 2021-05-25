import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/Cab.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/GuestOthers.dart';
import 'package:societyrun/Activities/HomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseExpectedVisitor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpectedVisitorState();
  }
}

class ExpectedVisitorState extends BaseStatefulState<BaseExpectedVisitor>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<VisitorInfo> _visitorInfoList = new List<VisitorInfo>();

  var name = "", photo = "", societyId, flat, block, duesRs = "", duesDate = "";

  int position = 0;

  var username, password;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getVisitorInfoList();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
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
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          title: text(
            AppLocalizations.of(context).translate('expected_visitor'),
            textColor: GlobalVariables.white,
          ),
          // bottom: getTabLayout(),
          //elevation: 5,
        ),
        /* body: TabBarView(controller: _tabController, children: <Widget>[
          getMyTicketLayout(),
          getMyDocumentsLayout(),
        ]),*/
        body: getVisitorLayout(),
      ),
    );
  }

  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_activities'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('helpers'),
            ),
          )
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.grey,
        indicatorColor: GlobalVariables.green,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.green,
      ),
    );
  }

  getVisitorInfoList() {
    _visitorInfoList = [
      VisitorInfo(
          visitorName: "SavitaBai",
          visitorInOut: "Inside",
          visitorRate: "4.3",
          visitorTime: "Free : 9-11 am,12-2pm",
          visitorHours: "4 Hours",
          visitorAddress:
              "Room No 5, Maneklal Chawl, Ekta Nagar, Kandivali West Mumbai-400067",
          visitorMobile: "99999 99990",
          visitorDuty: "Cook"),
      VisitorInfo(
          visitorName: "Vidhya",
          visitorInOut: "",
          visitorRate: "4.7",
          visitorTime: "Free : 8-8:30 am,4-5pm",
          visitorHours: "7 Hours",
          visitorAddress:
              "Room No 5, Maneklal Chawl, Ekta Nagar, Kandivali West Mumbai-400067",
          visitorMobile: "99999 99990",
          visitorDuty: "Cook"),
      VisitorInfo(
          visitorName: "Ramesh",
          visitorInOut: "Inside",
          visitorRate: "4.3",
          visitorTime: "Free : 9-11 am,12-2pm",
          visitorHours: "3 Hours",
          visitorAddress:
              "Room No 5, Maneklal Chawl, Ekta Nagar, Kandivali West Mumbai-400067",
          visitorMobile: "99999 99990",
          visitorDuty: "Cook"),
      VisitorInfo(
          visitorName: "Ramesh",
          visitorInOut: "Inside",
          visitorRate: "4.3",
          visitorTime: "Free : 9-11 am,12-2pm",
          visitorHours: "3 Hours",
          visitorAddress:
              "Room No 5, Maneklal Chawl, Ekta Nagar, Kandivali West Mumbai-400067",
          visitorMobile: "99999 99990",
          visitorDuty: "Cook"),
    ];
  }

  getVisitorLayout() {
    print('MyTicketLayout Tab Call');
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
                    context, 130.0),
                getVisitorsCardLayout(),
                visitorFilterDateLayout(),
                getVisitorListData(), // getActivitiesListDataLayout(),
                //addActivitiesFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getVisitorListData() {
    return Container(
      color: GlobalVariables.veryLightGray, //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 2.1, 10, 10),
      child: Builder(
          builder: (context) => ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _visitorInfoList.length,
                itemBuilder: (context, position) {
                  return getVisitorListItemLayout(position);
                },
                //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getVisitorListItemLayout(int position) {
    return InkWell(
      onTap: () {
        GlobalFunctions.showToast('Click at : ' + position.toString());
        Dialog infoDialog = Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: getVisitorFullInfo(position),
        );
        showDialog(
            context: context, builder: (BuildContext context) => infoDialog);
      },
      onDoubleTap: () {
        GlobalFunctions.showToast('Click at : ' + position.toString());
        Dialog infoDialog = Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: getVisitorCall(position),
        );
        showDialog(
            context: context, builder: (BuildContext context) => infoDialog);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: GlobalVariables.lightGreen,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Container(
                          child: AppIcon(
                        Icons.call,
                        iconColor: GlobalVariables.lightGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      )),
                      Container(
                          margin: EdgeInsets.all(5), //TODO: Divider
                          height: 20,
                          width: 8,
                          child: VerticalDivider(
                            color: GlobalVariables.black,
                          )),
                      Container(
                          child: AppIcon(
                        Icons.share,
                        iconColor: GlobalVariables.lightGreen,
                        iconSize: GlobalVariables.textSizeNormal,
                      )),
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              // padding: EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Container(
                                    child: text(
                                      _visitorInfoList[position].visitorName,
                                      textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeMedium,
                                          fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                            child: Icon(
                                          Icons.star,
                                          color: GlobalVariables.skyBlue,
                                          size: 15,
                                        )),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(5, 0, 0, 0),
                                          child: text(
                                            _visitorInfoList[position]
                                                .visitorRate,
                                            textColor: GlobalVariables.grey,
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
                          Container(
                            // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                                color: _visitorInfoList[position]
                                            .visitorInOut
                                            .length ==
                                        0
                                    ? GlobalVariables.transparent
                                    : GlobalVariables.skyBlue,
                                borderRadius: BorderRadius.circular(10)),
                            child: text(
                              _visitorInfoList[position].visitorInOut,
                              textColor: GlobalVariables.white,
                                fontSize: GlobalVariables.textSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      color: GlobalVariables.mediumGreen,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Divider(
                        height: 2,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: text(
                              _visitorInfoList[position].visitorTime,
                              textColor: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeSmall,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: text(
                              _visitorInfoList[position].visitorHours,
                              textColor: GlobalVariables.mediumGreen,
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
      ),
    );
  }

  getVisitorsCardLayout() {
    return Container(
      //color: GlobalVariables.black,
      //width: MediaQuery.of(context).size.width / 1.1,
      margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 60, 0,
          0), //color: GlobalVariables.black,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                BaseCab()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(40, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: GlobalVariables.white,
                        ), // width: 150,
                        // height: 150,
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(AppLocalizations.of(context)
                                      .translate('cab'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                BaseDelivery()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 40, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: GlobalVariables.white,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(AppLocalizations.of(context)
                                      .translate('delivery'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                BaseHomeService()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(40, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: GlobalVariables.white,
                        ), // width: 150,
                        // height: 150,
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(AppLocalizations.of(context)
                                      .translate('home_services'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                BaseGuestOthers()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 40, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: GlobalVariables.white,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(AppLocalizations.of(context)
                                      .translate('guests_other'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getMyDocumentsLayout() {
    print('MyDocumentsLayout Tab Call');
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
                    context, 130.0), //ticketOpenClosedLayout(),
                //   getDocumentListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  visitorFilterDateLayout() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height / 2.7, 0, 0),
          child: text(
            AppLocalizations.of(context).translate('find_helper'),
            textColor: GlobalVariables.green, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            //width: MediaQuery.of(context).size.width / 1.1,
            height: 50,
            margin: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).size.height / 60, 0, 0),
            decoration: BoxDecoration(
              color: GlobalVariables.transparent,
              //  borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: TextField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              hintText: "Search",
                              hintStyle: TextStyle(
                                  color: GlobalVariables.veryLightGray),
                              border: InputBorder.none,
                              suffixIcon: AppIcon(
                                Icons.search,
                                iconColor: GlobalVariables.mediumGreen,
                              )),
                        ),
                      )),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: TextField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              hintText: "Filter",
                              hintStyle: TextStyle(
                                  color: GlobalVariables.veryLightGray),
                              border: InputBorder.none,
                              suffixIcon: AppIcon(
                                Icons.search,
                                iconColor: GlobalVariables.mediumGreen,
                              )),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  getVisitorFullInfo(int position) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: GlobalVariables.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(1.15, -1.15),
            child: Container(
              decoration: BoxDecoration(
                color: GlobalVariables.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: AppIcon(
                    Icons.close,
                    iconColor: GlobalVariables.white,
                    iconSize: 30,
                  )),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: GlobalVariables.white),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: GlobalVariables.white,
                          //margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              GlobalVariables.lightGreen,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Container(
                                              child: text(
                                                _visitorInfoList[position]
                                                    .visitorName,
                                                textColor:
                                                        GlobalVariables.green,
                                                    fontSize: GlobalVariables.textSizeMedium,
                                                    fontWeight:
                                                        FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 15, 0, 0),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                      child: Icon(
                                                    Icons.star,
                                                    color:
                                                        GlobalVariables.orangeYellow,
                                                    size: 15,
                                                  )),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        5, 0, 0, 0),
                                                    child: text(
                                                      _visitorInfoList[position]
                                                          .visitorRate,
                                                      textColor: GlobalVariables
                                                            .black,
                                                        fontSize:  GlobalVariables.textSizeSmall,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 5, 20, 5),
                                              decoration: BoxDecoration(
                                                  color:
                                                      GlobalVariables.skyBlue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: text(
                                                _visitorInfoList[position]
                                                    .visitorDuty,
                                                textColor: GlobalVariables.white,
                                                  fontSize:  GlobalVariables.textSizeSmall,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 15, 0, 0),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                    child: text(
                                                      _visitorInfoList[position]
                                                          .visitorHours,
                                                      textColor: GlobalVariables
                                                            .mediumGreen,
                                                        fontSize:  GlobalVariables.textSizeSmall,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
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
                ),
                Container(
                 // color: GlobalVariables.veryLightGray,
                  margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                          child: Container(
                           // color: GlobalVariables.veryLightGray,
                            alignment: Alignment.topLeft,

                        child: AppIcon(
                          Icons.location_on,
                          iconColor: GlobalVariables.mediumGreen,
                        ),
                      )),
                      Flexible(
                          flex:2,
                          child: Container(
                           // color: GlobalVariables.veryLightGray,
                            alignment: Alignment.topLeft,
                        child: text(
                          AppLocalizations.of(context).translate('address') +
                              ":",
                         textColor: GlobalVariables.green,
                            fontSize:  GlobalVariables.textSizeSMedium,
                        ),
                      )),
                      Flexible(
                          flex: 5,
                          child: Container(
                            alignment: Alignment.topCenter,
                            margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
                        child: text(
                          _visitorInfoList[position].visitorAddress,
                          textColor: GlobalVariables.mediumGreen,
                            fontSize: GlobalVariables.textSizeSMedium,
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  height: 10, // width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.all(15),
                  child: Divider(
                    height: 5,
                    color: GlobalVariables.mediumGreen,
                  ),
                ),
                Container(
                //  color: GlobalVariables.veryLightGray,
                  margin: EdgeInsets.fromLTRB(20, 20, 10, 0),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: AppIcon(
                          Icons.phone_android,
                          iconColor: GlobalVariables.mediumGreen,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: text(
                          AppLocalizations.of(context).translate('mobile') +
                              ":",
                          textColor: GlobalVariables.green,
                            fontSize:  GlobalVariables.textSizeSMedium,
                        ),
                      ),
                      Expanded(
                        //  flex: 10,
                          child: Container(
                           //color: GlobalVariables.grey,
                            margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: text(
                              _visitorInfoList[position].visitorMobile,
                              textColor: GlobalVariables.mediumGreen,
                                fontSize:  GlobalVariables.textSizeSMedium,
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 10, // width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.all(15),
                  child: Divider(
                    height: 5,
                    color: GlobalVariables.mediumGreen,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 25, 10, 0),
                  alignment: Alignment.center,
                  child: text(
                    _visitorInfoList[position].visitorTime,
                    textColor: GlobalVariables.green,
                      fontSize:  GlobalVariables.textSizeMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getVisitorCall(int position) {
    return Container(
      width: 320,
      height: 280,
      decoration: BoxDecoration(
        color: GlobalVariables.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(1.15, -1.15),
            child: Container(
              decoration: BoxDecoration(
                color: GlobalVariables.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: AppIcon(
                    Icons.close,
                    iconColor: GlobalVariables.white,
                    iconSize: GlobalVariables.textSizeXLarge,
                  )),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(20, 25, 10, 0),
                  alignment: Alignment.center,
                  child: text(
                    'A-103 Customer Demo Society',
                    textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeSMedium,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 25, 10, 0),
                  alignment: Alignment.center,
                  child: text(
                    'Guest is waiting at the gate',
                    textColor: GlobalVariables.green,
                      fontSize: GlobalVariables.textSizeNormal,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  // color: GlobalVariables.veryLightGray,
                  margin: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                          GlobalVariables.lightGreen,
                        ),
                      ),
                      Container(
                        // color: GlobalVariables.veryLightGray,
                        alignment: Alignment.topLeft,
                        child: text(
                          _visitorInfoList[position].visitorName,
                          textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeNormal,
                        ),
                      ),
                      Container(
                        child: AppIcon(
                          Icons.call,
                          iconColor: GlobalVariables.mediumGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10, // width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.all(15),
                  child: Divider(
                    height: 5,
                    color: GlobalVariables.mediumGreen,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  //  color: GlobalVariables.veryLightGray,
                  margin: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            child: AppIcon(
                              Icons.cancel,
                              iconColor: GlobalVariables.grey,
                              iconSize: 50,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: text("DENY",
                              textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeLargeMedium,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: <Widget>[
                          Container(
                            child: AppIcon(
                              Icons.check_circle,
                              iconColor: GlobalVariables.green,
                              iconSize: 50.0,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: text("APPROVE",
                              textColor: TextStyle(
                                color: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeLargeMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class VisitorInfo {
  String visitorName,
      visitorInOut,
      visitorRate,
      visitorTime,
      visitorHours,
      visitorAddress,
      visitorMobile,
      visitorDuty;

  VisitorInfo(
      {this.visitorName,
      this.visitorInOut,
      this.visitorRate,
      this.visitorTime,
      this.visitorHours,
      this.visitorAddress,
      this.visitorMobile,
      this.visitorDuty});
}
