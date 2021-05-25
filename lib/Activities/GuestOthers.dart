import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/Cab.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/HomeService.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseGuestOthers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createS tate
    return GuestOthersState();
  }
}

class GuestOthersState extends BaseStatefulState<BaseGuestOthers> {
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
            child:AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          title: text(
            AppLocalizations.of(context).translate('guests_other'),
            textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeMedium
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
                      getGuestOthersLayout(),
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

  getGuestOthersLayout() {
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
              child: text(
                AppLocalizations.of(context).translate('guest_other_arriving_on'),
                textColor: GlobalVariables.green,
                    fontSize: GlobalVariables.textSizeLargeMedium,
                    fontWeight: FontWeight.bold,
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
                    )*/),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: null,
                    onChanged: null,
                    isExpanded: false,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child:  text(
                        "Today",
                       textColor: GlobalVariables.mediumGreen, fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
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
                          color: GlobalVariables.mediumGreen,
                          width: 3.0,
                        )
                    ),
                    child: TextField(
                      maxLength: 10,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('add_name_from_contact'),
                          hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                          border: InputBorder.none,
                          counterText: '',
                          suffixIcon: AppIcon(
                            Icons.contacts,
                            iconColor: GlobalVariables.mediumGreen,
                          )

                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: text('OR',textColor: GlobalVariables.mediumGreen,fontSize: GlobalVariables.textSizeMedium
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.mediumGreen,
                    width: 3.0,
                  )
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('enter_name'),
                    hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                    border: InputBorder.none
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
                    color: GlobalVariables.mediumGreen,
                    width: 3.0,
                  )
              ),
              child: TextField(
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('mobile_no'),
                    hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                    border: InputBorder.none
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
              alignment: Alignment.topLeft,
              child: text(
                AppLocalizations.of(context).translate('frequently_guest_other_running'),
                textColor: GlobalVariables.green,
                    fontSize: GlobalVariables.textSizeLargeMedium,
                    fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                  color: GlobalVariables.green,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: GlobalVariables.green,
                                    width: 2.0,
                                  )),
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                AppLocalizations.of(context)
                                    .translate('once'),
                                textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeMedium),
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
                                    color: GlobalVariables.mediumGreen,
                                    width: 2.0,
                                  )),
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                AppLocalizations.of(context)
                                    .translate('frequently'),
                                textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeMedium,
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
              alignment: Alignment.topLeft,
              height: 45,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: ButtonTheme(
               // minWidth: MediaQuery.of(context).size.width/2,
                child: RaisedButton(
                  color: GlobalVariables.green,
                  onPressed: () {

                  },
                  textColor: GlobalVariables.white,
                  //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                  ),
                  child: text(
                    AppLocalizations.of(context)
                        .translate('add'),
                        fontSize: GlobalVariables.textSizeMedium,
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
          margin: EdgeInsets.fromLTRB(5,0, 5,0),
          padding: EdgeInsets.fromLTRB(5,0,5,0),
          child: Row(
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
                              child: text(AppLocalizations.of(context)
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
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            BaseHomeService()));
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
                              child: text(AppLocalizations.of(context)
                                  .translate('home_services'))),
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
        color: GlobalVariables.lightGreen,
        borderRadius: BorderRadius.circular(10)
      ),
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
            child: text(
                AppLocalizations.of(context)
                    .translate('search_property'),
                textColor: GlobalVariables.green,
                    fontSize: GlobalVariables.varyLargeText,),
          )
        ],
      ),
    );


  }
}
