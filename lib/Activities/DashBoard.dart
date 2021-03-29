import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AppSettings.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/Discover.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/Expense.dart';
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
import 'package:societyrun/Widgets/AppDropDown.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/firebase_notification/firebase_message_handler.dart';
import 'package:intl/intl.dart';

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
  final GlobalKey<ScaffoldState> _dashboardSacfoldKey =
      new GlobalKey<ScaffoldState>();

  String _selectedItem;
  List<DropdownMenuItem<String>> _societyListItems =
      new List<DropdownMenuItem<String>>();
  List<LoginResponse> _societyList = new List<LoginResponse>();
  LoginResponse _selectedSocietyLogin;
  var username, password, societyId, flat, block, duesRs = "0.0", duesDate = "";

  List<RootTitle> _list = new List<RootTitle>();
  int _currentIndex = 0;
  int _moreIndex = 0;
  ProgressDialog _progressDialog;

  var name = '';
  var email = '', phone = '';
  var photo = '';

  List<Banners> _bannerList = List<Banners>();

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
        getDisplayName();
        getMobile();
        getPhoto();
        SQLiteDbProvider.db.getDataBaseInstance();
        GlobalFunctions.getAppPackageInfo();
        GlobalFunctions.checkInternetConnection().then((internet) {
          if (internet) {
            getDuesData();
            getAllSocietyData();
            getBannerData();
            //geProfileData();
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

  void geProfileData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    restClient.getProfileData(societyId, userId).then((value) {
      //  _progressDialog.hide();
      if (value.status) {
        setState(() {
          List<dynamic> _list = value.data;
          List<ProfileInfo> _profileList =
              List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
          photo = _profileList[0].PROFILE_PHOTO;
          name = _profileList[0].NAME;
          GlobalVariables.userNameValueNotifer.value = name;
          GlobalVariables.userImageURLValueNotifer.value = photo;
          GlobalVariables.userImageURLValueNotifer.notifyListeners();
          GlobalVariables.userNameValueNotifer.notifyListeners();
          GlobalFunctions.saveUserProfileToSharedPreferences(photo);
          GlobalFunctions.saveDisplayUserNameToSharedPreferences(name);
        });
      }
    }).catchError((Object obj) {
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

  int _activeMeterIndex;

  @override
  Widget build(BuildContext context) {
    FirebaseMessagingHandler().getToken();
    print('DashBoard context : ' + context.toString());
    print('BaseStatefulState context : ' + BaseStatefulState.getCtx.toString());
    print(
        'DashBoard _dashboardSacfoldKey : ' + _dashboardSacfoldKey.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getExpandableListViewData(context);
    // TODO: implement build
    //  GlobalFunctions.showToast("Dashboard state page");
    return Builder(
      builder: (context) => Scaffold(
        key: _dashboardSacfoldKey,
        // appBar: CustomAppBar.ScafoldKey(AppLocalizations.of(context).translate('overview'),context,_dashboardSacfoldKey),
        body: WillPopScope(child: getBodyLayout(), onWillPop: onWillPop),
        drawer: getDrawerLayout(),
        // bottomNavigationBar: getBottomNavigationBar(),
      ),
    );
  }

  getBodyLayout() {
    return Stack(
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
                        )
                    ),
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
                              _dashboardSacfoldKey.currentState.openDrawer();
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
                              child: Text(
                                'OVERVIEW',
                                style: TextStyle(
                                    color: GlobalVariables.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        _dashboardSacfoldKey.currentContext);
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
                                            margin: EdgeInsets.only(top: 5),
                                            //color: GlobalVariables.grey,
                                            child: SvgPicture.asset(
                                              GlobalVariables
                                                  .notificationBellIconPath,
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topRight,
                                            margin: EdgeInsets.only(left: 8),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: GlobalVariables
                                                      .orangeYellow,
                                                  border: Border.all(
                                                      color: GlobalVariables
                                                          .transparent,
                                                      width: 1)),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  newNotificationCounterValue
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: GlobalVariables
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ),
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
                                            child: userImageURLValueNotifer
                                                    .isEmpty
                                                ? AppAssetsImage(
                                                    GlobalVariables
                                                        .componentUserProfilePath,
                                                    imageWidth:20.0,
                                                    imageHeight:20.0,
                                                    borderColor:
                                                        GlobalVariables.grey,
                                                    borderWidth: 1.0,
                                                    fit: BoxFit.cover,
                                                    radius: 10.0,
                                                  )
                                                : AppNetworkImage(
                                                    userImageURLValueNotifer,
                                                    imageWidth:20.0,
                                                    imageHeight:20.0,
                                                    borderColor:
                                                        GlobalVariables.grey,
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
                  duesLayout(),
                ],
              ),
              getHomePage()
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

  getHomePage() {
    return Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            // color: GlobalVariables.grey,
            width: MediaQuery.of(context).size.width / 1.1,
            margin: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).size.height / 100,
                0,
                0), //color: GlobalVariables.black,
            child: Container(
              //color: GlobalVariables.green,
              margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              //getMyUnitPage();
                              redirectToPage(AppLocalizations.of(context)
                                  .translate('my_unit'));
                            },
                            child: Container(
                              // color: GlobalVariables.black,
                              width: 100,
                              height: 100,
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
                                          .translate('my_unit'))),
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
                              redirectToPage(AppLocalizations.of(context)
                                  .translate('my_complex'));
                            },
                            child: Container(
                              //    color: GlobalVariables.green,
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: SvgPicture.asset(
                                        GlobalVariables.buildingIconPath),

                                  ),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Text(AppLocalizations.of(context)
                                          .translate('my_complex'))),
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
                              if (AppPermission.isSocHelpDeskPermission)
                                redirectToPage(AppLocalizations.of(context)
                                    .translate('help_desk'));
                              else
                                GlobalFunctions
                                    .contactChairPersonForPermissionDialog(
                                        context);
                            },
                            child: Container(
                              //   color: GlobalVariables.black,
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: SvgPicture.asset(
                                        GlobalVariables.supportIconPath),
                                  ),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Text(AppLocalizations.of(context)
                                          .translate('help_desk'))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //color: GlobalVariables.green,
                    margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              // getClubFacilitiesPage();
                              redirectToPage(AppLocalizations.of(context)
                                  .translate('classified'));
                            },
                            child: Container(
                              //    color: GlobalVariables.black,
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: SvgPicture.asset(
                                        GlobalVariables.shoppingIconPath),
                                  ),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Text(AppLocalizations.of(context)
                                          .translate('classified'))),
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
                              if (AppPermission.isSocGatePassPermission)
                                redirectToPage(AppLocalizations.of(context)
                                    .translate('my_gate'));
                              else
                                GlobalFunctions
                                    .contactChairPersonForPermissionDialog(
                                        context);
                            },
                            child: Container(
                              //   color: GlobalVariables.green,
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: SvgPicture.asset(
                                        GlobalVariables.gatePassIconPath),
                                  ),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Text(AppLocalizations.of(context)
                                          .translate('my_gate'))),
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
                              redirectToPage(AppLocalizations.of(context)
                                  .translate('more'));
                            },
                            child: Container(
                              //     color: GlobalVariables.black,
                              width: 100,
                              height: 100,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: SvgPicture.asset(
                                        GlobalVariables.moreIconPath),
                                  ),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Text(AppLocalizations.of(context)
                                          .translate('more'))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                //GlobalFunctions.comingSoonDialog(context);
                                redirectToPage(AppLocalizations.of(context)
                                    .translate('exclusive_offer'));
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.lightGreen,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                        GlobalVariables.storeIconPath),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(AppLocalizations.of(context)
                                        .translate('exclusive_offer'))
                                  ],
                                ),
                              ),
                            )),
                        Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                // GlobalFunctions.comingSoonDialog(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BaseFindServices())).then((value) {
                                  GlobalFunctions.setBaseContext(
                                      _dashboardSacfoldKey.currentContext);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.lightGreen,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                        GlobalVariables.serviceIconPath),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text('Find Services')
                                  ],
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: GlobalVariables.mediumGreen,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        viewportFraction: 1.0,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                      ),
                      itemCount: _bannerList.length,
                      itemBuilder: (BuildContext context, int itemIndex) =>
                          _bannerList.length > 0
                              ? InkWell(
                                  onTap: () {
                                    print('SocietyID : ' + societyId);
                                    print('Name : ' + name);
                                    print('Mobile : ' + phone);
                                    print('Unit : ' + block + ' ' + flat);

                                    /*  var societyIdMD5 = md5.convert(utf8.encode(societyId));
                             var nameMD5 = md5.convert(utf8.encode(name));
                             var mobileMD5 = md5.convert(utf8.encode(phone));
                             var unitMD5 = md5.convert(utf8.encode(block+' '+flat));

                              print('societyIdMD5 : '+ societyIdMD5.toString());
                              print('nameMD5 : '+ nameMD5.toString());
                              print('mobileMD5 : '+ mobileMD5.toString());
                              print('unitMD5 : '+ unitMD5.toString());*/

                                    /* launch(_bannerList[itemIndex].Url +
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
                                        flat.toString());*/
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseWebViewScreen(
                                                    _bannerList[itemIndex].Url +
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
                                          _dashboardSacfoldKey.currentContext);
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    //color: GlobalVariables.black,
                                    //alignment: Alignment.center,
                                    child: Image.network(
                                      _bannerList[itemIndex].IMAGE,
                                      fit: BoxFit.fitWidth,
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

  getDrawerLayout() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  /*child: Image.asset(GlobalVariables.appLogoPath,
                    width: 250, height: 80, fit: BoxFit.fill),*/
                  margin: EdgeInsets.fromLTRB(10, 35, 5, 1),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.topLeft,
                  child: SvgPicture.asset(
                    GlobalVariables.drawerImagePath,
                    height: 40,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: EdgeInsets.all(5),
                  color: GlobalVariables.veryLightGray,
                  child: getHeaderLayout(),
                ),
                getListData(),
              ],
            ),
          ),
        ),
      );
    });
  }

  getHeaderLayout() {
    return FutureBuilder<Map<String, dynamic>>(
      future: getHeaderData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          print('header data snap map : ' + snapshot.data.toString());
          return Column(
            children: <Widget>[
              Container(
                //color:GlobalVariables.white,
                //  padding: EdgeInsets.all(5),
                margin: EdgeInsets.fromLTRB(5, 0, 5,
                    0), // width: MediaQuery.of(context).size.width / 2.2,
                //  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                /*    decoration: BoxDecoration(
                                  color: GlobalVariables.white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                            */
                //TODO : Dropdown
                child:
                    /*AppDropDown<String>(
                  _societyListItems,
                  changeDropDownItem,
                  value: _selectedItem,
                  icon: Icons.keyboard_arrow_down,
                  iconColor: GlobalVariables.black,
                ),*/
                    DropdownButton(
                  items: _societyListItems,
                  onChanged: changeDropDownItem,
                  value: _selectedItem,
                  underline: SizedBox(),
                  isExpanded: false,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: GlobalVariables.black,
                  ),
                  //iconSize: 20,
                ),
              ),
              Container(
                //color: GlobalVariables.black,
                //margin: EdgeInsets.all(5),
                // padding: EdgeInsets.all(5),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        navigateToProfilePage();
                      },
                      child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
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
                                        imageWidth:70.0,
                                        imageHeight:70.0,
                                        borderColor: GlobalVariables.grey,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 30.0,
                                      )
                                    : AppNetworkImage(
                                        userImageURLValueNotifer,
                                        imageWidth:70.0,
                                        imageHeight:70.0,
                                        borderColor: GlobalVariables.grey,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 30.0,
                                      );
                              })),
                    ),
                    Flexible(
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        //color: GlobalVariables.red,
                        //  padding: EdgeInsets.all(5),
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  5, 0, 0, 5), //color: GlobalVariables.green,
                              //TODO : UserName
                              child: ValueListenableBuilder(
                                  valueListenable:
                                      GlobalVariables.userNameValueNotifer,
                                  builder: (BuildContext context,
                                      String userNameValueNotifer,
                                      Widget child) {
                                    return AutoSizeText(
                                      userNameValueNotifer,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: GlobalVariables.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                    );
                                  }),
                            ),
                            Container(
                              margin: EdgeInsets.all(
                                  5), //   color: GlobalVariables.green,
                              //TODO : CustomerID
                              child: AutoSizeText(
                                (AppLocalizations.of(context)
                                        .translate("str_consumer_id") +
                                    ' : ' +
                                    snapshot
                                        .data[GlobalVariables.keyConsumerId]),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: GlobalVariables.grey, fontSize: 15),
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(
                                  5), //  color: GlobalVariables.green,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Visibility(
                                    visible: false,
                                    child: InkWell(
                                      onTap: () {
                                        GlobalFunctions.showToast("Logout");
                                        GlobalFunctions
                                            .clearSharedPreferenceData();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0, 0, 5, 5), //TODO: logout
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              'Logout',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: GlobalVariables.grey,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Container(
                                        margin: EdgeInsets.all(5),
                                        //TODO: Divider
                                        height: 20,
                                        width: 8,
                                        child: VerticalDivider(
                                          color: GlobalVariables.black,
                                        )),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                            5, 0, 5, 5), //Todo: setting
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Setting',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: GlobalVariables.grey,
                                            ),
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
        child: ListView.builder(
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
                                          child: AutoSizeText(
                                            _list[i].title,
                                            style: TextStyle(
                                                color: GlobalVariables.grey,
                                                fontSize: 14),
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
                                                    child: Text(
                                                      item,
                                                      style: new TextStyle(
                                                          fontSize: 16.0,
                                                          color: GlobalVariables
                                                              .grey),
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
            }),
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
    //  _progressDialog.show();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);

    String loggedUsername = await GlobalFunctions.getLoggedUserName();
    if (loggedUsername.length == 0) {
      GlobalFunctions.notAllowForRunAppDialog(context);
    } else {
      password = await GlobalFunctions.getPassword();
      societyId = await GlobalFunctions.getSocietyId();
      String loginId = await GlobalFunctions.getLoginId();
      int prefPos = 0;
      restClient.getAllSocietyData(loggedUsername).then((value) {
        if (value.status) {
          List<dynamic> _list = value.data;

          _societyList = List<LoginResponse>.from(
              _list.map((i) => LoginResponse.fromJson(i)));
          print('Societylist length ' + _societyList.length.toString());
          for (int i = 0; i < _societyList.length; i++) {
            _societyList[i].LoggedUsername = loggedUsername;
            LoginResponse loginResponse = _societyList[i];

            /*    cryptor.generateRandomKey().then((value) async {
            final encrypted =  await cryptor.encrypt(loginResponse.PASSWORD, value);
            final decrypted =  await cryptor.decrypt(loginResponse.PASSWORD, 'incredible');
            print('"loginResponse.ID : ' + loginResponse.ID);
            print('ShardPref societyId : ' + societyId);
            print('SocietyId ' + loginResponse.SOCIETY_ID);
            print('PASSWORD ' + loginResponse.PASSWORD);
            print('encrypted PASSWORD ' + encrypted);
            print('decrypted PASSWORD ' + decrypted);

          });*/
            /*   var bytes1 = utf8.encode("incredible");         // data being hashed
          var digest1 = sha1.convert(bytes1);         // Hashing Process
          print("Digest as bytes: ${digest1.bytes}");   // Print Bytes
          print("Digest as hex string: $digest1");*/
            print('"loginResponse.ID : ' + loginResponse.ID);
            print('ShardPref societyId : ' + societyId);
            print('SocietyId ' + loginResponse.SOCIETY_ID);
            print('PASSWORD ' + loginResponse.PASSWORD);

            //  print('SALT KEY '+utf8.encode('incredible').toString());

            //   print('ENCRYPTION PASSWORD '+ sha1.convert(utf8.encode('incredible')+utf8.encode(loginResponse.PASSWORD)).toString());

            //  print('DECRYPTION PASSWORD '+ sha1.convert();

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
                if (_societyListItems.length > 0) {
                  prefPos = i;
                  _societyListItems.insert(
                      0,
                      DropdownMenuItem(
                        value: loginResponse.ID,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            loginResponse.Society_Name +
                                " " +
                                loginResponse.BLOCK +
                                " " +
                                loginResponse.FLAT,
                            style: TextStyle(
                                color: GlobalVariables.black, fontSize: 12),
                            maxLines: 1,
                          ),
                        ),
                      ));
                } else {
                  _societyListItems.add(DropdownMenuItem(
                    value: loginResponse.ID,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                      child: AutoSizeText(
                        loginResponse.Society_Name +
                            " " +
                            loginResponse.BLOCK +
                            " " +
                            loginResponse.FLAT,
                        style: TextStyle(
                            color: GlobalVariables.black, fontSize: 12),
                        maxLines: 1,
                      ),
                    ),
                  ));
                }
              } else {
                _societyListItems.add(DropdownMenuItem(
                  value: loginResponse.ID,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      loginResponse.Society_Name +
                          " " +
                          loginResponse.BLOCK +
                          " " +
                          loginResponse.FLAT,
                      style:
                          TextStyle(color: GlobalVariables.black, fontSize: 12),
                      maxLines: 1,
                    ),
                  ),
                ));
              }
            }
            //print('value: ' + _societyListItems[i].value.toString());
          }
          print('size : ' + _societyListItems.length.toString());
          if (_societyListItems.length > 0) {
            print('_societyListItems 0 : ' + _societyListItems[0].toString());
            _selectedItem = _societyListItems[0].value;
            print('_selectedItem initial : ' + _selectedItem.toString());
            _selectedSocietyLogin = _societyList[prefPos];
            // if(_selectedSocietyLogin.User_Status!='C') {
            _selectedSocietyLogin.PASSWORD = password;
            _selectedSocietyLogin.LoggedUsername = loggedUsername;
            print("Flat" + _selectedSocietyLogin.FLAT.toString());
            GlobalFunctions.saveDataToSharedPreferences(_selectedSocietyLogin);

            if (Platform.isAndroid) {
              if (value.android_version != AppPackageInfo.version) {
                //show app update Dialog
                GlobalFunctions.appUpdateDialog(context, value.android_type);
              }
            } else if (Platform.isIOS) {
              if (value.ios_version != AppPackageInfo.version) {
                //show app update Dialog
                GlobalFunctions.appUpdateDialog(context, value.ios_type);
              }
            }
          } else {
            //show logout Dialog
            GlobalFunctions.forceLogoutDialog(context);
          }
        } else {
          if (value.message ==
              AppLocalizations.of(context)
                  .translate('invalid_username_password')) {
            GlobalFunctions.notAllowForRunAppDialog(context);
          }
        }

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
        }
            // }
            );
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
  }

  void changeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        setState(() {
          _selectedItem = value;
          print('_selctedItem:' + _selectedItem.toString());
          for (int i = 0; i < _societyList.length; i++) {
            if (_selectedItem == _societyList[i].ID) {
              _selectedSocietyLogin = _societyList[i];
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
            AppLocalizations.of(context).translate("my_dues"),
            AppLocalizations.of(context).translate("my_household"),
            // AppLocalizations.of(context).translate("my_documents"),
          ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('my_complex'),
          rootIconData: GlobalVariables.myBuildingIconPath,
          //innerIconData: GlobalVariables.myFlatIconPath,
          items: [
            AppLocalizations.of(context).translate("announcement"),
            AppLocalizations.of(context).translate("meetings"),
            AppLocalizations.of(context).translate("poll_survey"),
            AppLocalizations.of(context).translate("documents"),
            AppLocalizations.of(context).translate("directory"),
            AppLocalizations.of(context).translate("events")
          ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('discover'),
          rootIconData: GlobalVariables.myServiceIconPath,
          //innerIconData: GlobalVariables.myFlatIconPath,
          items: [
           // AppLocalizations.of(context).translate("my_classified"),
            AppLocalizations.of(context).translate("classified"),
            //AppLocalizations.of(context).translate("my_services"),
            AppLocalizations.of(context).translate("services"),
            AppLocalizations.of(context).translate("exclusive_offer"),
          ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('facilities'),
          rootIconData: GlobalVariables.myClubIconPath,
          //innerIconData: GlobalVariables.myFlatIconPath,
          items: []),
      if (AppPermission.isSocGatePassPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('my_gate'),
            rootIconData: GlobalVariables.myGateIconPath,
            //innerIconData: GlobalVariables.myFlatIconPath,
            items: [
              AppLocalizations.of(context).translate("my_activities"),
              AppLocalizations.of(context).translate("helpers"),
            ]),
      if (AppPermission.isSocHelpDeskPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('help_desk'),
            rootIconData: GlobalVariables.mySupportIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: []),
      if (AppPermission.isSocExpensePermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('expense'),
            rootIconData: GlobalVariables.expenseIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: [])
      else if (AppPermission.isAddExpensePermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('expense'),
            rootIconData: GlobalVariables.expenseIconPath,
            // innerIconData: GlobalVariables.myFlatIconPath,
            items: []),
      if (AppPermission.isUserAdminHelpDeskPermission)
        new RootTitle(
            title: AppLocalizations.of(context).translate('admin'),
            rootIconData: GlobalVariables.myAdminIconPath,
            //  innerIconData: GlobalVariables.myFlatIconPath,
            items: [
              AppLocalizations.of(context).translate("assign_helpdesk"),
            ]),
      new RootTitle(
          title: AppLocalizations.of(context).translate('settings'),
          rootIconData: GlobalVariables.settingsIconPath,
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
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    //societyId=110015.toString();
    restClientERP.getDuesData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());

      if (value.status) {
        GlobalVariables.isERPAccount = true;
      } else {
        GlobalVariables.isERPAccount = false;
      }

      duesRs = value.DUES.toString();
      duesDate = value.DUE_DATE.toString();
      if (duesRs.length == 0) {
        duesRs = "0.0";
      }
      if (duesDate == 'null') duesDate = '-';
      GlobalFunctions.saveDuesDataToSharedPreferences(duesRs, duesDate);
      _progressDialog.hide();

      if (_dashboardSacfoldKey.currentState != null) {
        if (_dashboardSacfoldKey.currentState.isDrawerOpen) {
          Navigator.of(context).pop();
        }
      }
      if (this.mounted) {
        setState(() {
          //Your state change code goes here
        });
      }
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

  getBannerData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    restClient.getBannerData().then((value) {
      print('Response : ' + value.toString());
      if (value.status) {
        List<dynamic> _list = value.data;
        print('complaint list length : ' + _list.length.toString());

        // print('first complaint : ' + _list[0].toString());
        // print('first complaint Status : ' + _list[0]['STATUS'].toString());

        _bannerList = List<Banners>.from(_list.map((i) => Banners.fromJson(i)));
        if (this.mounted) {
          setState(() {
            //Your state change code goes here
          });
        }
      }
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

  duesLayout() {
    print('duesDate : ' + duesDate);
    return Align(
      alignment: Alignment.center,
      child: Container(
        //color: GlobalVariables.black,
        width: MediaQuery.of(context).size.width / 0.8,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 10, 0, 0),
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0))),
          elevation: 20.0,
          shadowColor: GlobalVariables.green.withOpacity(0.3),
          margin: EdgeInsets.all(20),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    GlobalVariables.whileBGPath,
                  ),
                ),
              ),
              GlobalVariables.isERPAccount
                  ? Container(
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                    .translate('total_due'),
                                style: TextStyle(
                                    color: GlobalVariables.mediumGreen,
                                    fontSize: 14),
                              ),
                              double.parse(duesRs) > 0
                                  ? Text(
                                      getBillPaymentStatus(),
                                      style: TextStyle(
                                          color: getBillPaymentStatusColor(),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text(
                                      'Paid',
                                      style: TextStyle(
                                          color: GlobalVariables.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                " Rs. " +
                                    double.parse(duesRs).toStringAsFixed(2),
                                style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              Visibility(
                                visible:
                                    double.parse(duesRs) > 0 ? true : false,
                                child: Text(
                                  duesDate.length > 0 && duesDate != '-'
                                      ? GlobalFunctions.convertDateFormat(
                                          duesDate, 'dd-MM-yyyy')
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: GlobalVariables.mediumGreen,
                            margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: Divider(
                              height: 1,
                              color: GlobalVariables.mediumGreen,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    //GlobalFunctions.showToast('Transaction');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseLedger())).then((value) {
                                      GlobalFunctions.setBaseContext(
                                          _dashboardSacfoldKey.currentContext);
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('transaction_history'),
                                    style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    //GlobalFunctions.showToast('Pay Now');
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BaseMyUnit(null)))
                                        .then((value) {
                                      GlobalFunctions.setBaseContext(
                                          _dashboardSacfoldKey.currentContext);
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16,
                                    ),
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
            child: Text(
              AppLocalizations.of(context).translate('erp_acc_not'),
              style: TextStyle(
                  color: GlobalVariables.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width / 2,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: ButtonTheme(
              //minWidth: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                color: GlobalVariables.green,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BaseAboutSocietyRunInfo()))
                      .then((value) {
                    GlobalFunctions.setBaseContext(
                        _dashboardSacfoldKey.currentContext);
                  });
                },
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.green)),
                child: Text(
                  AppLocalizations.of(context).translate('i_am_interested'),
                  style: TextStyle(fontSize: GlobalVariables.textSizeMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getDisplayName() {
    GlobalFunctions.getDisplayName().then((value) {
      name = value;
      GlobalVariables.userNameValueNotifer.notifyListeners();
    });
  }

  getMobile() {
    GlobalFunctions.getMobile().then((value) {
      phone = value;
      getEmail();
    });
  }

  getEmail() {
    GlobalFunctions.getUserId().then((value) {
      email = value;
    });
  }

  void getPhoto() {
    GlobalFunctions.getPhoto().then((value) {
      photo = value;
      GlobalVariables.userImageURLValueNotifer.notifyListeners();
      print('profile image : ' + photo.toString());
    });
  }

  Future<void> redirectToPage(String item) async {
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      } else {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      }
    } else if (item == AppLocalizations.of(context).translate('my_dues')) {
      //Redirect to  My Dues
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_dues'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_household')) {
      //Redirect to  My Household
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_household'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_documents')) {
      //Redirect to  My Documents
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_documents'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_tenants')) {
      //Redirect to  My Tenants
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyUnit(
                      AppLocalizations.of(context).translate('my_tenants'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('my_complex')) {
      //Redirect to  My Complex
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('my_complex'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('announcement')) {
      //Redirect to News Board
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('announcement'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('meetings')) {
      //Redirect to News Board
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('meetings'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('directory')) {
      //Redirect to  Directory
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseMyComplex(
                      AppLocalizations.of(context).translate('directory'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('discover')) {
      //Redirect to  Discover
      //GlobalFunctions.comingSoonDialog(context);
      GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
    } else if (item == AppLocalizations.of(context).translate('classified')) {
      //Redirect to  classified
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseDiscover(
                      AppLocalizations.of(context).translate('classified'))))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('services')) {
      //Redirect to  services
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseFindServices()))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('exclusive_offer')) {
      //Redirect to  exclusive_offer
      //GlobalFunctions.comingSoonDialog(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseNearByShopPerCategory())).then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
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
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('expense')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => BaseExpense()))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('admin')) {
      //Redirect to  Admin
      GlobalFunctions.comingSoonDialog(context);
      /*Navigator.push(
         context, MaterialPageRoute(builder: (context) => BaseMyUnit(null)));*/
    } else if (item ==
        AppLocalizations.of(context).translate('assign_helpdesk')) {
      //Redirect to  Help Desk
      // GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseHelpDesk(true)))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('about_us')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseAboutSocietyRunInfo())).then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item ==
        AppLocalizations.of(context).translate('change_password')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseChangePassword()))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('settings')) {
      //Redirect to  Admin
      //  GlobalFunctions.showToast("Coming Soon...");
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => BaseAppSettings()))
          .then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });
    } else if (item == AppLocalizations.of(context).translate('more')) {
      //Redirect to  Admin«
      GlobalFunctions.comingSoonDialog(context);
     /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BaseCreateClassifiedListing())).then((value) {
        GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      });*/

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
                      borderRadius: BorderRadius.circular(25.0)),
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
            child: Text(
              AppLocalizations.of(context).translate('sure_logout'),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
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
                      child: Text(
                        AppLocalizations.of(context).translate('yes'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('no'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
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
      GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
      geProfileData();
    } else {
      GlobalFunctions.setBaseContext(_dashboardSacfoldKey.currentContext);
    }
  }

  String getBillPaymentStatus() {
    String status = '';

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(duesDate);
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

  getBillPaymentStatusColor() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(duesDate);
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      return Color(0xFFc0392b);
    } else if (days == 0) {
      return Color(0xFFf39c12);
    } else if (days >= -2 && days < 0) {
      return Color(0xFFf39c12);
    } else {
      return GlobalVariables.mediumGreen;
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
      if (_socPermissionList[i] == AppPermission.socHelpDeskPermission) {
        AppPermission.isSocHelpDeskPermission = true;
      }
      if (_socPermissionList[i] == AppPermission.socExpensePermission) {
        AppPermission.isSocExpensePermission = true;
      }
      if (_socPermissionList[i] == AppPermission.socGatePassPermission) {
        AppPermission.isSocGatePassPermission = true;
      }
      if (_socPermissionList[i] == AppPermission.socAddVehiclePermission) {
        AppPermission.isSocAddVehiclePermission = true;
      }
    }

    for (int i = 0; i < _userPermissionList.length; i++) {
     // print('_userPermissionList[i] : ' + _userPermissionList[i].toString());
      if (_userPermissionList[i] == AppPermission.userHelpDeskPermission) {
        AppPermission.isUserHelpDeskPermission = true;
      }
      if (_userPermissionList[i] == AppPermission.userAdminHelpDeskPermission) {
        AppPermission.isUserAdminHelpDeskPermission = true;
      }
      if (_userPermissionList[i] == AppPermission.userAdminPermission) {
        AppPermission.isUserAdminPermission = true;
      }
      if (_userPermissionList[i] == AppPermission.addExpensePermission) {
        AppPermission.isAddExpensePermission = true;
      }
      if (_userPermissionList[i] == AppPermission.userAddMemberPermission) {
        AppPermission.isUserAddMemberPermission = true;
      }
    }
  }
}

class RootTitle {
  String title;
  String rootIconData;

  //IconData innerIconData;
  List<String> items;

  RootTitle(
      {this.title, this.rootIconData, /* this.innerIconData, */ this.items});
}
