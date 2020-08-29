import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/BanquetBooking.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/MemberResponse.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseFacilities extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FacilitiesState();
  }
}

class FacilitiesState extends BaseStatefulState<BaseFacilities> {

  List<BookingHistory> _bookingHistoryList = List<BookingHistory>();

  @override
  void initState() {
    super.initState();
    getBookingHistoryList();
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
            AppLocalizations.of(context).translate('facilities'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getFacilitiesLayout(),
      ),
    );
  }

   getFacilitiesLayout() {
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
                getFacilitiesCardLayout(),
                //addActivitiesFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getFacilitiesCardLayout() {
    return Container(
      //color: GlobalVariables.black,
      //width: MediaQuery.of(context).size.width / 1.1,
      margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 60, 0,
          0), //color: GlobalVariables.black,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),

        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight:  Radius.circular(15.0),
                  bottomLeft:  Radius.circular(0),
                  bottomRight:  Radius.circular(0),

                ),
                color: GlobalVariables.white,
              ),
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
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        // width: 150,
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
                                      .translate('club_house'))),
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
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

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
                                      .translate('swimming_pool'))),
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
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

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
                                      .translate('banquet'))),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight:  Radius.circular(0),
                  bottomLeft:  Radius.circular(15.0),
                  bottomRight:  Radius.circular(15.0),

                ),
                color: GlobalVariables.white,
              ),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        // width: 150,
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
                                      .translate('kids_area'))),
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
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

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
                                      .translate('indoor_games'))),
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
                                BaseBanquetBooking()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

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
                                      .translate('outdoor_games'))),
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
              alignment: Alignment.topLeft, //color: GlobalVariables.white,
              margin: EdgeInsets.fromLTRB(5, 30, 0, 0),
              child: Text(
                AppLocalizations.of(context).translate('my_booking_history'),
                style: TextStyle(
                  color: GlobalVariables.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Builder(
                      builder: (context) => ListView.builder(
                        itemCount: _bookingHistoryList.length,
                        itemBuilder: (context, position) {
                          return getListItemLayout(position);
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
                ),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //color: GlobalVariables.white,
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            AppLocalizations.of(context).translate('view_more'),
                            style: TextStyle(
                                color: GlobalVariables.darkBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        Container(
                          child: Icon(
                            Icons.fast_forward,
                            color: GlobalVariables.darkBlue,
                          ),
                        )
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
  getListItemLayout(var position) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
             Container(
               child: Row(
                 children: <Widget>[
                   Container(
                     alignment: Alignment.topLeft,
                     padding: EdgeInsets.all(5),
                     child: Text(
                       _bookingHistoryList[position].date,
                       style: TextStyle(
                           color: GlobalVariables.mediumGreen, fontSize: 16),
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                     alignment: Alignment.topLeft,
                     padding: EdgeInsets.all(5),
                     child: Text(
                       _bookingHistoryList[position].facilitiesType,
                       style: TextStyle(
                           color: GlobalVariables.mediumGreen, fontSize: 16),
                     ),
                   ),
                 ],
               ),
             ),
              Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  _bookingHistoryList[position].payPrice,
                  style: TextStyle(
                      color: GlobalVariables.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: GlobalVariables.mediumGreen,
          height: 1,
        ),
      ],
    );
  }

  void getBookingHistoryList() {

    _bookingHistoryList = [

      BookingHistory(date: "13/02/2020",facilitiesType: "Banquet",payPrice: "Rs. 5000.00"),
      BookingHistory(date: "11/01/2020",facilitiesType: "Club House",payPrice: "Rs. 3000.00"),
      BookingHistory(date: "14/08/2019",facilitiesType: "Outdoor Games",payPrice: "Rs. 500.00"),
      BookingHistory(date: "14/08/2019",facilitiesType: "Indoor Games",payPrice: "Rs. 500.00"),
      BookingHistory(date: "25/03/2019",facilitiesType: "Kids Area",payPrice: "Rs. 1500.00"),
      BookingHistory(date: "13/01/2019",facilitiesType: "Banquet",payPrice: "Rs. 3000.00"),


    ];

  }
}

class BookingHistory {
  
  String date,facilitiesType,payPrice;

  BookingHistory({this.date, this.facilitiesType, this.payPrice});


}
