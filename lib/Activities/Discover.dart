import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/ListOfHomeService.dart';
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
    with TickerProviderStateMixin,AfterLayoutMixin<BaseDiscover> {
  TabController _tabController;
  String pageName;
  var width, height;

  DiscoverState(this.pageName);
  List<ClassifiedResponse> _selectedCategoryData = List<ClassifiedResponse>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
   /* if (pageName != null) {
      redirectToPage(pageName);
    }
*/
    // TODO: implement build
    return  ChangeNotifierProvider<ClassifiedResponse>.value(
        value : Provider.of<ClassifiedResponse>(context),
        child: Consumer<ClassifiedResponse>(
          builder: (context, value, child) {
            print('Consumer Value : '+ value.classifiedCategoryList.toString());
            _tabController = TabController(length: value.classifiedCategoryList.length, vsync: this);
            _tabController.addListener((){
              _handleSelection(_tabController.index,value);
            });
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
                    child: Icon(
                      Icons.arrow_back,
                      color: GlobalVariables.white,
                    ),
                  ),
                  title: Text(
                    AppLocalizations.of(context).translate('discover'),
                    style: TextStyle(color: GlobalVariables.white, fontSize: 16),
                  ),
                  bottom:  value.classifiedCategoryList.isNotEmpty ? getTabLayout(value):PreferredSize(preferredSize: Size.fromHeight(0.0),child: Container(),),
                  elevation: 0,
                ),
                body:  value.classifiedCategoryList.isNotEmpty ? getTabBarView(value):Center(child: CircularProgressIndicator(backgroundColor: GlobalVariables.grey,)),
              ),
            );
          },
        ));
  }

  /*Scaffold(
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
              style: TextStyle(color: GlobalVariables.white, fontSize: 16),
            ),
            bottom: getTabLayout(),
            elevation: 0,
          ),
          body: getTabBarView(),
        ),*/

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
        }).toList(),/*[
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: 'All Things',
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: 'Home',
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: 'Vehicle',
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: 'Furniture',
            ),
          ),
          *//* Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('near_by_shop'),
            ),
          )*//*
        ],*/
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

    //ClassifiedResponse _classifiedValue;
    List<Classified> _classifiedValue=List<Classified>();
    for(int i=0;i<value.classifiedList.length;i++)
    {
      var category = value.classifiedCategoryList[_tabController.index].Category_Name;
      if(category.toLowerCase()==value.classifiedList[i].Category.toLowerCase()){
         _classifiedValue.add(value.classifiedList[i]);
         //print('runtime : '+_classifiedValue.runtimeType.toString());
      }
    }
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
                getClassifiedListDataLayout(_classifiedValue),
                addClassifiedDiscoverFabLayout(
                    GlobalVariables.CreateClassifiedListingPage),
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
                        builder: (context) => BaseCreateClassifiedListing()));
                /*} else if (pageTitle == GlobalVariables.AddNearByShopPage) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseAddNearByShop()));
                }*/
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

  getClassifiedListDataLayout(List<Classified> value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.length,
                itemBuilder: (context, position) {
                  return getClassifiedListItemLayout(position,value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getClassifiedListItemLayout(int position, List<Classified> value) {

    var daysCount = GlobalFunctions.inDaysCount(value[position].C_Date);
    print('page : '+_tabController.index.toString());

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseClassifiedListItemDesc()));
      },
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: boxDecoration(radius: 10),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            //color: GlobalVariables.grey,
                            child: /*false
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
                                : */AppNetworkImage(
                              "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
                              imageWidth:width / 5.5,
                              imageHeight:width / 6,
                              borderColor: GlobalVariables.grey,
                              borderWidth: 1.0,
                              fit: BoxFit.cover,
                              radius: 12.0,
                              shape: BoxShape.rectangle,
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
                                  text(value[position].Title,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      maxLine: 2,
                                      textColor: GlobalVariables.green,fontWeight: FontWeight.w500),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: GlobalVariables.lightGray,
                                      ),
                                      SizedBox(width: 2),
                                      Flexible(
                                        child: text(value[position].Locality,
                                            textColor:
                                            GlobalVariables.lightGray,
                                            fontSize:
                                            GlobalVariables.textSizeSmall,
                                            maxLine: 2),
                                      ),
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
                            child: text('Rs. '+value[position].Price,
                                textColor: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            child: (daysCount+1)>7 ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.date_range,
                                      size: 15,
                                      color: Colors.grey,
                                    )),
                                SizedBox(
                                  width: 4,
                                ),
                                text(GlobalFunctions.convertDateFormat(value[position].C_Date, 'dd-MMM-yyyy'),
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    fontWeight: FontWeight.normal),
                              ],
                            ) : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.access_time,
                                      size: 15,
                                      color: Colors.grey,
                                    )),
                                SizedBox(
                                  width: 4,
                                ),
                                text(daysCount.toString()+' days ago',
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeSmall,
                                    fontWeight: FontWeight.normal),
                              ],
                            ),
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
                  color: position % 2 == 0 ? GlobalVariables.grey : GlobalVariables.lightOrange,
                )
              ],
            ),
          )),
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

  getTabBarView(ClassifiedResponse value) {

    return  TabBarView(controller: _tabController,children: value.classifiedCategoryList.map<Widget>((dynamicContent) {
      return getClassifiedLayout(value);
    }).toList());


  }
  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
    Provider.of<ClassifiedResponse>(context,listen: false).getClassifiedData();
  }

  void _handleSelection(int index, ClassifiedResponse value) {
    print('_tabController.index : '+index.toString());

  }
}
