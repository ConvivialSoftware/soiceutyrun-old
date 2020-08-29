import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

import 'base_stateful.dart';

class BaseCreateClassifiedListing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreateClassifiedListingState();
  }
}

class CreateClassifiedListingState extends BaseStatefulState<BaseCreateClassifiedListing> {
  var name="", mobile="", mail="";

  @override
  void initState() {
    super.initState();
    getSharedPrefData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.darkBlue,
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
            AppLocalizations.of(context).translate('create_listing'),
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
                getCreateClassifiedListingLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getCreateClassifiedListingLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('add_new_listing'),
                  style: TextStyle(
                      color: GlobalVariables.darkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                      AppLocalizations.of(context).translate('select_category'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 12),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('i_want_to'),
                  style: TextStyle(
                      color: GlobalVariables.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: GlobalVariables.darkBlue,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: GlobalVariables.darkBlue,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('sell'),
                                  style: TextStyle(
                                      color: GlobalVariables.darkBlue,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
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
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context).translate('buy'),
                                  style: TextStyle(
                                      color: GlobalVariables.darkBlue,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
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
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('rent'),
                                  style: TextStyle(
                                      color: GlobalVariables.darkBlue,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
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
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('giveaway'),
                                  style: TextStyle(
                                      color: GlobalVariables.darkBlue,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10,0,0,0),
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('title_selling'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
                      border: InputBorder.none),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.fromLTRB(10,0,0,0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  maxLines: 99,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('description_selling'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
                      border: InputBorder.none),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width/2,
                        padding: EdgeInsets.fromLTRB(10,0,0,0),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 3.0,
                            )),
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                  .translate('property_details'),
                              hintStyle: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 16),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                          width: MediaQuery.of(context).size.width/2,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.mediumGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.transparent,
                              width: 3.0,
                            )),
                        child: FlatButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.camera_alt,
                              color: GlobalVariables.white,
                            ),
                            label: Text(
                              AppLocalizations.of(context)
                                  .translate('add_photo'),
                              style: TextStyle(color: GlobalVariables.white),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10,0,0,0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Rs.",
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 16),
                      border: InputBorder.none),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 1,
                color: GlobalVariables.lightGray,
                child: Divider(
                  height: 1,
                  color: GlobalVariables.lightGray,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: GlobalVariables.mediumGreen, width: 3.0)),
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
                                      color: GlobalVariables.darkBlue,
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
                            color:GlobalVariables.darkBlue,
                            borderRadius: BorderRadius.circular(30)),
                        child:Icon(Icons.edit,color: GlobalVariables.white,size: 20,)
                      ),
                    ],
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
                    color: GlobalVariables.darkBlue,
                    onPressed: () {},
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: GlobalVariables.darkBlue)),
                    child: Text(
                      AppLocalizations.of(context).translate('submit'),
                      style: TextStyle(fontSize: GlobalVariables.largeText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
