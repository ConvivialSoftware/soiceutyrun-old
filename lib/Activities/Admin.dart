import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddExpense.dart';
import 'package:societyrun/Activities/Broadcast.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/HelpDesk.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/UnitDetails.dart';
import 'package:societyrun/Activities/UserManagement.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/MonthExpensePendingRequestResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class BaseAdmin extends StatefulWidget {
  @override
  _BaseAdminState createState() => _BaseAdminState();
}

class _BaseAdminState extends State<BaseAdmin> {
  List<SliderCardName> _listSliderCardName = <SliderCardName>[];

  //List<BarChartModel> _listBarChart = <BarChartModel>[];
  int pageCount = 0;

  @override
  void initState() {
    Provider.of<UserManagementResponse>(context, listen: false)
        .getUserManagementDashboard();
    Provider.of<UserManagementResponse>(context, listen: false)
        .getMonthExpensePendingRequestData();
    getSliderCardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context, value, child) {
        return Builder(
            builder: (context) => Scaffold(
                  backgroundColor: GlobalVariables.white,
                  appBar: AppBar(
                    title: text(AppLocalizations.of(context).translate('admin'),
                        textColor: GlobalVariables.white),
                    leading: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back)),
                  ),
                  body: getBaseAdminLayout(value),
                ));
      }),
    );
  }

  getBaseAdminLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
          value.isLoading
              ? Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/3),
              child: GlobalFunctions.loadingWidget(context))
              : getAdminLayout(value),
        ],
      ),
    );
  }

  List<Widget> buildDotIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _listSliderCardName.length; i++) {
      list.add(i == pageCount
          ? indicator(isActive: true, activeColor: GlobalVariables.primaryColor)
          : indicator(isActive: false));
    }
    return list;
  }

  getAdminLayout(UserManagementResponse value) {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            CarouselSlider.builder(
                itemCount: _listSliderCardName.length,
                itemBuilder: (BuildContext context, int position, int item) {
                  switch (position) {
                    case 0:
                      return getComplaintDataLayout(value);
                      break;
                    case 1:
                      return getUserLayout(value);
                      break;
                    case 2:
                      return getERPLayout(value);
                      break;
                    default:
                      return AppContainer();
                  }
                },
                options: CarouselOptions(
                    height: 230.0,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                    viewportFraction: 1.0,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    onPageChanged: (index, _carouselPageChangedReason) {
                      print(
                          'reason : ' + _carouselPageChangedReason.toString());
                      setState(() {
                        pageCount = index;
                      });
                    })),
            // SizedBox(height: 8,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buildDotIndicator(),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              //color: GlobalVariables.grey,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          // if (AppUserPermission.isUserBroadcastPermission) {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseBroadcast()))
                              .then((value) {
                            GlobalFunctions.setBaseContext(context);
                          });
                          /*} else {
                            GlobalFunctions
                                .showAdminPermissionDialogToAccessFeature(
                                    context, true);
                          }*/
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          decoration: BoxDecoration(
                              color: GlobalVariables.AccentColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AppAssetsImage(
                                GlobalVariables.emailIconPath,
                                imageWidth: 28.0,
                                imageHeight: 28.0,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              text(
                                  AppLocalizations.of(context)
                                      .translate('broadcast'),
                                  fontSize: GlobalVariables.textSizeSMedium)
                            ],
                          ),
                        ),
                      )),
                  Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          if(AppUserPermission.isUserAccountingPermission) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseUnitDetails(isDuesUnit: true)));
                          }else{
                            GlobalFunctions
                                .showAdminPermissionDialogToAccessFeature(
                                context, true);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          decoration: BoxDecoration(
                              color: GlobalVariables.AccentColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AppAssetsImage(
                                GlobalVariables.receiptIconPath,
                                imageWidth: 28.0,
                                imageHeight: 28.0,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              text(
                                  AppLocalizations.of(context)
                                      .translate('add_receipt'),
                                  fontSize: GlobalVariables.textSizeSMedium),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            ),
            InkWell(
              onTap: () {
                // if (!AppUserPermission.isUserUserManagementPermission) {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseUserManagement()))
                    .then((value) {
                  GlobalFunctions.setBaseContext(context);
                });
                /*} else {
                  GlobalFunctions.showAdminPermissionDialogToAccessFeature(
                      context, true);
                }*/
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                    color: GlobalVariables.AccentColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppAssetsImage(
                      GlobalVariables.userIconPath,
                      imageWidth: 28.0,
                      imageHeight: 28.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    text(
                        AppLocalizations.of(context)
                            .translate('user_management'),
                        fontSize: GlobalVariables.textSizeSMedium)
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                color: GlobalVariables.transparent,
                child: Card(
                  shape: (RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
                  elevation: 10.0,
                  shadowColor: GlobalVariables.primaryColor.withOpacity(0.2),
                  margin: EdgeInsets.all(16),
                  color: GlobalVariables.white,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Center(
                        child: BarChart(
                          data: value.monthExpenseList,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            value.adminPendingList.length > 0
                ? Container(
                    alignment: Alignment.topLeft,
                    //color: GlobalVariables.white,
                    margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: text(
                      AppLocalizations.of(context)
                          .translate('pending_transaction'),
                      textColor: GlobalVariables.black,
                      fontSize: GlobalVariables.textSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
            value.adminPendingList.length > 0
                ? Container(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    decoration: boxDecoration(
                        color: GlobalVariables.veryLightGray, width: 0.5),
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  /*value.adminPendingList.length >= 3
                                        ? 3
                                        : */
                                  value.adminPendingList.length,
                              itemBuilder: (context, position) {
                                return getPendingListItemLayout(
                                    position, value);
                              }, //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  )
                : Container(),
            SizedBox(
              height: 8,
            ),
          ],
        )
      ],
    );
  }

  void getSliderCardData() {
    SliderCardName scn0 = SliderCardName(0, "Complaint");
    _listSliderCardName.add(scn0);

    SliderCardName scn1 = SliderCardName(1, "User");
    _listSliderCardName.add(scn1);

    SliderCardName scn2 = SliderCardName(2, "ERP");
    _listSliderCardName.add(scn2);
  }

  getComplaintDataLayout(UserManagementResponse value) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          elevation: 10.0,
          shadowColor: GlobalVariables.primaryColor.withOpacity(0.2),
          margin: EdgeInsets.all(16),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppAssetsImage(
                    GlobalVariables.whileBGPath,
                    imageHeight: 100,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    text('Complaints',
                        isCentered: true,
                        fontSize: GlobalVariables.textSizeNormal,
                        textColor: GlobalVariables.primaryColor,
                        fontWeight: FontWeight.bold),
                    SizedBox(
                      height: 16,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  text(value.openComplaint,
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeNormal,
                                      fontWeight: FontWeight.bold),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  text('Open',
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeMedium)
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(),
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  text(value.closeComplaint,
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeNormal,
                                      fontWeight: FontWeight.bold),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  text('Closed',
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeMedium)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BaseRaiseNewTicket(isAdmin: true)))
                                .then((value) {
                              GlobalFunctions.setBaseContext(context);
                            });
                          },
                          child: text('Add Complaint',
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseHelpDesk(true))).then((value) {
                              GlobalFunctions.setBaseContext(context);
                            });
                          },
                          child: text('View Complaint',
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getUserLayout(UserManagementResponse value) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseUserManagement())).then((value) {
            GlobalFunctions.setBaseContext(context);
          });
        },
        child: Container(
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 10.0,
            shadowColor: GlobalVariables.primaryColor.withOpacity(0.2),
            margin: EdgeInsets.all(16),
            color: GlobalVariables.white,
            child: Stack(
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AppAssetsImage(
                      GlobalVariables.whileBGPath,
                      imageHeight: 100,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      text('Users',
                          isCentered: true,
                          fontSize: GlobalVariables.textSizeNormal,
                          textColor: GlobalVariables.primaryColor,
                          fontWeight: FontWeight.bold),
                      SizedBox(
                        height: 16,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    text(value.noOfUnits,
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize: GlobalVariables.textSizeNormal,
                                        fontWeight: FontWeight.bold),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    text('Units',
                                        textColor: GlobalVariables.black,
                                        fontSize: GlobalVariables.textSizeMedium)
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(),
                            SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        text('Register User',
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(value.registerUser,
                                            textColor: GlobalVariables.primaryColor,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        text('Active Users',
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(value.activeUser,
                                            textColor: GlobalVariables.primaryColor,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        text('Mobile Users',
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(value.mobileUser,
                                            textColor: GlobalVariables.primaryColor,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseUserManagement())).then((value) {
                                GlobalFunctions.setBaseContext(context);
                              });
                            },
                            child: text(
                                (int.parse(value.rentalRequest) +
                                            int.parse(value.pendingRequest) +
                                            int.parse(value.moveOutRequest))
                                        .toString() +
                                    ' Pending Request*',
                                textColor: GlobalVariables.red,
                                fontSize: GlobalVariables.textSizeSMedium),
                          ),
                          // text('View Complaint',textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getERPLayout(UserManagementResponse value) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          elevation: 10.0,
          shadowColor: GlobalVariables.primaryColor.withOpacity(0.2),
          margin: EdgeInsets.all(16),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppAssetsImage(
                    GlobalVariables.whileBGPath,
                    imageHeight: 100,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    text('ERP',
                        isCentered: true,
                        fontSize: GlobalVariables.textSizeNormal,
                        textColor: GlobalVariables.primaryColor,
                        fontWeight: FontWeight.bold),
                    SizedBox(
                      height: 16,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: text(
                                        GlobalFunctions.getCurrencyFormat(
                                            value.receiptAmount??'0'),
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeNormal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  text(value.receiptCount + ' Receipt',
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeMedium)
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(),
                          Flexible(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: text(
                                        GlobalFunctions.getCurrencyFormat(
                                            value.expenseAmount??'0'),
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeNormal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  text(value.expenseCount + ' Voucher',
                                      textColor: GlobalVariables.black,
                                      fontSize: GlobalVariables.textSizeMedium)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if(AppUserPermission.isUserAccountingPermission) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseUnitDetails(isDuesUnit: true)));
                            }else{
                              GlobalFunctions
                                  .showAdminPermissionDialogToAccessFeature(
                                  context, true);
                            }
                          },
                          child: text('Add Receipt',
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                        InkWell(
                          onTap: () {
                            if(AppUserPermission.isUserAccountingPermission) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseUnitDetails(isAddExpense: true)));
                            }else{
                              GlobalFunctions
                                  .showAdminPermissionDialogToAccessFeature(
                                  context, true);
                            }
                          },
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('add_invoice'),
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /* getBarChartData(List<MonthExpenses> value) {
    _listBarChart = [
      BarChartModel(
        year: "Jan",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.green),
      ),
      BarChartModel(
        year: "Feb",
        financial: 250,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Mar",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Apr",
        financial: 100,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "May",
        financial: 450,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Jun",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.green),
      ),
      BarChartModel(
        year: "July",
        financial: 250,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Aug",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Sept",
        financial: 100,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Oct",
        financial: 450,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.mediumGreen),
      ),
      BarChartModel(
        year: "Nov",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.green),
      ),
      BarChartModel(
        year: "Dec",
        financial: 300,
        color: charts.ColorUtil.fromDartColor(GlobalVariables.green),
      ),
    ];
  }*/

  getPendingListItemLayout(var position, UserManagementResponse value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // SizedBox(height: 30,),
        Container(
          padding: EdgeInsets.all(5),
          color: GlobalVariables.AccentColor,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: text(
              value.adminPendingList[position].PAYMENT_DATE.length > 0
                  ? GlobalFunctions.convertDateFormat(
                      value.adminPendingList[position].PAYMENT_DATE,
                      'dd-MM-yyyy')
                  : "",
              textColor: GlobalVariables.grey,
              fontSize: GlobalVariables.textSizeSMedium,
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          value.adminPendingList[position].FLAT_NO,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium,
                         // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseViewReceipt(
                                      null,
                                      null,
                                      null,
                                      null,
                                      receipt: value.adminPendingList[position],
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          /*"Rs. " +
                              double.parse(value.adminPendingList[position].AMOUNT
                                      .toString())
                                  .toStringAsFixed(2)*/
                          GlobalFunctions.getCurrencyFormat(value
                              .adminPendingList[position].AMOUNT
                              .toString()),
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeSMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

class SliderCardName {
  int position;
  String name;

  SliderCardName(this.position, this.name);
}

/*class BarChartModel {
  String month;
  String year;
  int financial;
  charts.Color color;

  BarChartModel({
    this.month,
    this.year,
    this.financial,
    this.color,
  });
}*/

class BarChart extends StatelessWidget {
  final List<MonthExpenses> data;

  BarChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    //print('data : ' + data.toString());
    List<charts.Series<MonthExpenses, String>> series = [
      charts.Series(
        id: "Subscribers",
        data: data,
        // seriesColor : charts.ColorUtil.fromDartColor(GlobalVariables.black  ),
        domainFn: (MonthExpenses series, _) => series.month,
        measureFn: (MonthExpenses series, _) {
          //print('series.exp_amount : ' + series.exp_amount);
          return double.parse(series.exp_amount);
        },
        colorFn: (MonthExpenses series, _) =>
            charts.ColorUtil.fromDartColor(GlobalVariables.primaryColor),
        //areaColorFn: (BarChartModel series, _) =>  charts.ColorUtil.fromDartColor(GlobalVariables.black)
      )
    ];
    return Container(
      height: 250,

      //   color :  GlobalVariables.,
      // padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("Expenses",
                    textColor: GlobalVariables.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: GlobalVariables.textSizeMedium),
                InkWell(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseExpenseSearchAdd()))
                        .then((value) {
                      GlobalFunctions.setBaseContext(context);
                    });
                  },
                  child: smallTextContainerOutlineLayout(
                      AppLocalizations.of(context).translate('view_expenses')),
                )
              ],
            ),
          ),
          Expanded(
            child: charts.BarChart(series,
                animate: true,
                domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: new charts.SmallTickRendererSpec(
                        minimumPaddingBetweenLabelsPx: 1,
                        // Tick and Label styling here.
                        labelStyle: new charts.TextStyleSpec(
                            fontSize: 8, // size in Pts.
                            color: charts.MaterialPalette.black),

                        // Change the line colors to match text color.
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.black))),

            ),
          )
        ],
      ),
    );
  }
}
