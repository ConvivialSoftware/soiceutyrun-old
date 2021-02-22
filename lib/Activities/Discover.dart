import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/ListOfHomeService.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppWidget.dart';
import 'base_stateful.dart';

class BaseDiscover extends StatefulWidget {
  String pageName;

  BaseDiscover(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DiscoverState(pageName);
  }
}

class DiscoverState extends BaseStatefulState<BaseDiscover>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Classified> _classifiedList = new List<Classified>();
  List<NearByShop> _nearByShopList = new List<NearByShop>();

  String pageName;
  var width, height;

  DiscoverState(this.pageName);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getClassifiedList();
    getNearByShopList();
  }

  @override
  Widget build(BuildContext context) {
    //  _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (pageName != null) {
      redirectToPage(pageName);
    }
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
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
            AppLocalizations.of(context).translate('discover'),
            style: TextStyle(color: GlobalVariables.white),
          ),
          bottom: getTabLayout(),
          elevation: 0,
        ),
        body: TabBarView(controller: _tabController, children: <Widget>[
          getClassifiedLayout(),
          getServiceLayout(),
          //getNearByShopLayout(),
        ]),
      ),
    );
  }

  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('classified'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('services'),
            ),
          ),
         /* Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('near_by_shop'),
            ),
          )*/
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.white30,
        indicatorColor: GlobalVariables.white,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.white,
      ),
    );
  }

  getClassifiedList() {
    _classifiedList = [
      Classified(
          title: "3BHK Flat in Kanvivali",
          subDesc: "Mahavir Nagar,Kanvivali",
          rs: "Rs. 2,25,00,000",
          type: "Sell",
          daysAgo: "2 days ago",
          category: "Real Estate"),
      Classified(
          title: "1BHK Flat in Borivali",
          subDesc: "Chikuwadi,Borivali",
          rs: "Rs. 80,00,000",
          type: 'Buy',
          daysAgo: "5 days ago",
          category: "Real Estate"),
      Classified(
          title: "Hundai Creta",
          subDesc: "Staya Nagar, Borivali",
          rs: "Rs. 8,25,000",
          type: 'Sell',
          daysAgo: "10 days ago",
          category: "Vehicle"),
      Classified(
          title: "Maruti Ertiga",
          subDesc: "Staya Nagar, Borivali",
          rs: "Rs. 7,50,000",
          type: 'Sell',
          daysAgo: "13 days ago",
          category: "Vehicle"),
      Classified(
          title: "2BHK Flat in Kanvivali",
          subDesc: "Parekh Nagar,Station Road",
          rs: "Rs. 32,000",
          type: 'Rent',
          daysAgo: "13 days ago",
          category: "Real Estate"),
    ];
  }

  getClassifiedLayout() {
    print('getClassifiedLayout Tab Call');
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
                    context, 150.0),
              //  classifiedFilterButtonLayout(),
                getClassifiedListDataLayout(),
                addClassifiedDiscoverFabLayout(GlobalVariables.CreateClassifiedListingPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  classifiedFilterButtonLayout() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        //height: 50,
        margin: EdgeInsets.fromLTRB(
            10, MediaQuery.of(context).size.height / 30, 10, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          //  borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Filter",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumGreen,
                          )),
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                  color: GlobalVariables.mediumGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  // padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: FlatButton(
                      onPressed: () {},
                      child: Text(
                        AppLocalizations.of(context).translate('my_list'),
                        style: TextStyle(
                            color: GlobalVariables.white, fontSize: 14),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  addClassifiedDiscoverFabLayout(String pageTitle) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
                if (pageTitle == GlobalVariables.CreateClassifiedListingPage) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseCreateClassifiedListing()));
                } else if (pageTitle == GlobalVariables.AddNearByShopPage) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseAddNearByShop()));
                }
              },
              child: Icon(
                Icons.add,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getClassifiedListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 10, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _classifiedList.length,
                itemBuilder: (context, position) {
                  return getClassifiedListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getClassifiedListItemLayout(int position) {
    return /*Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: GlobalVariables.mediumGreen,
                      borderRadius: BorderRadius.circular(10)),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                _classifiedList[position].title,
                                style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              child: Text(
                                _classifiedList[position].daysAgo,
                                style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _classifiedList[position].subDesc,
                                  style: TextStyle(
                                    color: GlobalVariables.lightGray,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Text(
                                  _classifiedList[position].rs,
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
                              padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                              decoration: BoxDecoration(
                                  color: GlobalVariables.mediumGreen,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                _classifiedList[position].category,
                                style: TextStyle(
                                  color: GlobalVariables.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                              padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                              decoration: BoxDecoration(
                                  color: getClassifiedTypeColor(
                                      _classifiedList[position].type),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                _classifiedList[position].type,
                                style: TextStyle(
                                  color: GlobalVariables.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )*/InkWell(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseClassifiedListItemDesc()));
      },
      child: Container(
        decoration: boxDecoration(
            showShadow: false, bgColor: GlobalVariables.white, radius: 10.0),
        margin: EdgeInsets.all(10),

        // .cornerRadiusWithClipRRect(10.0) .withShadow() .paddingOnly(top: 8,left: 16,right: 16,bottom: 8)
        //     color: t9_white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 2,bottom: 4,left: 8,right: 8),
                     // alignment: Alignment.topRight ,
                     // padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                          BorderRadius.all(Radius.circular(8))),
                      child: text('Rs. 1,00,000',
                          textColor: GlobalVariables.white,fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    child: CachedNetworkImage(
                        imageUrl: "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
                        height: 50,
                        width: 50,
                        fit: BoxFit.fill),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(
                                    'Resale 1bhk luxurious Flat in jail Road. Nasik Road.',
                                    fontFamily: GlobalVariables.fontBold,
                                    fontSize: GlobalVariables.textSizeMedium,
                                    maxLine: 2,
                                    textColor: GlobalVariables.green
                                  ),
                                  SizedBox(height: 4),
                                  text('Dasak Gaon, Nashik, Maharashtra',
                                      textColor: GlobalVariables.lightGray,
                                      fontSize: GlobalVariables.textSizeSmall,
                                    maxLine: 2

                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 2,bottom: 4,left: 16,right: 16),
                              child: text(
                                "Rent",
                                  fontFamily: GlobalVariables.fontBold,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                  textColor: GlobalVariables.grey
                              ),
                            ),
                            Container(
                              child: text(
                                "Real Estate",
                                  fontFamily: GlobalVariables.fontBold,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                  textColor: GlobalVariables.grey
                              ),
                            ),
                            //SizedBox(width: 10),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getClassifiedTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case "sell":
        return GlobalVariables.skyBlue;
        break;
      case "buy":
        return GlobalVariables.green;
        break;
      case "rent":
        return GlobalVariables.orangeYellow;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  getServiceLayout() {
    print('getClassifiedLayout Tab Call');
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
                    context, 150.0),
                serviceSearchFilterLayout(),
                getServiceTypeDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  serviceSearchFilterLayout() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        //height: 50,
        margin: EdgeInsets.fromLTRB(
            10, MediaQuery.of(context).size.height / 40, 10, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          //  borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Search",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumGreen,
                          )),
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Filter",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumGreen,
                          )),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  getServiceTypeDataLayout() {
    return Container(
      //color: GlobalVariables.black,
      //width: MediaQuery.of(context).size.width / 1.1,
      margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0,
          0), //color: GlobalVariables.black,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseListOfHomeService()));
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('home_care'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('pest_control'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('laundry'))),
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
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('move_in_out'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('health'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('govt_legal'))),
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
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('event_organiser'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('kids'))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
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
                                      .translate('other_services'))),
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
        ),
      ),
    );
  }

  getNearByShopList() {
    _nearByShopList = [
      NearByShop(
          title: 'Siddhivinayak Traders',
          subDesc: 'Grocery Shop',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: true),
      NearByShop(
          title: 'Arogya Medical',
          subDesc: 'Medical',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: true),
      NearByShop(
          title: 'Raj Bakery',
          subDesc: 'Bakery Shop',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: false),
      NearByShop(
          title: 'Lookout',
          subDesc: 'Salon and Beauty Parlor',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: false),
      NearByShop(
          title: 'Elite Spa',
          subDesc: 'Spa',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: true),
      NearByShop(
          title: 'Amar Aerobics & Yoga',
          subDesc: 'Aerobics & Yoga',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: true),
      NearByShop(
          title: 'Fitness Gym',
          subDesc: 'Gym',
          rateCount: '4.3',
          isCall: true,
          isMail: true,
          isWeb: true),
    ];
  }

  getNearByShopLayout() {
    print('getClassifiedLayout Tab Call');
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
                    context, 150.0),
                //serviceSearchFilterLayout(),
                getNearByShopListDataLayout(),
                addClassifiedDiscoverFabLayout(
                    GlobalVariables.AddNearByShopPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNearByShopListDataLayout() {
    return BaseNearByShopPerCategory();/*Container(
      alignment: Alignment.topCenter,
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 12, 10, 0),
      child: Builder(
          builder: (context) => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 2),
                ),
                scrollDirection: Axis.vertical,
                itemCount: _nearByShopList.length,
                itemBuilder: (context, position) {
                  return getNearByShopListItemLayout(position);
                },
                //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );*/
  }

  getNearByShopListItemLayout(int position) {
    return InkWell(
        onTap: () {

         /* Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseNearByShopPerCategory(_nearByShopList[position].title)));*/

        },
        child: category(GlobalVariables.white, GlobalVariables.shoppingIconPath,
            _nearByShopList[position].subDesc, context, position,
            isNew: false));
  }

  Widget category(
      Color color, String img, String name, BuildContext context, var id,
      {bool isNew = false, String type = 'New'}) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.center,
      children: [
        Container(
          width: width / 2,
          height: width / 3,
          margin: EdgeInsets.only(left: 5, right: 5,top: 10),
          decoration:
              boxDecoration(radius: 4, bgColor: color, showShadow: false),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(img, width: width / 12, height: width / 12),
              text('$name',
                  textColor: GlobalVariables.green,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontFamily: GlobalVariables.fontMedium,
                  maxLine: 2,
                  isCentered: true),
            ],
          ),
        ),
        Positioned(
          right: -5,
          top: -5,
          child: Visibility(
            visible: isNew,
            child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(right: 8, top: 8),
              padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
              decoration:
                  boxDecoration(bgColor: GlobalVariables.skyBlue, radius: 4),
              child: FittedBox(
                  child: text(type,
                      fontSize: 8.0, textColor: GlobalVariables.white)),
            ),
          ),
        ),
      ],
    );
  }

  void redirectToPage(String item) {
    if (item == AppLocalizations.of(context).translate('discover')) {
      //Redirect to Discover
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('classified')) {
      //Redirect to  Classified
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('services')) {
      //Redirect to  Services
      _tabController.animateTo(1);
    } else if (item == AppLocalizations.of(context).translate('near_by_shop')) {
      //Redirect to  NearByShop
      _tabController.animateTo(2);
    } else {
      _tabController.animateTo(0);
    }
  }
}

class Classified {
  String title, subDesc, rs, type, daysAgo, category;

  Classified(
      {this.title,
      this.subDesc,
      this.rs,
      this.type,
      this.daysAgo,
      this.category});
}

class NearByShop {
  String title, subDesc, rateCount;
  bool isCall, isMail, isWeb;

  NearByShop(
      {this.title,
      this.subDesc,
      this.rateCount,
      this.isCall,
      this.isMail,
      this.isWeb});
}
