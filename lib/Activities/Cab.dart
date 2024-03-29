import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/GuestOthers.dart';
import 'package:societyrun/Activities/HomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseCab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CabState();
  }
}

class CabState extends State<BaseCab> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('cab'),
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
                      getCabLayout(),
                      getOtherVisitorCardLayout(),
                      getSearchPropertyLayout(),
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

  getCabLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 40, 10, 20),
      padding: EdgeInsets.all(20),
      // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(20)),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                AppLocalizations.of(context).translate('cab_arriving_on'),
                style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                //alignment: Alignment.topLeft,
                //width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  /*borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )*/
                ),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: null,
                    onChanged: null,
                    isExpanded: false,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.secondaryColor,
                    ),
                    underline: SizedBox(),
                    hint: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Text(
                        "Today",
                        style: TextStyle(
                            color: GlobalVariables.secondaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.secondaryColor,
                    width: 3.0,
                  )),
              child: TextField(
                decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).translate('company_name'),
                    hintStyle: TextStyle(
                        color: GlobalVariables.lightGray, fontSize: 14),
                    border: InputBorder.none),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.secondaryColor,
                    width: 3.0,
                  )),
              child: TextField(
                decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).translate('vehicle_no') +
                            " (Enter last 4 digit)",
                    hintStyle: TextStyle(
                        color: GlobalVariables.lightGray, fontSize: 14),
                    border: InputBorder.none),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.secondaryColor,
                    width: 3.0,
                  )),
              child: ButtonTheme(
                child: DropdownButton(
                  items: null,
                  onChanged: null,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: GlobalVariables.secondaryColor,
                  ),
                  underline: SizedBox(),
                  hint: Text(
                    AppLocalizations.of(context).translate('flat_no'),
                    style: TextStyle(
                        color: GlobalVariables.lightGray, fontSize: 14),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
              alignment: Alignment.topLeft,
              child: Text(
                AppLocalizations.of(context)
                    .translate('frequently_cab_running'),
                style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Container(
              // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: InkWell(
                      //  splashColor: GlobalVariables.mediumGreen,
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: GlobalVariables.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: GlobalVariables.primaryColor,
                                    width: 2.0,
                                  )),
                              child: Icon(Icons.check,
                                  color: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                AppLocalizations.of(context).translate('once'),
                                style: TextStyle(
                                    color: GlobalVariables.primaryColor,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: InkWell(
                      //  splashColor: GlobalVariables.mediumGreen,
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: GlobalVariables.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: GlobalVariables.secondaryColor,
                                    width: 2.0,
                                  )),
                              child: Icon(Icons.check,
                                  color: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('frequently'),
                                style: TextStyle(
                                    color: GlobalVariables.primaryColor,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )),
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        hintText: AppLocalizations.of(context)
                            .translate('valid_till'),
                        hintStyle:
                            TextStyle(color: GlobalVariables.veryLightGray),
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.date_range,
                          color: GlobalVariables.secondaryColor,
                        )),
                  ),
                )),
            Container(
              alignment: Alignment.topLeft,
              height: 45,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: ButtonTheme(
                // minWidth: MediaQuery.of(context).size.width/2,
                child: MaterialButton(
                  color: GlobalVariables.primaryColor,
                  onPressed: () {},
                  textColor: GlobalVariables.white,
                  //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: GlobalVariables.primaryColor)),
                  child: Text(
                    AppLocalizations.of(context).translate('add'),
                    style: TextStyle(fontSize: GlobalVariables.textSizeMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getOtherVisitorCardLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseDelivery()));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                                  .translate('delivery'))),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseHomeService()));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseGuestOthers()));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
    );
  }

  getSearchPropertyLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
          color: GlobalVariables.AccentColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SvgPicture.asset(GlobalVariables.classifiedBigIconPath),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            alignment: Alignment.center,
            child:
                Text(AppLocalizations.of(context).translate('search_property'),
                    style: TextStyle(
                      color: GlobalVariables.primaryColor,
                      fontSize: GlobalVariables.varyLargeText,
                    )),
          )
        ],
      ),
    );
  }
}
