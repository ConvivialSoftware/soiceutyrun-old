import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
//import 'package:social_share/social_share.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DashBoard.dart';
import 'package:societyrun/Activities/NearByShopPerCategoryItemDetails.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/NearByShopResponse.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_stateful.dart';

class BaseNearByShopPerCategory extends StatefulWidget {

  String exclusiveId;
  BaseNearByShopPerCategory({this.exclusiveId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NearByShopPerCategoryState();
  }
}

class NearByShopPerCategoryState
    extends BaseStatefulState<BaseNearByShopPerCategory>
    with SingleTickerProviderStateMixin {
  ProgressDialog _progressDialog;
  TabController _tabController;
  var width, height;

  NearByShopPerCategoryState();


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('initState Call');
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        Provider.of<NearByShopResponse>(context, listen: false)
            .getExclusiveOfferData(GlobalVariables.appFlag, null)
            .then((tabLength) {
          print(', : ' + tabLength.toString());
          _tabController =
              TabController(length: int.parse(tabLength), vsync: this);
          _tabController.addListener(() {
            print('_tabController.index : ' + _tabController.index.toString());
            setState(() {});
          });
        });
      }else{
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    // _tabController = TabController(length: 3, vsync: this);
    //_tabController.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<NearByShopResponse>.value(
        value: Provider.of<NearByShopResponse>(context),
        child: Consumer<NearByShopResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.nearByShopCategoryList.toString());
            if(value.nearByShopList.length>0) {
              if (widget.exclusiveId != null) {
                widget.exclusiveId=null;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                 // Navigator.of(context).pop();


                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NearByShopPerCategoryItemDetails(
                                  value.nearByShopList[0]))).then((value) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => BaseDashBoard()),
                            (Route<dynamic> route) => false);
                  });
                });
              }
            }
            return DefaultTabController(
              length: value.nearByShopCategoryList.length,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: GlobalVariables.green,
                  centerTitle: true,
                  leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: AppIcon(
                      Icons.arrow_back,
                      iconColor: GlobalVariables.white,
                    ),
                  ),
                  title: text(
                    AppLocalizations.of(context).translate('exclusive_offer'),
                      textColor: GlobalVariables.white, fontSize: 16,
                  ),
                  bottom: value.nearByShopCategoryList.isNotEmpty
                      ? getTabLayout(value)
                      : PreferredSize(
                          preferredSize: Size.fromHeight(0.0),
                          child: Container(),
                        ),
                  elevation: 0,
                ),
                body:
                    /*value.classifiedCategoryList.isNotEmpty && */ !value
                            .isLoading
                        ? getTabBarView(value)
                        : GlobalFunctions.loadingWidget(context),
              ),
            );
          },
        ));
  }

  /*Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.white,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context, 'back');
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.green,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('exclusive_offer'),
            style: TextStyle(color: GlobalVariables.green,fontSize: 16),
          ),
          bottom: getTabLayout(),
          elevation: 3,
        ),
        body:   WillPopScope(
            child: TabBarView(controller: _tabController, children: <Widget>[
              Container(
                color: GlobalVariables.veryLightGray,
                child: getNearByShopPerCategoryLayout(),
              ),
              SingleChildScrollView(
                child: Container(),
              ),
              SingleChildScrollView(
                child: Container(),
              ),
            ]),
            onWillPop: (){
              Navigator.pop(context);
              return;
            }),
      ),
    );*/
  getTabLayout(NearByShopResponse value) {
    return PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: TabBar(
        tabs: value.nearByShopCategoryList.map((e) {
          return Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: e.Category_Name,
            ),
          );
        }).toList(),
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.white30,
        indicatorColor: GlobalVariables.white,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.white,
      ),
    );
  }

  getTabBarView(NearByShopResponse value) {
    return TabBarView(
        controller: _tabController,
        children: value.nearByShopCategoryList.map<Widget>((dynamicContent) {
          return getNearByShopPerCategoryLayout(value);
        }).toList());
  }

  getNearByShopPerCategoryLayout(NearByShopResponse value) {
    int tabIndex = _tabController == null ? 0 : _tabController.index;
    NearByShopResponse _nearByShopResponse = NearByShopResponse();
    for (int i = 0; i < value.nearByShopList.length; i++) {
      var category = value.nearByShopCategoryList[tabIndex].Category_Name;
      print('category : ' + category.toString());
      if (category.toLowerCase() ==
          value.nearByShopList[i].Category.toLowerCase()) {
        _nearByShopResponse.nearByShopList.add(value.nearByShopList[i]);
      }
    }

    String tabName = value.nearByShopCategoryList[tabIndex].Category_Name;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.white30,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                //GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
                _nearByShopResponse.nearByShopList.isNotEmpty
                    ? getNearByShopPerCategoryListDataLayout(
                        _nearByShopResponse)
                    : GlobalFunctions.noDataFoundLayout(context,
                        'No Exclusive Offer Found For ' + tabName.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNearByShopPerCategoryListDataLayout(NearByShopResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 25, 0, 0),
      padding: EdgeInsets.all(10),
      // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.nearByShopList.length,
                itemBuilder: (context, position) {
                  return getNearByShopPerCategoryListItemLayout(
                      position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getNearByShopPerCategoryListItemLayout(
      int position, NearByShopResponse value) {
    return Container(
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 16),
        decoration: boxDecoration(
          radius: 10,
          showShadow: false,
          bgColor: Color(int.parse(value.nearByShopList[position].card_bg)),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(
                                left: 5, right: 5, top: 1, bottom: 1),
                            decoration: boxDecoration(
                                bgColor: GlobalVariables.white, radius: 30),
                            child: text(
                              'Till ' +
                                  GlobalFunctions.convertDateFormat(
                                      value.nearByShopList[position].exp_date,
                                      'dd-MMM-yyyy'),
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: AppNetworkImage(
                          value.nearByShopList[position].Img_Name,
                          imageWidth: width,
                          imageHeight: width * 0.5,
                          borderColor: GlobalVariables.transparent,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                child: text(
                                    value.nearByShopList[position].Title,
                                    fontWeight: FontWeight.bold,
                                    maxLine: 3,
                                    textColor: Color(int.parse(value
                                        .nearByShopList[position].title_bg)))),
                          ),
                          InkWell(
                            onTap: (){
                             /* var url = "https://wa.me/?text="+value.nearByShopList[position].Category+'\n'+value.nearByShopList[position].Title;
                              SocialShare.shareWhatsapp(url);*/
                              //launch(url);
                              launch("tel://" + value.nearByShopList[position].vendor_mobile);
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 8),
                              child:Icon(Icons.call,
                                size: 20,
                                color: GlobalVariables.white,
                              ),
                            ),
                          ),
                         /* SizedBox(
                            width: 16,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Icon(
                              Icons.favorite,
                              size: 24,
                              color: GlobalVariables.red,
                            ),
                          ),*/
                          // Image.asset(t3_ic_search)
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      text(value.nearByShopList[position].short_description,
                          textColor: Color(int.parse(
                              value.nearByShopList[position].title_bg)),
                          fontSize: GlobalVariables.textSizeMedium,
                          maxLine: 2),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NearByShopPerCategoryItemDetails(
                                      value.nearByShopList[position])));
                    },
                    child: Container(
                      decoration: const ShapeDecoration(
                        color: GlobalVariables.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: AppIcon(
                          Icons.arrow_forward,
                          iconColor: GlobalVariables.green,
                        ),
                        iconSize: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
