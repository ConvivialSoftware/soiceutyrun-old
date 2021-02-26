import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/NearByShopPerCategoryItemDetails.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/utils/AppWidget.dart';

import 'base_stateful.dart';

class BaseNearByShopPerCategory extends StatefulWidget {

  //var title;
  BaseNearByShopPerCategory();


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NearByShopPerCategoryState();
  }
}

class NearByShopPerCategoryState extends BaseStatefulState<BaseNearByShopPerCategory> with SingleTickerProviderStateMixin{

  ProgressDialog _progressDialog;
  TabController _tabController;
  NearByShopPerCategoryState();

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
    });
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
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
    );
  }
  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: TabBar(
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('all_offers'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('house_things'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('fashion'),
            ),
          ),
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.grey,
        indicatorColor: GlobalVariables.green,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.green,
      ),
    );
  }

  getNearByShopPerCategoryLayout() {
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
                getNearByShopPerCategoryListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNearByShopPerCategoryListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).size.height / 25, 0, 0),
      padding: EdgeInsets.all(10), // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder: (context, position) {
              return getNearByShopPerCategoryListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getNearByShopPerCategoryListItemLayout(int position) {
    var urlImg ="https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg";
    //var urlImg ="https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_dish1.png";
    ///images/theme3/t3_ic_dish2.jpg
    return InkWell(
      onTap: () async {

      },
      child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 16),
          decoration: boxDecoration(
            radius: 10,
            showShadow: false,
            bgColor: position%2!=0 ? GlobalVariables.lightCyan : GlobalVariables.lightOrange
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
                              padding: EdgeInsets.only(left: 5,right: 5,top: 1,bottom: 1),
                              decoration: boxDecoration(bgColor: GlobalVariables.white,radius: 30),
                              child: text('Till 31 March 2021',fontSize: 12.0,),
                            ),
                          ],
                        ),
                        ClipRRect(
                          child: /*CachedNetworkImage(
                            imageUrl: urlImg,
                          ),*/Image.asset(GlobalVariables.sofaIconPath),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  child: text(
                                    'Pay 50% less for your daily groceries.(First 5 Orders)',fontWeight: FontWeight.bold,maxLine:3,textColor: Colors.white
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: SvgPicture.asset(
                                GlobalVariables.whatsAppIconPath,
                                height: 20,
                                width: 20,
                                color: GlobalVariables.white,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.favorite,
                                size: 24,
                                color: GlobalVariables.red,
                              ),
                            ),
                           // Image.asset(t3_ic_search)
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        text('Woodsworth is our premium homegrown label thats part classic, part contemporary.',
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeMedium,
                            maxLine: 2),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NearByShopPerCategoryItemDetails()));
                      },
                      child: Container(
                        decoration: const ShapeDecoration(
                          color: GlobalVariables.white,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: GlobalVariables.green,
                          ),
                          iconSize: 28,
                        ),
                      ),
                    ),
                  ),
                  /*RaisedButton(
                    textColor: GlobalVariables.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0))),
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: GlobalVariables.green,
                        *//*gradient: LinearGradient(colors: <Color>[
                          GlobalVariables.green,
                          GlobalVariables.mediumGreen
                        ]),*//*
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            'View More',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NearByShopPerCategoryItemDetails()));
                    },
                  )*/
                ],
              ),
            ],
          )),
    );
  }

  void _handleTabSelection() {

  }


}
