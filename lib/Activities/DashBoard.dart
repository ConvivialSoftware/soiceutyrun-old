import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/Admin.dart';
import 'package:societyrun/Activities/AppSettings.dart';
import 'package:societyrun/Activities/Broadcast.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/Discover.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/Expense.dart';
import 'package:societyrun/Activities/ExpenseSearchAdd.dart';
import 'package:societyrun/Activities/FindServices.dart';
import 'package:societyrun/Activities/HelpDesk.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/More.dart';
import 'package:societyrun/Activities/MyComplex.dart';

import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/Activities/Notifications.dart';
import 'package:societyrun/Activities/OwnerDiscover.dart';
import 'package:societyrun/Activities/OwnerServices.dart';
import 'package:societyrun/Activities/Support.dart';
import 'package:societyrun/Activities/UserManagement.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Banners.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/SQLiteDatabase/SQLiteDbProvider.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppDropDown.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

import 'LoginPage.dart';
import 'WebViewScreen.dart';

class BaseDashBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // GlobalFunctions.showToast("DashBoard page");
    return DashBoardState();
  }
}

class DashBoardState extends BaseStatefulState<BaseDashBoard>
    with WidgetsBindingObserver, ChangeNotifier {
   final GlobalKey<ScaffoldState> dashboardScaffoldKey = new GlobalKey<ScaffoldState>();

  String selectedSocietyName;
  List<LoginResponse> mSocietyList = new List<LoginResponse>();

  // String _selectedItem;
  // List<DropdownMenuItem<String>> _societyListItems = new List<DropdownMenuItem<String>>();

  //List<LoginResponse> _societyList = new List<LoginResponse>();
  LoginResponse _selectedSocietyLogin;
  var username, password, societyId, flat, block;

  /*duesRs = "0.0", duesDate = ""*/

  List<RootTitle> _list = new List<RootTitle>();
  int _currentIndex = 0;
  int _moreIndex = 0;
  ProgressDialog _progressDialog;

  var name = '';
  var email = '', phone = '';
  var photo = '', consumerId, societyName;

  //List<Banners> _bannerList = List<Banners>();

  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 30,
    googlePlayIdentifier: AppPackageInfo.packageName,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GlobalFunctions.isAllowForRunApp().then((value) {
      if (value) {
        getSharedPreferenceData();
        SQLiteDbProvider.db.getDataBaseInstance();
        GlobalFunctions.getAppPackageInfo();
        GlobalFunctions.checkInternetConnection().then((internet) {
          if (internet) {
            getDuesData();
            getAllSocietyData();
            Provider.of<LoginDashBoardResponse>(context, listen: false)
                .getBannerData();
          } else {
            GlobalFunctions.showToast(AppLocalizations.of(context)
                .translate('pls_check_internet_connectivity'));
          }
        });
      } else {
        GlobalFunctions.notAllowForRunAppDialog(context);
      }
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      //GlobalFunctions.showToast('Resume');
      GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      SQLiteDbProvider.db.getDataBaseInstance();
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      // GlobalFunctions.showToast('Inactive');
      SQLiteDbProvider.db.getDataBaseInstance();
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      //GlobalFunctions.showToast('Paused');
      SQLiteDbProvider.db.getDataBaseInstance();
    } else if (state == AppLifecycleState.detached) {
      // user is about quit our app temporally
      // GlobalFunctions.showToast('Detached');
      SQLiteDbProvider.db.getDataBaseInstance();
    }
  }

  int _activeMeterIndex;

  @override
  Widget build(BuildContext context) {
    FirebaseMessagingHandler().getToken();
    print('DashBoard context : ' + context.toString());
    print('BaseStatefulState context : ' + BaseStatefulState.getCtx.toString());
    print(
        'DashBoard _dashboardSacfoldKey : ' + dashboardScaffoldKey.toString());

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getExpandableListViewData(context);

    // TODO: implement build
    //  GlobalFunctions.showToast("Dashboard state page");
    return ChangeNotifierProvider<LoginDashBoardResponse>.value(
      value: Provider.of<LoginDashBoardResponse>(context),
      child: Consumer<LoginDashBoardResponse>(
        builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              key: dashboardScaffoldKey,
              // appBar: CustomAppBar.ScafoldKey(AppLocalizations.of(context).translate('overview'),context,_dashboardSacfoldKey),
              body: WillPopScope(
                  child: getBodyLayout(value), onWillPop: onWillPop),
              drawer: getDrawerLayout(value),
              // bottomNavigationBar: getBottomNavigationBar(),
            ),
          );
        },
      ),
    );
  }

  getBodyLayout(LoginDashBoardResponse value) {
    return value.isLoading
        ? GlobalFunctions.loadingWidget(context)
        : Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: GlobalVariables.white,
                ),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SvgPicture.asset(
                                GlobalVariables.headerIconPath,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              )),
                        ),
                        Container(
                          // color: GlobalVariables.black,
                          margin: EdgeInsets.fromLTRB(
                              0, MediaQuery.of(context).size.height / 30, 0, 0),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                //  color: GlobalVariables.grey,
                                child: SizedBox(
                                    child: GestureDetector(
                                  onTap: () {
                                    dashboardScaffoldKey.currentState
                                        .openDrawer();
                                  },
                                  child: SvgPicture.asset(
                                    GlobalVariables.topBreadCrumPath,
                                  ),
                                )),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      MediaQuery.of(context).size.width / 70,
                                      0), // color: GlobalVariables.green,
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    /*child: SvgPicture.asset(
                              GlobalVariables.overviewTxtPath,
                            )*/
                                    child: text(
                                      'OVERVIEW',
                                      textColor: GlobalVariables.white,
                                      fontSize:
                                          GlobalVariables.textSizeLargeMedium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Container(
                                    //color: GlobalVariables.grey,
                                    margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
                                    child: SizedBox(
                                        child: GestureDetector(
                                      onTap: () {
                                        //GlobalFunctions.comingSoonDialog(context);
                                        //if(GlobalVariables.notificationCounterValueNotifer.value>0) {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BaseNotifications()))
                                            .then((value) {
                                          GlobalFunctions.setBaseContext(
                                              dashboardScaffoldKey
                                                  .currentContext);
                                        });
                                        //}
                                      },
                                      child: ValueListenableBuilder(
                                          valueListenable: GlobalVariables
                                              .notificationCounterValueNotifer,
                                          builder: (BuildContext context,
                                              int newNotificationCounterValue,
                                              Widget child) {
                                            return Stack(
                                              children: [
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  //color: GlobalVariables.grey,
                                                  child: AppAssetsImage(
                                                    GlobalVariables
                                                        .notificationBellIconPath,
                                                    imageWidth: GlobalVariables
                                                        .textSizeNormal,
                                                    imageHeight: GlobalVariables
                                                        .textSizeNormal,
                                                  ),
                                                ),
                                                newNotificationCounterValue > 0
                                                    ? Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        margin: EdgeInsets.only(
                                                            left: 8),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: GlobalVariables
                                                                  .orangeYellow,
                                                              border: Border.all(
                                                                  color: GlobalVariables
                                                                      .transparent,
                                                                  width: 1)),
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            // margin: EdgeInsets.only(bottom: 4),
                                                            child: text(
                                                                newNotificationCounterValue
                                                                    .toString(),
                                                                textColor:
                                                                    GlobalVariables
                                                                        .white,
                                                                fontSize:
                                                                    GlobalVariables
                                                                        .textSizeSmall),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            );
                                          }),
                                    )),
                                  ),
                                  Container(
                                    //  color: GlobalVariables.grey,
                                    margin: EdgeInsets.fromLTRB(
                                        0, 10, 20, 0), // alignment: Alignment
                                    child: SizedBox(
                                        child: ValueListenableBuilder(
                                            valueListenable: GlobalVariables
                                                .userImageURLValueNotifer,
                                            builder: (BuildContext context,
                                                String userImageURLValueNotifer,
                                                Widget child) {
                                              return GestureDetector(
                                                  onTap: () {
                                                    // GlobalFunctions.showToast('profile_user');
                                                    navigateToProfilePage();
                                                  },
                                                  child:
                                                      userImageURLValueNotifer
                                                              .isEmpty
                                                          ? AppAssetsImage(
                                                              GlobalVariables
                                                                  .componentUserProfilePath,
                                                              imageWidth: 20.0,
                                                              imageHeight: 20.0,
                                                              borderColor:
                                                                  GlobalVariables
                                                                      .grey,
                                                              borderWidth: 1.0,
                                                              fit: BoxFit.cover,
                                                              radius: 10.0,
                                                            )
                                                          : AppNetworkImage(
                                                              userImageURLValueNotifer,
                                                              imageWidth: 20.0,
                                                              imageHeight: 20.0,
                                                              borderColor:
                                                                  GlobalVariables
                                                                      .grey,
                                                              borderWidth: 1.0,
                                                              fit: BoxFit.cover,
                                                              radius: 10.0,
                                                            ));
                                            })),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        duesLayout(value)
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    getHomePage(value)
                  ],
                ),
              ),
            ],
          );
  }

  /* getBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          0, 10, 0, 0), //margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
      //height: 70,
      // color: GlobalVariables.green,
      decoration: BoxDecoration(
          color: GlobalVariables.green,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0))),
      child: BottomNavigationBar(
          backgroundColor: GlobalVariables.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            _currentIndex = index;
            _moreIndex = 0;
            navigateToPage();
          },
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomHomeIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomHomeIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomMyHomeIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomMyHomeIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomBuildingIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomBuildingIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomServiceIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomServiceIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomClubIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomClubIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  GlobalVariables.bottomMenuIconPath,
                  color: GlobalVariables.white30,
                  width: 20,
                  height: 20,
                ),
                activeIcon: SvgPicture.asset(
                  GlobalVariables.bottomMenuIconPath,
                  color: GlobalVariables.white,
                ),
                title: Text("")),
          ]),
    );
  }*/

  /*bool isHomePage() {
    if (_currentIndex == 0) {
      return true;
    }
    return false;
  }*/

  /* navigateToPage() {
    switch (_currentIndex) {
      case 0:
        {
          //Home
          setState(() {});
        }
        break;
      case 1:
        {
          //MyUnit
          getMyUnitPage();
        }
        break;
      case 2:
        {
          //MyComplex
          getMyComplexPage();
        }
        break;
      case 3:
        {
          //Discover
          getDiscoverPage();
        }
        break;
      case 4:
        {
          //ClubFacilities
          getClubFacilitiesPage();
        }
        break;
      case 5:
        {
          //More
          if (_moreIndex == 4) {
            getMyGatePage();
          } else if (_moreIndex == 5) {
            getHelpDeskPage();
          } else if (_moreIndex == 6) {
            getAdminPage();
          } else {
            getMorePage();
          }
        }
        break;
      default:
        {
          getHomePage();
        }
        break;
    }
  }*/

  getHomePage(LoginDashBoardResponse loginDashBoardResponse) {
    return Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                //color: GlobalVariables.grey,
                margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          //getMyUnitPage();
                          redirectToPage(
                              AppLocalizations.of(context).translate('my_unit'),
                              context);
                        },
                        child: Container(
                          //    color: GlobalVariables.black,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                  GlobalVariables.shopIconPath,
                                ),
                              ),
                              Container(
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('my_unit'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          // getMyComplexPage();
                          redirectToPage(
                              AppLocalizations.of(context)
                                  .translate('my_complex'),
                              context);
                        },
                        child: Container(
                          //  color: GlobalVariables.green,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.buildingIconPath),
                              ),
                              Container(
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('my_complex'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          // getHelpDeskPage();
                          if (!AppSocietyPermission.isSocHideHelpDeskPermission)
                            redirectToPage(
                                AppLocalizations.of(context)
                                    .translate('help_desk'),
                                context);
                          else
                            GlobalFunctions
                                .showAdminPermissionDialogToAccessFeature(
                                    context, true);
                        },
                        child: Container(
                          //    color: GlobalVariables.black,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.supportIconPath),
                              ),
                              Container(
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('help_desk'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                //color: GlobalVariables.grey,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          // getClubFacilitiesPage();
                          if (!AppSocietyPermission
                              .isSocHideClassifiedPermission) {
                            redirectToPage(
                                AppLocalizations.of(context)
                                    .translate('classified'),
                                context);
                          } else {
                            GlobalFunctions
                                .showAdminPermissionDialogToAccessFeature(
                                    context, true);
                          }
                        },
                        child: Container(
                          //    color: GlobalVariables.black,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.shoppingIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('classified'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          // getMyGatePage();
                          if (!AppSocietyPermission.isSocHideGatePassPermission)
                            redirectToPage(
                                AppLocalizations.of(context)
                                    .translate('my_gate'),
                                context);
                          else
                            GlobalFunctions
                                .showAdminPermissionDialogToAccessFeature(
                                    context, true);
                        },
                        child: Container(
                          //    color: GlobalVariables.green,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.gatePassIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('my_gate'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          /*getMorePage();*/
                          redirectToPage(
                              AppLocalizations.of(context).translate('more'),
                              context);
                        },
                        child: Container(
                          //color: GlobalVariables.black,
                          width: 100,
                          height: 80,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: AppAssetsImage(
                                    GlobalVariables.moreIconPath),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('more'),
                                      fontSize:
                                          GlobalVariables.textSizeSMedium)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                            //GlobalFunctions.comingSoonDialog(context);
                            if (!AppSocietyPermission
                                .isSocHideOffersPermission) {
                              redirectToPage(
                                  AppLocalizations.of(context)
                                      .translate('exclusive_offer'),
                                  context);
                            } else {
                              GlobalFunctions
                                  .showAdminPermissionDialogToAccessFeature(
                                      context, true);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            decoration: BoxDecoration(
                                color: GlobalVariables.AccentColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SvgPicture.asset(
                                  GlobalVariables.storeIconPath,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                text(
                                    AppLocalizations.of(context)
                                        .translate('exclusive_offer'),
                                    fontSize: GlobalVariables.textSizeSMedium)
                              ],
                            ),
                          ),
                        )),
                    Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            // GlobalFunctions.comingSoonDialog(context);
                            if (!AppSocietyPermission
                                .isSocHideServicesPermission) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseFindServices())).then((value) {
                                GlobalFunctions.setBaseContext(
                                    dashboardScaffoldKey.currentContext);
                              });
                            } else {
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SvgPicture.asset(
                                  GlobalVariables.serviceIconPath,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                text(
                                    AppLocalizations.of(context)
                                        .translate('find_services'),
                                    fontSize: GlobalVariables.textSizeSMedium),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              Container(
                //color: GlobalVariables.grey,
                decoration: boxDecoration(
                  radius: GlobalVariables.textSizeVerySmall,
                ),
                margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                    viewportFraction: 1.0,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                  ),
                  itemCount: loginDashBoardResponse.bannerList.length,
                  itemBuilder: (BuildContext context, int itemIndex,
                          int item) =>
                      loginDashBoardResponse.bannerList.length > 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BaseWebViewScreen(
                                            loginDashBoardResponse
                                                    .bannerList[itemIndex].Url +
                                                '?' +
                                                'SID=' +
                                                societyId.toString() +
                                                '&MOBILE=' +
                                                phone.toString() +
                                                '&NAME=' +
                                                name.toString() +
                                                '&UNIT=' +
                                                block.toString() +
                                                ' ' +
                                                flat.toString()))).then(
                                    (value) {
                                  GlobalFunctions.setBaseContext(
                                      dashboardScaffoldKey.currentContext);
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                //color: GlobalVariables.black,
                                //alignment: Alignment.center,
                                child: AppNetworkImage(
                                  loginDashBoardResponse
                                      .bannerList[itemIndex].IMAGE,
                                  fit: BoxFit.fitWidth,
                                  shape: BoxShape.rectangle,
                                  borderColor: GlobalVariables.transparent,
                                  radius: GlobalVariables.textSizeVerySmall,
                                ),
                              ),
                            )
                          : Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*getMyUnitPage() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseMyUnit(null)));
    print('result back : ' + result.toString());
    if (result == 'back') {
      getDuesData();
    }
  }*/

  /*getMyComplexPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseMyComplex(null)));
  }*/

  /*getDiscoverPage() {
    GlobalFunctions.comingSoonDialog(context);
    */ /*Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseDiscover(null)));*/ /*
  }*/

  /*getClubFacilitiesPage() {
    GlobalFunctions.comingSoonDialog(context);
    */ /* Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseFacilities()));*/ /*
  }*/

  /*getMyGatePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseMyGate(null)));
  }*/

  /*getMorePage() {
    GlobalFunctions.comingSoonDialog(context);
    */ /*Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseMyUnit(null)));*/ /*
  }*/

  /*getHelpDeskPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseHelpDesk(false))).then((value) {
          setState(() {
            print("context : "+context.toString());
            print("currentContext : "+_dashboardSacfoldKey.currentContext.toString());
            print("currentState : "+_dashboardSacfoldKey.currentState.toString());
            print("currentWidget : "+_dashboardSacfoldKey.currentWidget.toString());
            GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
            //showDialog(context: context,child: Container(color: GlobalVariables.green,width: 50,height: 50,));
          });
    });
  }*/

  /*getAdminPage() {
    GlobalFunctions.comingSoonDialog(context);
    */ /*Navigator.push(
        context, MaterialPageRoute(builder: (context) => BaseMyUnit(null)));*/ /*
  }*/

  getDrawerLayout(LoginDashBoardResponse value) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.80,
        child: Drawer(
          child: Column(
            children: <Widget>[
              /*Container(
                */ /*child: Image.asset(GlobalVariables.appLogoPath,
                  width: 250, height: 100, fit: BoxFit.fill),*/ /*
                margin: EdgeInsets.fromLTRB(10, 35, 5, 1),
                padding: EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                child: AppAssetsImage(
                  GlobalVariables.drawerImagePath,
                  imageHeight: 40.0,
                ),
              ),*/
              SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 30, 0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: GlobalVariables.primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: getHeaderLayout(value),
                ),
              ),
              getListData(),
            ],
          ),
        ),
      );
    });
  }

  getHeaderLayout(LoginDashBoardResponse loginDashBoardResponse) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getHeaderData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          print('header data snap map : ' + snapshot.data.toString());
          return Column(
            children: <Widget>[
              /*Container(
                //color:GlobalVariables.white,
                //  padding: EdgeInsets.all(5),
                margin: EdgeInsets.fromLTRB(5, 0, 5,
                    0), // width: MediaQuery.of(context).size.width / 2.2,
                //  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                */ /*    decoration: BoxDecoration(
                                  color: GlobalVariables.white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                            */ /*
                //TODO : Dropdown
                child:
                    */ /*AppDropDown<String>(
                  _societyListItems,
                  changeDropDownItem,
                  value: _selectedItem,
                  icon: Icons.keyboard_arrow_down,
                  iconColor: GlobalVariables.black,
                ),*/ /*
                    DropdownButton(
                  items: _societyListItems,
                  onChanged: (value) {
                    GlobalFunctions.checkInternetConnection().then((internet) {
                      if (internet) {
                        setState(() {
                          _selectedItem = value;
                          print('_selctedItem:' + _selectedItem.toString());
                          for (int i = 0;
                              i < loginDashBoardResponse.societyList.length;
                              i++) {
                            if (_selectedItem ==
                                loginDashBoardResponse.societyList[i].ID) {
                              _selectedSocietyLogin =
                                  loginDashBoardResponse.societyList[i];
                              _selectedSocietyLogin.PASSWORD = password;
                              GlobalFunctions.saveDataToSharedPreferences(
                                  _selectedSocietyLogin);
                              print('for _selctedItem:' + _selectedItem);
                              getDuesData();
                              getDisplayName();
                              getMobile();
                              getPhoto();
                              break;
                            }
                          }
                        });
                      } else {
                        GlobalFunctions.showToast(AppLocalizations.of(context)
                            .translate('pls_check_internet_connectivity'));
                      }
                    });
                  },
                  value: _selectedItem,
                  underline: SizedBox(),
                  isExpanded: false,
                  icon: AppIcon(
                    Icons.keyboard_arrow_down,
                    iconColor: GlobalVariables.black,
                  ),
                  //iconSize: 20,
                ),
              ),*/
              Container(
                //color: GlobalVariables.black,
                //margin: EdgeInsets.all(5),
                // padding: EdgeInsets.all(5),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        navigateToProfilePage();
                      },
                      child: Container(
                          // margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          //color: GlobalVariables.red,
                          //TODO: userImage
                          child: ValueListenableBuilder(
                              valueListenable:
                                  GlobalVariables.userImageURLValueNotifer,
                              builder: (BuildContext context,
                                  String userImageURLValueNotifer,
                                  Widget child) {
                                return userImageURLValueNotifer.isEmpty
                                    ? AppAssetsImage(
                                        GlobalVariables
                                            .componentUserProfilePath,
                                        imageWidth: 70.0,
                                        imageHeight: 70.0,
                                        borderColor: GlobalVariables.grey,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 30.0,
                                      )
                                    : AppNetworkImage(
                                        userImageURLValueNotifer,
                                        imageWidth: 70.0,
                                        imageHeight: 70.0,
                                        borderColor: GlobalVariables.grey,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 30.0,
                                      );
                              })),
                    ),
                    Flexible(
                      child: Container(
                        //alignment: AlignmentDirectional.center,
                        //color: GlobalVariables.red,
                        //  padding: EdgeInsets.all(5),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Column(
                          //mainAxisSize: MainAxisSize.max,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              //color: GlobalVariables.green,
                              //TODO : UserName
                              child: ValueListenableBuilder(
                                  valueListenable:
                                      GlobalVariables.userNameValueNotifer,
                                  builder: (BuildContext context,
                                      String userNameValueNotifer,
                                      Widget child) {
                                    print('Name : ' +
                                        userNameValueNotifer.toString());
                                    print('Name1 : ' + name.toString());
                                    return primaryText(
                                      'Hello,\n' +
                                          (userNameValueNotifer.isEmpty
                                              ? name
                                              : userNameValueNotifer),
                                      // maxLine: 1,
                                      //   textAlign: TextAlign.left,
                                      textColor: GlobalVariables.white,
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.topLeft,
                //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                // margin: EdgeInsets.all(5), //   color: GlobalVariables.green,
                //TODO : CustomerID
                child: secondaryText(
                  (AppLocalizations.of(context).translate("str_consumer_id") +
                      ' : ' +
                      snapshot.data[GlobalVariables.keyConsumerId]),
                  //textAlign: TextAlign.left,

                  textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeSmall,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: text(
                  block + ' ' + flat + ' ' + societyName,
                  textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeMedium,
                  textStyleHeight: 1.5,
                  maxLine: 1,
                ),
              ),
              /* Container(
                color: GlobalVariables.grey,
                alignment: Alignment.center,
                child: text(block+' '+flat+' '+societyName,textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeSMedium),
              )*/
            ],
          );
        } else {
          return Container(
              // child: CircularProgressIndicator(),
              );
        }
      },
    );

    /*
*/
  }

  getListData() {
    print('_list.lenght : ' + _list.length.toString());
    print('_list : ' + _list.toString());
    print('_list.title at 0 : ' + _list[0].title.toString());

    return Flexible(
      child: Container(
        //color: GlobalVariables.black,
        child: Theme(
          data: ThemeData(accentColor: GlobalVariables.primaryColor),
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (BuildContext context, int index) =>
                EntryItem(_list[index], index, context),
          ),
        ),
        /*ListView.builder(
            shrinkWrap: true,
            itemCount: _list.length,
            itemBuilder: (context, i) {
              return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: GlobalVariables.transparent),
                  child: Material(
                    elevation: 0,
                    child: ExpansionPanelList(
                      expansionCallback: (int index, bool status) {
                        setState(() {
                          _activeMeterIndex = _activeMeterIndex == i ? null : i;
                        });
                      },
                      dividerColor: GlobalVariables.transparent,
                      children: [
                        ExpansionPanel(
                            isExpanded: _list[i].items.length == 0
                                ? false
                                : _activeMeterIndex == i,
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ExpansionTile(
                                key: PageStorageKey<String>(_list[i].title),
                                onExpansionChanged: ((newState) {
                                  print('root click : ' + _list[i].title);
                                  //GlobalFunctions.showToast(_list[i].title);
                                  if (_list[i].items.length == 0)
                                    redirectToPage(_list[i].title);
                                  else
                                    setState(() {
                                      _activeMeterIndex =
                                          _activeMeterIndex == i ? null : i;
                                    });
                                  //Navigator.of(context).pop();
                                }),
                                title: Container(
                                  // color: GlobalVariables.green,
                                  //transform: Matrix4.translationValues(0, 0, -10.0),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                          child: SvgPicture.asset(
                                        _list[i].rootIconData,
                                        color: GlobalVariables.grey,
                                        width: 25,
                                        height: 25,
                                      )),
                                      Flexible(
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(20, 0, 0, 0),
                                          child: text(
                                            _list[i].title,
                                                textColor: GlobalVariables.grey,
                                                fontSize: GlobalVariables.textSizeSMedium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Icon(null),
                              );
                            },
                            body: _list[i].items.length > 0
                                ? Container(
                                    child: Column(
                                      children: <Widget>[
                                        for (String item in _list[i].items)
                                          InkWell(
                                            onTap: () {
                                              //GlobalFunctions.showToast(item);
                                              redirectToPage(item);
                                            },
                                            child: Container(
                                              // color: GlobalVariables.grey,
                                              margin: EdgeInsets.fromLTRB(
                                                  55, 0, 0, 0),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, 8, 0, 8),
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                        color: GlobalVariables
                                                            .green,
                                                        shape: BoxShape.circle),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        20, 8, 0, 8),
                                                    child: text(
                                                      item,
                                                      fontSize: GlobalVariables.textSizeMedium,
                                                          textColor: GlobalVariables
                                                              .grey
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Container())
                      ],
                    ),
                  ));
            }),*/
      ),
    );
  }

  Future<Map<String, dynamic>> getHeaderData() async {
    //Future.delayed(Duration(seconds: 2),() async {
    var headerList = <String, dynamic>{
      GlobalVariables.keyName: await GlobalFunctions.getDisplayName(),
      GlobalVariables.keyConsumerId: await GlobalFunctions.getConsumerID(),
    };
    print('header data map : ' + headerList.toString());
    return headerList;
    // });
  }

  Future<void> getAllSocietyData() async {
    String loggedUsername = await GlobalFunctions.getLoggedUserName();
    if (loggedUsername.length == 0) {
      GlobalFunctions.notAllowForRunAppDialog(context);
    } else {
      Provider.of<LoginDashBoardResponse>(context, listen: false)
          .getAllSocietyData(loggedUsername, context)
          .then((_societyList) async {
        getSocietyData();
        _rateMyApp.init().then((_) {
          //if(_rateMyApp.shouldOpenDialog){ //conditions check if user already rated the app
          if (mounted && _rateMyApp.shouldOpenDialog) {
            _rateMyApp.showRateDialog(
              context,
              title: 'Rate this app',
              // The dialog title.
              message:
                  'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
              // The dialog message.
              rateButton: 'RATE',
              // The dialog "rate" button text.
              noButton: 'NO THANKS',
              // The dialog "no" button text.
              laterButton: 'MAYBE LATER',
              // The dialog "later" button text.
              listener: (button) {
                // The button click listener (useful if you want to cancel the click event).
                switch (button) {
                  case RateMyAppDialogButton.rate:
                    print('Clicked on "Rate".');
                    break;
                  case RateMyAppDialogButton.later:
                    print('Clicked on "Later".');
                    break;
                  case RateMyAppDialogButton.no:
                    print('Clicked on "No".');
                    break;
                }

                return true; // Return false if you want to cancel the click event.
              },
              ignoreNativeDialog: Platform.isAndroid,
              // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
              dialogStyle: DialogStyle(),
              // Custom dialog styles.
              onDismissed: () => _rateMyApp.callEvent(RateMyAppEventType
                  .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
              // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
              // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
            );
          }
        });
      });
    }
  }

  void changeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
  }

  void getExpandableListViewData(BuildContext context) {
    //   print('AppLocalizations.of(context).translate(my_flat) : '+AppLocalizations.of(context).translate('my_unit').toString());
    getAppPermission();
    _list = [
      new RootTitle(
          title: AppLocalizations.of(context).translate('my_unit'),
          rootIconData: GlobalVariables.myFlatIconPath,
          //innerIconData: Icons.,
          items: [
            RootTitle(
              title: AppLocalizations.of(context).translate("my_dues"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("my_household"),
            )
            // AppLocalizations.of(context).translate("my_documents"),
          ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('my_complex'),
          rootIconData: GlobalVariables.myBuildingIconPath,
          //innerIconData: GlobalVariables.myFlatIconPath,
          items: [
            RootTitle(
              title: AppLocalizations.of(context).translate("announcement"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("meetings"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("poll_survey"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("documents"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("directory"),
            ),
            RootTitle(
              title: AppLocalizations.of(context).translate("events"),
            ),
          ]),
      if (!AppSocietyPermission.isSocHideClassifiedPermission ||
          !AppSocietyPermission.isSocHideServicesPermission ||
          !AppSocietyPermission.isSocHideOffersPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('discover'),
            rootIconData: GlobalVariables.myServiceIconPath,
            //innerIconData: GlobalVariables.myFlatIconPath,
            items: [
              if (!AppSocietyPermission.isSocHideClassifiedPermission)
                RootTitle(
                  title: AppLocalizations.of(context).translate("classified"),
                ),
              if (!AppSocietyPermission.isSocHideServicesPermission)
                RootTitle(
                  title: AppLocalizations.of(context).translate("services"),
                ),
              if (!AppSocietyPermission.isSocHideOffersPermission)
                RootTitle(
                  title:
                      AppLocalizations.of(context).translate("exclusive_offer"),
                ),
            ]),
      /* new RootTitle(
          title: AppLocalizations.of(context).translate('facilities'),
          rootIconData: GlobalVariables.myClubIconPath,
          //innerIconData: GlobalVariables.myFlatIconPath,
          items: []),*/
      if (!AppSocietyPermission.isSocHideGatePassPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('my_gate'),
            rootIconData: GlobalVariables.myGateIconPath,
            //innerIconData: GlobalVariables.myFlatIconPath,
            items: [
              RootTitle(
                  title:
                      AppLocalizations.of(context).translate("my_activities")),
              RootTitle(
                  title: AppLocalizations.of(context).translate("helpers")),
            ]),
      if (!AppSocietyPermission.isSocHideHelpDeskPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('help_desk'),
            rootIconData: GlobalVariables.mySupportIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: []),
      if (!AppSocietyPermission.isSocHideExpensePermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('expense'),
            rootIconData: GlobalVariables.expenseIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: []),
    /*  else if (AppUserPermission.isUserAccountingPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('expense'),
            rootIconData: GlobalVariables.expenseIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: []),*/
      if (AppUserPermission.isUserAdminPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('admin'),
            rootIconData: GlobalVariables.myAdminIconPath,
            //  innerIconData: GlobalVariables.myFlatIconPath,
            items: [
              /*if (!AppSocietyPermission.isSocHideHelpDeskPermission)
              RootTitle(
                title:
                    AppLocalizations.of(context).translate("assign_helpdesk"),
              ),
              if (AppUserPermission.isUserBroadcastPermission)
                RootTitle(
                  title: AppLocalizations.of(context).translate("broadcast"),
                ),
              if (AppUserPermission.isUserUserManagementPermission)
                RootTitle(
                  title:
                      AppLocalizations.of(context).translate("user_management"),
                ),*/
            ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('settings'),
          rootIconData: GlobalVariables.settingsIconPath,
          //  innerIconData: GlobalVariables.myFlatIconPath,
          items: []),
      new RootTitle(
          title: AppLocalizations.of(context).translate('switch_society'),
          rootIconData: GlobalVariables.switchIconPath,
          //  innerIconData: GlobalVariables.myFlatIconPath,
          items: []),
    ];
  }

  /*getDrawerItemIndex(int index) {
    switch (index) {
      case 0:
        {
          //myUnit
          _currentIndex = 1;
          _moreIndex = 0;
        }
        break;
      case 1:
        {
          //MyComplex
          _currentIndex = 2;
          _moreIndex = 1;
        }
        break;
      case 2:
        {
          //Discover
          _currentIndex = 3;
          _moreIndex = 2;
        }
        break;
      case 3:
        {
          //Club Facilities
          _currentIndex = 4;
          _moreIndex = 3;
        }
        break;
      case 4:
        {
          //myGate
          _currentIndex = 5;
          _moreIndex = 4;
        }
        break;
      case 5:
        {
          //helpDesk
          _currentIndex = 5;
          _moreIndex = 5;
        }
        break;
      case 6:
        {
          //admin
          _currentIndex = 5;
          _moreIndex = 6;
        }
        break;
    }
    */ /*setState(() {

    });*/ /*
    navigateToPage();
  }*/

  getDuesData() async {
    Provider.of<LoginDashBoardResponse>(context, listen: false)
        .getDuesData()
        .then((value) {
      if (dashboardScaffoldKey.currentState != null) {
        if (dashboardScaffoldKey.currentState.isDrawerOpen) {
          Navigator.of(context).pop();
        }
      }
      if (this.mounted) {
        setState(() {
          //Your state change code goes here
        });
      }
    });
  }

  duesLayout(LoginDashBoardResponse loginDashBoardResponse) {
    print('duesDate : ' + loginDashBoardResponse.duesDate.toString());
    print('duesRS : ' + loginDashBoardResponse.duesRs.toString());
    return Align(
      alignment: Alignment.center,
      child: Container(
        //color: GlobalVariables.black,
        // width: MediaQuery.of(context).size.width / 0.8,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 8, 0, 0),
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          elevation: 20.0,
          shadowColor: GlobalVariables.primaryColor.withOpacity(0.3),
          margin: EdgeInsets.all(16),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppAssetsImage(
                    GlobalVariables.whileBGPath,
                    imageHeight: 50,
                  ),
                ),
              ),
              GlobalVariables.isERPAccount
                  ? Container(
                      margin: EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              text(
                                AppLocalizations.of(context)
                                    .translate('total_due'),
                                textColor: GlobalVariables.primaryColor,
                                fontSize: GlobalVariables.textSizeSMedium,
                              ),
                              !AppUserPermission.isUserHideMyDuesPermission
                                  ? double.parse(
                                              loginDashBoardResponse.duesRs) >
                                          0
                                      ? text(
                                          getBillPaymentStatus(
                                              loginDashBoardResponse),
                                          textColor: getBillPaymentStatusColor(
                                              loginDashBoardResponse),
                                          fontSize:
                                              GlobalVariables.textSizeSMedium,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : text(
                                          'Paid',
                                          textColor: GlobalVariables.primaryColor,
                                          fontSize:
                                              GlobalVariables.textSizeSMedium,
                                          fontWeight: FontWeight.bold,
                                        )
                                  : SizedBox(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              text(
                                !AppUserPermission.isUserHideMyDuesPermission
                                    ? GlobalFunctions.getCurrencyFormat(
                                        loginDashBoardResponse.duesRs)
                                    /*double.parse(
                                                loginDashBoardResponse.duesRs)
                                            .toStringAsFixed(2)*/
                                    : GlobalFunctions.getCurrencyFormat("0"),
                                textColor: GlobalVariables.primaryColor,
                                fontSize: GlobalVariables.textSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                              Visibility(
                                visible: double.parse(
                                            loginDashBoardResponse.duesRs) >
                                        0
                                    ? true
                                    : false,
                                child: text(
                                  !AppUserPermission.isUserHideMyDuesPermission
                                      ? loginDashBoardResponse.duesDate.length >
                                                  0 &&
                                              loginDashBoardResponse.duesDate !=
                                                  '-'
                                          ? GlobalFunctions.convertDateFormat(
                                              loginDashBoardResponse.duesDate,
                                              'dd-MM-yyyy')
                                          : '-'
                                      : '',
                                  //textAlign: TextAlign.center,
                                  textColor: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                              //color: GlobalVariables.mediumGreen,
                              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: Divider()),
                          Container(
                            //margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    //GlobalFunctions.showToast('Transaction');
                                    !AppUserPermission
                                            .isUserHideMyDuesPermission
                                        ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BaseLedger(
                                                            block, flat)))
                                            .then((value) {
                                            GlobalFunctions.setBaseContext(
                                                dashboardScaffoldKey
                                                    .currentContext);
                                          })
                                        : GlobalFunctions
                                            .showAdminPermissionDialogToAccessFeature(
                                                context, true);
                                  },
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('transaction_history'),
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeMedium,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    //GlobalFunctions.showToast('Pay Now');
                                    !AppUserPermission
                                            .isUserHideMyDuesPermission
                                        ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BaseMyUnit(null)))
                                            .then((value) {
                                            GlobalFunctions.setBaseContext(
                                                dashboardScaffoldKey
                                                    .currentContext);
                                          })
                                        : GlobalFunctions
                                            .showAdminPermissionDialogToAccessFeature(
                                                context, true);
                                  },
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeMedium,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : getNoERPAccountLayout(),
            ],
          ),
        ),
      ),
    );
  }

  getNoERPAccountLayout() {
    return Container(
      padding: EdgeInsets.all(10),
      //margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      //   color: GlobalVariables.white,
      //width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              GlobalVariables.creditCardPath,
              width: 70,
              height: 70,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: text(
              AppLocalizations.of(context).translate('erp_acc_not'),
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeLargeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width / 2,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: ButtonTheme(
              //minWidth: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                color: GlobalVariables.primaryColor,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BaseAboutSocietyRunInfo()))
                      .then((value) {
                    GlobalFunctions.setBaseContext(
                        dashboardScaffoldKey.currentContext);
                  });
                },
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.primaryColor)),
                child: text(
                    AppLocalizations.of(context).translate('i_am_interested'),
                    fontSize: GlobalVariables.textSizeMedium,
                    textColor: GlobalVariables.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    //userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    GlobalVariables.userNameValueNotifer.value = name;
    GlobalVariables.userNameValueNotifer.notifyListeners();
    photo = await GlobalFunctions.getPhoto();
    GlobalVariables.userImageURLValueNotifer.value = photo;
    GlobalVariables.userImageURLValueNotifer.notifyListeners();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();

    // print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('societyName : ' + societyName);

    /* var keys = GlobalFunctions.sharedPreferences.getKeys();

    final prefsMap = Map<String, dynamic>();
    for(String key in keys) {
    prefsMap[key] = GlobalFunctions.sharedPreferences.get(key);
    }

    GlobalVariables.loggedUserInfoMap.value.addAll(prefsMap);

    print('User map : '+ GlobalVariables.loggedUserInfoMap.value[GlobalVariables.keyName].toString());
    //print('User map : '+ GlobalVariables.loggedUserInfoMap.value.toString());*/
    setState(() {});
  }

  Future<void> redirectToPage(String item, BuildContext context) async {
    if (item == AppLocalizations.of(context).translate('my_unit')) {
      //Redirect to my Unit
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyUnit(
                  AppLocalizations.of(context).translate('my_unit'))));
      print('result back : ' + result.toString());
      if (result == 'back') {
        getDuesData();
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      } else {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      }
    } else if (item == AppLocalizations.of(context).translate('my_dues')) {
      //Redirect to  My Dues
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_dues'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_household')) {
      //Redirect to  My Household
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_household'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_documents')) {
      //Redirect to  My Documents
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_documents'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_tenants')) {
      //Redirect to  My Tenants
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_tenants'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_complex')) {
      //Redirect to  My Complex
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('my_complex'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('announcement')) {
      //Redirect to News Board
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('announcement'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('meetings')) {
      //Redirect to News Board
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('meetings'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('poll_survey')) {
      //Redirect to  Poll Survey
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('poll_survey'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('directory')) {
      //Redirect to  Directory
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('directory'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('documents')) {
      //Redirect to  Documents
      //GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('documents'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('events')) {
      //Redirect to  Events
      //  GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('events'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('discover')) {
      //Redirect to  Discover
      //GlobalFunctions.comingSoonDialog(context);
      GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
    } else if (item == AppLocalizations.of(context).translate('classified')) {
      //Redirect to  classified
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseDiscover(
                      AppLocalizations.of(context).translate('classified'))))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('services')) {
      //Redirect to  services
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseFindServices()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('exclusive_offer')) {
      //Redirect to  exclusive_offer
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseNearByShopPerCategory())).then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('facilities')) {
      //Redirect to Facilities
      GlobalFunctions.comingSoonDialog(context);
      /*  Navigator.push(
         context, MaterialPageRoute(builder: (context) => BaseFacilities()));*/
    } else if (item == AppLocalizations.of(context).translate('my_gate')) {
      //Redirect to  My Gate
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyGate(
                      AppLocalizations.of(context).translate('my_gate'), null)))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('my_activities')) {
      //Redirect to  My Dues
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('my_activities'),
                  null))).then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('helpers')) {
      //Redirect to  My Dues
      // GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseMyGate(
                  AppLocalizations.of(context).translate('helpers'), null)));
    } else if (item == AppLocalizations.of(context).translate('help_desk')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseHelpDesk(false)))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('expense')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseExpenseSearchAdd()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('admin')) {
      //Redirect to  Admin
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseAdmin()));
    } else if (item ==
        AppLocalizations.of(context).translate('assign_helpdesk')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseHelpDesk(true)))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('broadcast')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => BaseBroadcast()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('user_management')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseUserManagement()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('about_us')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAboutSocietyRunInfo())).then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('change_password')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseChangePassword()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('settings')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseAppSettings()))
          .then((value) {
        GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('switch_society')) {
      showSocietyDialog(context);
    } else if (item == AppLocalizations.of(context).translate('more')) {
      //Redirect to  Admin«
      //GlobalFunctions.comingSoonDialog(context);

      /*showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  //backgroundColor: GlobalVariables.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  //child: supportLayout(),
                );
              }));*/
     /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseSupport())).then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });*/

      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              BaseSupport()));


      /*Navigator.push(
          context, MaterialPageRoute(builder: (context) => BaseMore())).then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });*/
    } else if (item == AppLocalizations.of(context).translate('logout')) {
      // GlobalFunctions.showToast("Logout");
      showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: displayLogoutLayout(),
                );
              }));
    }
  }

  displayLogoutLayout() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('sure_logout'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        logout(context);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('no'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      GlobalFunctions.showToast(
          AppLocalizations.of(context).translate('leave_app'));
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> navigateToProfilePage() async {
    //String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String userType = await GlobalFunctions.getUserType();
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseDisplayProfileInfo(userId, userType)));
    if (result == 'profile') {
      GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
      Provider.of<LoginDashBoardResponse>(context, listen: false)
          .geProfileData()
          .then((value) {});
    } else {
      GlobalFunctions.setBaseContext(dashboardScaffoldKey.currentContext);
    }
  }

  String getBillPaymentStatus(LoginDashBoardResponse loginDashBoardResponse) {
    String status = '';

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(loginDashBoardResponse.duesDate);
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);
    print('days : ' + days.toString());

    if (days > 0) {
      status = "Overdue";
    } else if (days == 0) {
      status = "Due Today";
    } else if (days >= -2 && days < 0) {
      status = 'Due in ' + (days * (-1)).toString() + ' day';
    } else {
      status = 'Due Date';
    }
    return status;
  }

  getBillPaymentStatusColor(LoginDashBoardResponse loginDashBoardResponse) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(loginDashBoardResponse.duesDate);
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      return Color(0xFFc0392b);
    } else if (days == 0) {
      return Color(0xFFf39c12);
    } else if (days >= -2 && days < 0) {
      return Color(0xFFf39c12);
    } else {
      return GlobalVariables.secondaryColor;
    }
  }

  static Future<void> logout(BuildContext context) async {
    ProgressDialog _progressDialog;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String gcmId = await GlobalFunctions.getFCMToken();

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    _progressDialog.show();
    restClient.userLogout(societyId, userId, gcmId).then((value) {
      print('Response : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        GlobalFunctions.clearSharedPreferenceData();
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new BaseLoginPage()),
            (Route<dynamic> route) => false);
      }
      GlobalFunctions.showToast(value.message);
    }).catchError((Object obj) {
      if (_progressDialog.isShowing()) {
        _progressDialog.hide();
      }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  Future<void> getAppPermission() async {
    var societyPermission = await GlobalFunctions.getSocietyPermission();
    var userPermission = await GlobalFunctions.getUserPermission();

    List<String> _socPermissionList = societyPermission.toString().split(',');
    List<String> _userPermissionList = userPermission.toString().split(',');

    for (int i = 0; i < _socPermissionList.length; i++) {
      // print('_socPermissionList[i] : ' + _userPermissionList[i].toString());
      /* if (_socPermissionList[i] == AppSocietyPermission.socHelpDeskPermission) {
        AppSocietyPermission.isSocHelpDeskPermission = true;
      }
      if (_socPermissionList[i] == AppSocietyPermission.socExpensePermission) {
        AppSocietyPermission.isSocExpensePermission = true;
      }
      if (_socPermissionList[i] == AppSocietyPermission.socGatePassPermission) {
        AppSocietyPermission.isSocGatePassPermission = true;
      }*/
      if (_socPermissionList[i] ==
          AppSocietyPermission.socAddVehiclePermission) {
        AppSocietyPermission.isSocAddVehiclePermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socPayAmountEditPermission) {
        AppSocietyPermission.isSocPayAmountEditPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socPayAmountNoLessPermission) {
        AppSocietyPermission.isSocPayAmountNoLessPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideTenantPermission) {
        AppSocietyPermission.isSocHideTenantPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideHelperPermission) {
        AppSocietyPermission.isSocHideHelperPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideVehiclePermission) {
        AppSocietyPermission.isSocHideVehiclePermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideGatePassPermission) {
        AppSocietyPermission.isSocHideGatePassPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideHelpDeskPermission) {
        AppSocietyPermission.isSocHideHelpDeskPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideClassifiedPermission) {
        AppSocietyPermission.isSocHideClassifiedPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideOffersPermission) {
        AppSocietyPermission.isSocHideOffersPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideServicesPermission) {
        AppSocietyPermission.isSocHideServicesPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideAlreadyPaidPermission) {
        AppSocietyPermission.isSocHideAlreadyPaidPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideContactPermission) {
        AppSocietyPermission.isSocHideContactPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideCommitteeContactPaidPermission) {
        AppSocietyPermission.isSocHideCommitteeContactPaidPermission = true;
      }
      if (_socPermissionList[i] ==
          AppSocietyPermission.socHideExpensePermission) {
        AppSocietyPermission.isSocHideExpensePermission = true;
      }
    }

    for (int i = 0; i < _userPermissionList.length; i++) {
      // print('_userPermissionList[i] : ' + _userPermissionList[i].toString());
      if (_userPermissionList[i] == AppUserPermission.userHelpDeskPermission) {
        AppUserPermission.isUserHelpDeskPermission = true;
      }
      if (_userPermissionList[i] == AppUserPermission.userAdminPermission) {
        AppUserPermission.isUserAdminPermission = true;
      }
      if (_userPermissionList[i] ==
          AppUserPermission.addUserAccountingPermission) {
        AppUserPermission.isUserAccountingPermission = true;
      }
      if (_userPermissionList[i] ==
          AppUserPermission.userAddExpensePermission) {
        AppUserPermission.isUserAddExpensePermission = true;
      }
      if (_userPermissionList[i] == AppUserPermission.userAddMemberPermission) {
        AppUserPermission.isUserAddMemberPermission = true;
      }
      if (_userPermissionList[i] ==
          AppUserPermission.userHideMyDuesPermission) {
        AppUserPermission.isUserHideMyDuesPermission = true;
      }
      if (_userPermissionList[i] == AppUserPermission.userBroadcastPermission) {
        AppUserPermission.isUserBroadcastPermission = true;
      }
      if (_userPermissionList[i] ==
          AppUserPermission.userUserManagementPermission) {
        AppUserPermission.isUserUserManagementPermission = true;
      }
      /*if (_userPermissionList[i] ==
          AppUserPermission.userAssignHelpdeskPermission) {
        AppUserPermission.isUserAssignHelpdeskPermission = true;
      }
      if (_userPermissionList[i] ==
          AppUserPermission.userAdminHelpDeskPermission) {
        AppUserPermission.isUserAdminHelpDeskPermission = true;
      }*/
    }
  }

  Future<void> showSocietyDialog(BuildContext context) async {
    getSocietyData();
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: AppContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context)
                                .translate('switch_society'),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ListView.builder(
                          itemCount: mSocietyList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, position) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  print('mSocietyList : ' +
                                      mSocietyList.toString());
                                  //print('mSocietyList : '+mSocietyList.toString());
                                  mSocietyList.forEach((element) {
                                    print('societyName : ' +
                                        element.Society_Name);
                                    print('society selected : ' +
                                        element.isSelected.toString());
                                    if (element.isSelected) {
                                      element.isSelected = false;
                                    } else {
                                      //print('societyName : '+element.Society_Name);
                                      element.isSelected = true;
                                      _selectedSocietyLogin = element;
                                    }
                                  });
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: mSocietyList[position]
                                                            .isSelected ==
                                                        true
                                                    ? GlobalVariables.primaryColor
                                                    : GlobalVariables
                                                        .transparent,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: mSocietyList[position]
                                                              .isSelected ==
                                                          true
                                                      ? GlobalVariables.primaryColor
                                                      : GlobalVariables
                                                          .secondaryColor,
                                                  width: 2.0,
                                                )),
                                            child: AppIcon(
                                              Icons.check,
                                              iconColor: mSocietyList[position]
                                                          .isSelected ==
                                                      true
                                                  ? GlobalVariables.white
                                                  : GlobalVariables.transparent,
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 0, 0, 0),
                                              child: text(
                                                mSocietyList[position]
                                                            .Society_Name ==
                                                        null
                                                    ? ''
                                                    : mSocietyList[position]
                                                        .Society_Name,
                                                textColor:
                                                    GlobalVariables.primaryColor,
                                                fontSize: GlobalVariables
                                                    .textSizeSMedium,
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
                          }),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        child: AppButton(
                            textContent:
                                AppLocalizations.of(context).translate('done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // setState(() {
                              GlobalFunctions.saveDataToSharedPreferences(
                                  _selectedSocietyLogin);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BaseDashBoard()),
                                  (Route<dynamic> route) => false);
                              // print('for _selctedItem:' + _selectedItem);
                              /* getDuesData();
                            getSharedPreferenceData();*/

                              //});
                            }),
                      ),
                    ],
                  ),
                ),

                /*  child: DropdownButton(
                    items: _societyListItems,
                    onChanged: (value) {
                      GlobalFunctions.checkInternetConnection().then((internet) {
                        if (internet) {
                          setState(() {
                            _selectedItem = value;
                            print('_selctedItem:' + _selectedItem.toString());
                            for (int i = 0; i < LoginDashBoardResponse.societyList.length;
                            i++) {
                              if (_selectedItem ==
                                  LoginDashBoardResponse.societyList[i].ID) {
                                _selectedSocietyLogin =
                                LoginDashBoardResponse.societyList[i];
                                _selectedSocietyLogin.PASSWORD = password;
                                GlobalFunctions.saveDataToSharedPreferences(
                                    _selectedSocietyLogin);
                                print('for _selctedItem:' + _selectedItem);
                                getDuesData();
                                getSharedPreferenceData();
                                break;
                              }
                            }
                          });
                        } else {
                          GlobalFunctions.showToast(AppLocalizations.of(context)
                              .translate('pls_check_internet_connectivity'));
                        }
                      });
                    },
                    value: _selectedItem,
                    underline: SizedBox(),
                    isExpanded: false,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.black,
                    ),
                    //iconSize: 20,
                  ),*/
              );
            }));
  }

  Future<void> getSocietyData() async {
    mSocietyList = new List<LoginResponse>();
    password = await GlobalFunctions.getPassword();
    societyId = await GlobalFunctions.getSocietyId();
    String loginId = await GlobalFunctions.getLoginId();
    // int prefPos = 0;

    String loggedUsername = await GlobalFunctions.getLoggedUserName();

    print('Societylist length ' +
        LoginDashBoardResponse.societyList.length.toString());
    for (int i = 0; i < LoginDashBoardResponse.societyList.length; i++) {
      LoginDashBoardResponse.societyList[i].LoggedUsername = loggedUsername;
      LoginResponse loginResponse = LoginDashBoardResponse.societyList[i];
      loginResponse.isSelected = false;

      print('"loginResponse.ID : ' + loginResponse.ID);
      print('ShardPref societyId : ' + societyId);
      print('SocietyId ' + loginResponse.SOCIETY_ID);
      print('PASSWORD ' + loginResponse.PASSWORD);

      print('SocietyId ' +
          loginResponse.Society_Name +
          " " +
          loginResponse.BLOCK +
          " " +
          loginResponse.FLAT);

      print('User Status : ' + loginResponse.User_Status);
      //loginResponse.User_Status='C';
      print('User Status : ' + loginResponse.User_Status);
      if (loginResponse.User_Status != 'C') {
        if (loginId == loginResponse.ID) {
          if (mSocietyList.length > 0) {
            //prefPos = i;

            mSocietyList.insert(0, loginResponse);
            /*_societyListItems.insert(
                0,
                DropdownMenuItem(
                  value: loginResponse.ID,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topLeft,
                    child: text(
                      loginResponse.Society_Name +
                          " " +
                          loginResponse.BLOCK +
                          " " +
                          loginResponse.FLAT,
                      textColor: GlobalVariables.black,
                      fontSize: GlobalVariables.textSizeSmall,
                      maxLine: 1,
                    ),
                  ),
                ));*/
          } else {
            mSocietyList.add(loginResponse);
            /* _societyListItems.add(DropdownMenuItem(
              value: loginResponse.ID,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                child: text(
                  loginResponse.Society_Name +
                      " " +
                      loginResponse.BLOCK +
                      " " +
                      loginResponse.FLAT,
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeSmall,
                  maxLine: 1,
                ),
              ),
            ));*/
          }
        } else {
          mSocietyList.add(loginResponse);
          /* _societyListItems.add(DropdownMenuItem(
            value: loginResponse.ID,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              child: text(
                loginResponse.Society_Name +
                    " " +
                    loginResponse.BLOCK +
                    " " +
                    loginResponse.FLAT,
                textColor: GlobalVariables.black,
                fontSize: GlobalVariables.textSizeSmall,
                maxLine: 1,
              ),
            ),
          ));*/
        }
      }
    }

    print('size : ' + mSocietyList.length.toString());
    if (mSocietyList.length > 0) {
      print('_societyListItems 0 : ' + mSocietyList[0].toString());
      selectedSocietyName = mSocietyList[0].Society_Name;
      print('_selectedItem initial : ' + selectedSocietyName.toString());
      _selectedSocietyLogin = mSocietyList[0];
      // if(_selectedSocietyLogin.User_Status!='C') {
      _selectedSocietyLogin.PASSWORD = password;
      _selectedSocietyLogin.LoggedUsername = loggedUsername;
      _selectedSocietyLogin.isSelected = true;
      print("Flat" + _selectedSocietyLogin.FLAT.toString());
      GlobalFunctions.saveDataToSharedPreferences(_selectedSocietyLogin);
    } else {
      //show logout Dialog
      GlobalFunctions.forceLogoutDialog(context);
    }
    print('mSocietyList : '+mSocietyList.toString());
    print('mSocietyList : '+mSocietyList.length.toString());
  }
}

