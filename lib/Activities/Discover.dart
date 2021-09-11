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
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';
import 'package:intl/intl.dart';

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
class DiscoverState extends State<BaseDiscover>
    with SingleTickerProviderStateMixin ,AfterLayoutMixin<BaseDiscover> {
  TabController _tabController;
  String pageName,societyId;
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
    getSharedPreferenceData();
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
                backgroundColor: GlobalVariables.veryLightGray,
                appBar: AppBar(
                  backgroundColor: GlobalVariables.primaryColor,
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
                        margin: EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            AppIcon(
                              Icons.history,
                              iconColor: GlobalVariables.white,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            text(
                              AppLocalizations.of(context).translate('my_ads'),textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeSmall)
                             // iconColor: GlobalVariables.white,
                               //   iconSize: GlobalVariables.textSizeSMedium),
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
      //print('category : ' + category.toString());
      if (category.toLowerCase() ==
          value.classifiedList[i].Category.toLowerCase()) {
        _classifiedResponse.classifiedList.add(value.classifiedList[i]);
        //print('runtime : '+_classifiedValue.runtimeType.toString());
      }
    }

    for(int j=0;j<_classifiedResponse.classifiedList.length;j++){
      for(int k=0;k<value.filterOptionList.length;k++){
        if(value.filterOptionList[k].isSelected){

          if(value.filterOptionList[k].filterName=='All Location'){
            //Nothing to Do
          }/*else if(value.filterOptionList[k].filterName=='My Society'){
            _classifiedResponse.classifiedList.removeWhere((item) =>
            item.SOCIETY_ID != societyId);
          }*/else {
            _classifiedResponse.classifiedList.removeWhere((item) =>
            item.City != value.filterOptionList[k].filterName);
          }
        }
      }
    }

    var tabName = 'No Data Found For ' +
        value
            .classifiedCategoryList[
                _tabController == null ? 0 : _tabController.index]
            .Category_Name;
    print('getClassifiedLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        getClassifiedListDataLayout(_classifiedResponse,value,tabName)
           //
        //addClassifiedDiscoverFabLayout(GlobalVariables.CreateClassifiedListingPage),
      ],
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
              backgroundColor: GlobalVariables.primaryColor,
            ),
          )
        ],
      ),
    );
  }

  getClassifiedListDataLayout(ClassifiedResponse value, ClassifiedResponse providerValue, String tabName) {
    print('value.filterOptionList : '+providerValue.filterOptionList.toString());
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 60,
          margin: EdgeInsets.only(top: 16.0),
          child: ListView.builder(
            itemCount: providerValue.filterOptionList.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context,position){
            return InkWell(
              onTap: (){
                for(int i=0;i<providerValue.filterOptionList.length;i++){
                  if(i==position){
                    providerValue.filterOptionList[i].isSelected =true;
                  }else{
                    providerValue.filterOptionList[i].isSelected =false;
                  }
                 // print(providerValue.filterOptionList[i].filterName);
                  //print(providerValue.filterOptionList[i].isSelected.toString());
                }
                setState(() {
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                decoration: boxDecoration(
                  radius: 5,
                  color: GlobalVariables.white,
                ),
                child: text(
                    providerValue.filterOptionList[position].filterName,
                    textColor: providerValue.filterOptionList[position].isSelected ? GlobalVariables.primaryColor : GlobalVariables.black,
                    isCentered: true
                ),

              ),
            );
          })
        ),
        value.classifiedList.isNotEmpty
            ?   Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 8.0),
            child: Builder(
                builder: (context) => ListView.builder(
                      //scrollDirection: Axis.vertical,
                      itemCount: value.classifiedList.length,
                      itemBuilder: (context, position) {
                        return getClassifiedListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ) : Container(
          margin: EdgeInsets.only(top: height/4),
          child: GlobalFunctions.noDataFoundLayout(context, tabName),
        ),
      ],
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
      child: AppContainer(
        isListItem: true,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child:
                            imageList.length > 0
                                ? AppNetworkImage(
                                    imageList[0].Img_Name,
                                    imageWidth: 70.0,
                                    imageHeight: 70.0,
                                    borderColor: GlobalVariables.grey,
                                    borderWidth: 1.0,
                                    fit: BoxFit.fill,
                                    radius: 35.0,
                                  )
                                : AppAssetsImage(
                                    GlobalVariables
                                        .componentUserProfilePath,
                                    imageWidth: 70.0,
                                    imageHeight: 70.0,
                                    borderColor: GlobalVariables.grey,
                                    borderWidth: 1.0,
                                    fit: BoxFit.fill,
                                    radius: 35.0,
                                  )
                        ),
                    SizedBox(width: 16,),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            primaryText(value.classifiedList[position].Title,),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AppIcon(
                                  Icons.location_on,
                                  iconColor: GlobalVariables.grey,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: text(
                                      value.classifiedList[position]
                                              .Locality +
                                          ' - ' +
                                          value.classifiedList[position]
                                              .City,fontSize: GlobalVariables.textSizeSmall,
                                  textStyleHeight: 1.0,
                                  textColor: GlobalVariables.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 4,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: (daysCount + 1) > 7
                                      ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: AppIcon(
                                            Icons.date_range,
                                            iconColor: GlobalVariables.grey,
                                          )),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      text(
                                          GlobalFunctions.convertDateFormat(
                                              value.classifiedList[position]
                                                  .C_Date,
                                              'dd-MMM-yyyy'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSmall,),
                                    ],
                                  )
                                      : Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: AppIcon(
                                            Icons.access_time,
                                            iconColor: GlobalVariables.grey,
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
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSmall,),
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
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      //NumberFormat.currency(locale: 'IN').format(
                      child: text(
                          GlobalFunctions.getCurrencyFormat(value.classifiedList[position].Price),
                          textColor: GlobalVariables.black,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            color: getClassifiedTypeColor(value.classifiedList[position].Type),
                            borderRadius: BorderRadius.circular(5)),
                      child: text(value.classifiedList[position].Type,
                          fontSize: GlobalVariables.textSizeSmall,
                          textColor: GlobalVariables.white,),
                    ),
                    //SizedBox(width: 10),
                  ],
                )
              ],
            ),
     /*       Container(
              width: 4,
              height: 35,
              margin: EdgeInsets.only(top: 16),
              color: position % 2 == 0
                  ? GlobalVariables.grey
                  : GlobalVariables.lightOrange,
            )*/
          ],
        ),
      ),
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

  getClassifiedTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case "buy":
        return GlobalVariables.skyBlue;
        break;
      case "rent":
        return GlobalVariables.orangeYellow;
        break;
      case "sell":
        return GlobalVariables.primaryColor;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  Future<void> getSharedPreferenceData() async {
    societyId = await GlobalFunctions.getSocietyId();
  }
}
