import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/GuestOthers.dart';
import 'package:societyrun/Activities/HomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAddNearByShop extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddNearByShopState();
  }
}

class AddNearByShopState extends State<BaseAddNearByShop> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('add_near_by_shop'),
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
                      getAddNearByShopLayout(),
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

  getAddNearByShopLayout() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
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
              child: text(
                  AppLocalizations.of(context).translate('add_near_by_shop'),
                  textColor: GlobalVariables.primaryColor,
                  fontSize: GlobalVariables.textSizeLargeMedium,
                  fontWeight: FontWeight.bold),
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
                        AppLocalizations.of(context).translate('shop_name'),
                    hintStyle: TextStyle(
                        color: GlobalVariables.lightGray, fontSize: 14),
                    border: InputBorder.none),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: Container(
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
                        icon: AppIcon(
                          Icons.keyboard_arrow_down,
                          iconColor: GlobalVariables.secondaryColor,
                        ),
                        underline: SizedBox(),
                        hint: text(
                          AppLocalizations.of(context)
                              .translate('service_type'),
                          textColor: GlobalVariables.lightGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                      color: GlobalVariables.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AppIcon(
                      Icons.add,
                      iconColor: GlobalVariables.white,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: Container(
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
                      maxLength: 10,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('phone_number'),
                          hintStyle: TextStyle(
                              color: GlobalVariables.lightGray, fontSize: 14),
                          border: InputBorder.none,
                          counterText: ''),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                      color: GlobalVariables.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AppIcon(
                      Icons.add,
                      iconColor: GlobalVariables.white,
                    ),
                  ),
                ),
              ],
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
                        AppLocalizations.of(context).translate('email_id'),
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
                    hintText: AppLocalizations.of(context).translate('website'),
                    hintStyle: TextStyle(
                        color: GlobalVariables.lightGray, fontSize: 14),
                    border: InputBorder.none),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    decoration: BoxDecoration(
                        color: GlobalVariables.secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: GlobalVariables.transparent,
                          width: 3.0,
                        )),
                    child: TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.camera_alt,
                          color: GlobalVariables.white,
                        ),
                        label: Text(
                          AppLocalizations.of(context).translate('add_photo'),
                          style: TextStyle(color: GlobalVariables.white),
                        )),
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
                child: MaterialButton(
                  color: GlobalVariables.primaryColor,
                  onPressed: () {},
                  textColor: GlobalVariables.white,
                  //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: GlobalVariables.primaryColor)),
                  child: Text(
                    AppLocalizations.of(context).translate('submit'),
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
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
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