class RootTitle {
  String title;
  String rootIconData;

  //IconData innerIconData;
  List<RootTitle> items;

  RootTitle(
      {this.title,
      this.rootIconData,
      /* this.innerIconData, */ this.items = const <RootTitle>[]});
}

class EntryItem extends StatefulWidget {
  const EntryItem(this.entry, this.position, this.context);

  final context;
  final position;
  final RootTitle entry;

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  int _activeMeterIndex;

  Widget _buildTitle(RootTitle root) {
    return Container(
      // color: GlobalVariables.green,
      //transform: Matrix4.translationValues(0, 0, -10.0),
      child: Row(
        children: <Widget>[
          Container(
              width: 26,
              height: 26,
              //  color: GlobalVariables.veryLightGray,
              child: AppAssetsImage(
                root.rootIconData,
                imageColor: GlobalVariables.grey,
                imageWidth: 25,
                imageHeight: 25,
              )),
          Flexible(
            child: Container(
              alignment: Alignment.topLeft,
              // color: GlobalVariables.lightGray,
              margin: EdgeInsets.fromLTRB(20, 8, 0, 8),
              child: text(
                root.title,
                textColor: GlobalVariables.black,
                fontSize: GlobalVariables.textSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiles(RootTitle root) {
    if (root.items.isEmpty) {
      return ListTile(
        title: InkWell(
            onTap: () {
              DashBoardState().redirectToPage(root.title, context);
            },
            child: _buildTitle(root)),
      );
    }
    return ExpansionTile(
      key: PageStorageKey<RootTitle>(root),
      title: _buildTitle(root),
      children: root.items.map<Widget>(_buildChildrenTiles).toList(),
    );
  }

  /*ExpansionTile(
      onExpansionChanged: (value){
        setState(() {
          _activeMeterIndex = _activeMeterIndex == widget.position ? null : widget.position;
        });
      },
      key: PageStorageKey<RootTitle>(root),
      title: _buildTitle(root),
      children: root.items.map<Widget>(_buildChildrenTiles).toList(),
    );*/

  Widget _buildChildrenTiles(RootTitle root) {
    return InkWell(
      onTap: () {
        DashBoardState().redirectToPage(root.title, context);
      },
      child: Container(
        // color: GlobalVariables.grey,
        margin: EdgeInsets.fromLTRB(55, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: GlobalVariables.primaryColor, shape: BoxShape.circle),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 8, 0, 8),
              child: text(root.title,
                  fontSize: GlobalVariables.textSizeMedium,
                  textColor: GlobalVariables.grey),
            ),
          ],
        ),
        // title: text(root.title,fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black),
        //children: root.items.map<Widget>(_buildTiles).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }
}
