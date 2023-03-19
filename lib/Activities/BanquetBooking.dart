import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class BaseBanquetBooking extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BanquetBookingState();
  }
}

class BanquetBookingState extends State<BaseBanquetBooking> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('new_booking'),
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
                getRaiseTicketLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRaiseTicketLayout() {
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
                  AppLocalizations.of(context).translate('banquet_booking'),
                  style: TextStyle(
                      color: GlobalVariables.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                //color: GlobalVariables.black,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        //  color: GlobalVariables.grey,
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context).translate('booking_for'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                              'Customer Demo Society A 103',
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context).translate('date'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                              '15/03/2020',
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context).translate('slot'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                              '06:00 to 09:00',
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context).translate('rate'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Rs. 2500.00',
                          style: TextStyle(
                              color: GlobalVariables.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('special_request'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(10),
                        // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.secondaryColor,
                              width: 3.0,
                            )),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('enter_ur_requirement'),
                          style: TextStyle(
                              color: GlobalVariables.lightGray, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment(-1, -1),
                        child: Text(
                          AppLocalizations.of(context).translate('remark'),
                          style: TextStyle(
                              color: GlobalVariables.secondaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.secondaryColor,
                              width: 3.0,
                            )),
                        child: TextField(
                          maxLines: 99,
                          decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                  .translate('text_here'),
                              hintStyle: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topLeft,
                        height: 45,
                        child: ButtonTheme(
                          // minWidth: MediaQuery.of(context).size.width/2,
                          child: MaterialButton(
                            color: GlobalVariables.primaryColor,
                            onPressed: () {},
                            textColor: GlobalVariables.white,
                            //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: GlobalVariables.primaryColor)),
                            child: Text(
                              AppLocalizations.of(context).translate('submit'),
                              style: TextStyle(
                                  fontSize: GlobalVariables.textSizeMedium),
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
      ),
    );
  }
}
