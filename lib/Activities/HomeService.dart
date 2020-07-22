import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/Cab.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/GuestOthers.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseHomeService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeServiceState();
  }
}

class HomeServiceState extends State<BaseHomeService> {

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
                      getHomeServiceLayout(),
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

  getHomeServiceLayout() {
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
              child: Text(
                AppLocalizations.of(context).translate('visitor_arriving_on'),
                style: TextStyle(
                    color: GlobalVariables.green,
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
                    )*/),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: null,
                    onChanged: null,
                    isExpanded: false,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Text(
                        "Today",
                        style: TextStyle(
                            color: GlobalVariables.mediumGreen, fontSize: 16,fontWeight: FontWeight.w500),
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
                    color: GlobalVariables.mediumGreen,
                    width: 3.0,
                  )
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('name_of_person'),
                  hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 14),
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
                  hintText: AppLocalizations.of(context).translate('company_name'),
                  hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 14),
                  border: InputBorder.none
                ),
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
                    color: GlobalVariables.mediumGreen,
                    width: 3.0,
                  )),
              child: ButtonTheme(
                child: DropdownButton(
                  items: null,
                  onChanged: null,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: GlobalVariables.mediumGreen,
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
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('add'),
                    style: TextStyle(
                        fontSize: GlobalVariables.largeText),
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
                              child: Text(AppLocalizations.of(context)
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
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            BaseGuestOthers()));
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
            child: Text(
                AppLocalizations.of(context)
                    .translate('search_property'),
                style: TextStyle(
                  color: GlobalVariables.green,
                    fontSize: GlobalVariables.varyLargeText,)),
          )
        ],
      ),
    );
  }


}
