//import 'package:after_layout/after_layout.dart';
import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/OwnerDiscover.dart';
import 'package:societyrun/Activities/ServicesPerCategory.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ClassifiedResponse.dart';
import 'package:societyrun/Retrofit/RestClientDiscover.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
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

//TickerProviderStateMixi
class DiscoverState extends BaseStatefulState<BaseDiscover>
    with SingleTickerProviderStateMixin ,AfterLayoutMixin<BaseDiscover> {
  TabController _tabController;
  String pageName;
  var width, height;

  DiscoverState(this.pageName);

  @override
  void dispose() {
    super.dispose();
  } // ProgressDialog _progressDialog;


  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
    Provider.of<ClassifiedResponse>(context, listen: false)
        .getClassifiedData()
        .then((tabLength) {
      print('tablength : ' + tabLength.toString());
      _tabController = TabController(length: int.parse(tabLength), vsync: this);
      _tabController.addListener(() {
        print('_tabController.index : ' + _tabController.index.toString());
        // _handleSelection(_tabController.index);
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print('initState Call');

  }

  @override
  Widget build(BuildContext context) {
    //   _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return ChangeNotifierProvider<ClassifiedResponse>.value(
        value: Provider.of<ClassifiedResponse>(context),
        child: Consumer<ClassifiedResponse>(
          builder: (context, value, child) {
            print(
                'Consumer Value : ' + value.classifiedCategoryList.toString());
            return DefaultTabController(
              length: value.classifiedCategoryList.length,
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
                  actions: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseOwnerDiscover(
                                    AppLocalizations.of(context)
                                        .translate('my_classified'))));
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            AppIcon(
                              Icons.history,
                              iconColor: GlobalVariables.white,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            AppIcon(
                              AppLocalizations.of(context).translate('my_ads'),
                              iconColor: GlobalVariables.white,
                                  iconSize: GlobalVariables.textSizeSMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                  title: text(
                    AppLocalizations.of(context).translate('classified'),
                    textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium,
                  ),
                  bottom: value.classifiedCategoryList.isNotEmpty
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

  getTabLayout(ClassifiedResponse value) {
    return PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: TabBar(
        tabs: value.classifiedCategoryList.map((e) {
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

  getClassifiedLayout(ClassifiedResponse value) {
    ClassifiedResponse _classifiedResponse = ClassifiedResponse();
    for (int i = 0; i < value.classifiedList.length; i++) {
      var category = value
          .classifiedCategoryList[
              _tabController == null ? 0 : _tabController.index]
          .Category_Name;
      print('category : ' + category.toString());
      if (category.toLowerCase() ==
          value.classifiedList[i].Category.toLowerCase()) {
        _classifiedResponse.classifiedList.add(value.classifiedList[i]);
        //print('runtime : '+_classifiedValue.runtimeType.toString());
      }
    }
    var tabName = 'No Data Found For ' +
        value
            .classifiedCategoryList[
                _tabController == null ? 0 : _tabController.index]
            .Category_Name;
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
                _classifiedResponse.classifiedList.isNotEmpty
                    ? getClassifiedListDataLayout(_classifiedResponse)
                    : GlobalFunctions.noDataFoundLayout(context, tabName),
                //addClassifiedDiscoverFabLayout(GlobalVariables.CreateClassifiedListingPage),
              ],
            ),
          ),
        ],
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
                //if (pageTitle == GlobalVariables.CreateClassifiedListingPage) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BaseCreateClassifiedListing(false))).then((value) {
                  GlobalFunctions.setBaseContext(context);
                });
              },
              child: AppIcon(
                Icons.add,
                iconColor: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getClassifiedListDataLayout(ClassifiedResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.classifiedList.length,
                itemBuilder: (context, position) {
                  return getClassifiedListItemLayout(position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getClassifiedListItemLayout(int position, ClassifiedResponse value) {
    var daysCount =
        GlobalFunctions.inDaysCount(value.classifiedList[position].C_Date);
    // print('page : '+_tabController.index.toString());
    List<ClassifiedImage> imageList = List<ClassifiedImage>.from(value
        .classifiedList[position].Images
        .map((i) => ClassifiedImage.fromJson(i)));
    //print('imageList[0].img : ' + imageList[0].img);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseClassifiedListItemDesc(
                    value.classifiedList[position]))).then((value) {
          GlobalFunctions.setBaseContext(context);
        });
      },
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: boxDecoration(radius: 10),
            child: Stack(
              children: <Widget>[
                Container(
                  padding:
                      EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                              //color: GlobalVariables.grey,
                              child:
                                  /*false
                                ? AppAssetsImage(
                              GlobalVariables
                                  .componentUserProfilePath,
                              width / 5.5,
                              width / 6,
                              borderColor: GlobalVariables.grey,
                              borderWidth: 1.0,
                              fit: BoxFit.fill,
                              radius: 12.0,
                              shape: BoxShape.rectangle
                            )
                                : */
                                  imageList.length > 0
                                      ? AppNetworkImage(
                                          imageList[0].Img_Name,
                                          imageWidth: width / 5.5,
                                          imageHeight: width / 5.5,
                                          borderColor: GlobalVariables.grey,
                                          borderWidth: 1.0,
                                          fit: BoxFit.fill,
                                          radius: 12.0,
                                          shape: BoxShape.rectangle,
                                        )
                                      : AppAssetsImage(
                                          GlobalVariables
                                              .componentUserProfilePath,
                                          imageWidth: width / 5.5,
                                          imageHeight: width / 5.5,
                                          borderColor: GlobalVariables.grey,
                                          borderWidth: 1.0,
                                          fit: BoxFit.fill,
                                          radius: 12.0,
                                          shape: BoxShape.circle,
                                        )
                              /*ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
                                width: width / 5.5,
                                height: width / 6,
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),*/
                              ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(value.classifiedList[position].Title,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      maxLine: 2,
                                      textColor: GlobalVariables.green,
                                      fontWeight: FontWeight.w500),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppIcon(
                                        Icons.location_on,
                                        iconSize: 20,
                                        iconColor: GlobalVariables.lightGray,
                                      ),
                                      SizedBox(width: 2),
                                      Flexible(
                                        child: text(
                                            value.classifiedList[position]
                                                    .Locality +
                                                ' - ' +
                                                value.classifiedList[position]
                                                    .City,
                                            textColor:
                                                GlobalVariables.lightGray,
                                            fontSize:
                                                GlobalVariables.textSizeSmall,
                                            maxLine: 2),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: (daysCount + 1) > 7
                                            ? Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(top: 3),
                                                child: AppIcon(
                                                  Icons.date_range,
                                                  iconSize: 15.0,
                                                  iconColor: GlobalVariables.lightGray,
                                                )),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            text(
                                                GlobalFunctions.convertDateFormat(
                                                    value.classifiedList[position]
                                                        .C_Date,
                                                    'dd-MMM-yyyy'),
                                                textColor: GlobalVariables.lightGray,
                                                fontSize:
                                                GlobalVariables.textSizeSmall,
                                                fontWeight: FontWeight.normal),
                                          ],
                                        )
                                            : Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(top: 3),
                                                child: AppIcon(
                                                  Icons.access_time,
                                                  iconSize: 15,
                                                  iconColor: GlobalVariables.lightGray,
                                                )),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            text(
                                                daysCount == 0
                                                    ? 'Today'
                                                    : daysCount == 1
                                                    ? 'Yesterday '
                                                    : daysCount.toString() +
                                                    ' days ago',
                                                textColor: GlobalVariables.lightGray,
                                                fontSize:
                                                GlobalVariables.textSizeSmall,
                                                fontWeight: FontWeight.normal),
                                          ],
                                        ),
                                      ),
                                      value.classifiedList[position].Status.toLowerCase()=='inactive' ?  Container(
                                        child: text(value.classifiedList[position].Status,
                                            fontSize: GlobalVariables.textSizeSmall,
                                            maxLine: 1,
                                            textColor: GlobalVariables.red,
                                            fontWeight: FontWeight.normal),
                                      ): daysCount>30 ?  text('Inactive',
                                          fontSize: GlobalVariables.textSizeSmall,
                                          maxLine: 1,
                                          textColor: GlobalVariables.red,
                                          fontWeight: FontWeight.normal) : SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                      Divider(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: text(
                                'Rs. ' + value.classifiedList[position].Price,
                                textColor: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            child: text(value.classifiedList[position].Type,
                                fontSize: GlobalVariables.textSizeMedium,
                                maxLine: 2,
                                textColor: GlobalVariables.orangeYellow,
                                fontWeight: FontWeight.w500),
                          ),
                          //SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: 4,
                  height: 35,
                  margin: EdgeInsets.only(top: 16),
                  color: position % 2 == 0
                      ? GlobalVariables.grey
                      : GlobalVariables.lightOrange,
                )
              ],
            ),
          )),
    );
  }

  /*getServiceTypeDataLayout() {
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
                                builder: (context) => BaseServicesPerCategory()));
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
  }*/

  getTabBarView(ClassifiedResponse value) {
    return TabBarView(
        controller: _tabController,
        children: value.classifiedCategoryList.map<Widget>((dynamicContent) {
          return getClassifiedLayout(value);
        }).toList());
  }
}
