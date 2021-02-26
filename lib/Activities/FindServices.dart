import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/ListOfHomeService.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppImage.dart';
import 'package:societyrun/utils/AppWidget.dart';
import 'base_stateful.dart';

class BaseFindServices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DiscoverState();
  }
}

class DiscoverState extends BaseStatefulState<BaseFindServices> {
  var width, height;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
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
            AppLocalizations.of(context).translate('discover'),
            style: TextStyle(color: GlobalVariables.white, fontSize: 16),
          ),
          //bottom: getTabLayout(),
          //elevation: 0,
        ),
        body: getServiceLayout(),
      ),
    );
  }

  getServiceLayout() {
    print('getClassifiedLayout Tab Call');
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
                    context, 150.0),
                getServiceTypeDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getServiceTypeDataLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 10, 0,
          0), //color: GlobalVariables.black,
      child: Container(
          child: Builder(
              builder: (context) => GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, position) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseListOfHomeService()));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: width / 5.5,
                          height: width / 6,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: GlobalVariables.white,
                          ),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: AppNetworkImage(
                                    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
                                    30.0,
                                    30.0,
                                    borderColor: GlobalVariables.grey,
                                    borderWidth: 1.0,
                                    fit: BoxFit.cover,
                                    radius: 15.0,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                    child: Text(AppLocalizations.of(context)
                                        .translate('home_care'))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, //  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  ))
          /*Column(
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseListOfHomeService()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('home_care'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('pest_control'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('laundry'))),
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
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('move_in_out'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('health'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('govt_legal'))),
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
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('event_organiser'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('kids'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                child: SvgPicture.asset(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(AppLocalizations.of(context)
                                      .translate('other_services'))),
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
        ),*/
          ),
    );
  }
}