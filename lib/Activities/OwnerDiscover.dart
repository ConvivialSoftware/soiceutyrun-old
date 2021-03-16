//import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/OwnerClassifiedListItemDesc.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';

class BaseOwnerDiscover extends StatefulWidget {
  String pageName;

  BaseOwnerDiscover(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OwnerDiscoverState(pageName);
  }
}

//TickerProviderStateMixi
class OwnerDiscoverState extends BaseStatefulState<BaseOwnerDiscover> {
  //TabController _tabController;
  String pageName;
  var width, height;

  OwnerDiscoverState(this.pageName);

  // ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    print('initState Call');
    Provider.of<OwnerClassifiedResponse>(context, listen: false)
        .getOwnerClassifiedData()
        .then((tabLength) {
          setState(() {
            
          });
     /* print('tablength : ' + tabLength.toString());
      _tabController = TabController(length: int.parse(tabLength), vsync: this);
      _tabController.addListener(() {
        print('_tabController.index : ' + _tabController.index.toString());
        // _handleSelection(_tabController.index);
        setState(() {});
      });*/
    });
  }

  @override
  Widget build(BuildContext context) {
    //   _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return ChangeNotifierProvider<OwnerClassifiedResponse>.value(
        value: Provider.of<OwnerClassifiedResponse>(context),
        child: Consumer<OwnerClassifiedResponse>(
          builder: (context, value, child) {
            print(
                'Consumer Value : ' + value.ownerClassifiedCategoryList.toString());
            return DefaultTabController(
              length: value.ownerClassifiedCategoryList.length,
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
                    AppLocalizations.of(context).translate('my_classified'),
                    style:
                        TextStyle(color: GlobalVariables.white, fontSize: 16),
                  ),
                  /*bottom: value.ownerClassifiedCategoryList.isNotEmpty
                      ? getTabLayout(value)
                      : PreferredSize(
                          preferredSize: Size.fromHeight(0.0),
                          child: Container(),
                        ),*/
                  elevation: 0,
                ),
                body:
                    /*value.ownerClassifiedCategoryList.isNotEmpty && */!value.isLoading
                        ? getOwnerClassifiedLayout(value)
                        : GlobalFunctions.loadingWidget(context),
              ),
            );
          },
        ));
  }

  /*getTabLayout(OwnerClassifiedResponse value) {
    return PreferredSize(
      preferredSize: Size.fromHeight(30.0),
      child: TabBar(
        tabs: value.ownerClassifiedCategoryList.map((e) {
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
  }*/

  getOwnerClassifiedLayout(OwnerClassifiedResponse value) {
    /*OwnerClassifiedResponse _OwnerClassifiedResponse = OwnerClassifiedResponse();
    for (int i = 0; i < value.ownerClassifiedList.length; i++) {
      var category = value
          .ownerClassifiedCategoryList[
              _tabController == null ? 0 : _tabController.index]
          .Category_Name;
      print('category : ' + category.toString());
      if (category.toLowerCase() ==
          value.ownerClassifiedList[i].Category.toLowerCase()) {
        _OwnerClassifiedResponse.ownerClassifiedList.add(value.ownerClassifiedList[i]);
        //print('runtime : '+_classifiedValue.runtimeType.toString());
      }
    }
    print('getClassifiedLayout Tab Call');*/
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
                value.ownerClassifiedList.isNotEmpty
                    ? getOwnerClassifiedListDataLayout(value)
                    : GlobalFunctions.noDataFoundLayout(context,'No Data Found'),
                addClassifiedOwnerDiscoverFabLayout(
                    GlobalVariables.CreateClassifiedListingPage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addClassifiedOwnerDiscoverFabLayout(String pageTitle) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
                //if (pageTitle == GlobalVariables.CreateownerClassifiedListingPage) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BaseCreateClassifiedListing())).then((value) {
                  GlobalFunctions.setBaseContext(context);
                });

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

  getOwnerClassifiedListDataLayout(OwnerClassifiedResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin:
          EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 15, 0, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: value.ownerClassifiedList.length,
                itemBuilder: (context, position) {
                  return getOwnerClassifiedListItemLayout(position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getOwnerClassifiedListItemLayout(int position, OwnerClassifiedResponse value) {
    var daysCount =
        GlobalFunctions.inDaysCount(value.ownerClassifiedList[position].C_Date);
    // print('page : '+_tabController.index.toString());
    List<ClassifiedImage> imageList = List<ClassifiedImage>.from(value
        .ownerClassifiedList[position].Images
        .map((i) => ClassifiedImage.fromJson(i)));
    //print('imageList[0].img : ' + imageList[0].img);
    return InkWell(
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BaseOwnerClassifiedListItemDesc(value.ownerClassifiedList[position])))
            .then((value) {
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
                              imageList.length>0 ? AppNetworkImage(
                            imageList[0].img,
                            imageWidth: width / 5.5,
                            imageHeight: width / 5.5,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.fill,
                            radius: 12.0,
                            shape: BoxShape.rectangle,
                          ) : AppAssetsImage(
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
                                  text(value.ownerClassifiedList[position].Title,
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
                                      Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: GlobalVariables.lightGray,
                                      ),
                                      SizedBox(width: 2),
                                      Flexible(
                                        child: text(
                                            value.ownerClassifiedList[position]
                                                .Locality+' - '+value.ownerClassifiedList[position]
                                                .City,
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
                            child: text(
                                'Rs. ' + value.ownerClassifiedList[position].Price,
                                textColor: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            child: (daysCount + 1) > 7
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Icon(
                                            Icons.date_range,
                                            size: 15,
                                            color: Colors.grey,
                                          )),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      text(
                                          GlobalFunctions.convertDateFormat(
                                              value.ownerClassifiedList[position]
                                                  .C_Date,
                                              'dd-MMM-yyyy'),
                                          textColor: GlobalVariables.grey,
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
                                          child: Icon(
                                            Icons.access_time,
                                            size: 15,
                                            color: Colors.grey,
                                          )),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      text(daysCount==0 ? 'Today' : daysCount==1 ? 'Yesterday ': daysCount.toString() + ' days ago',
                                          textColor: GlobalVariables.grey,
                                          fontSize:
                                              GlobalVariables.textSizeSmall,
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
                  color: position % 2 == 0
                      ? GlobalVariables.grey
                      : GlobalVariables.lightOrange,
                )
              ],
            ),
          )),
    );
  }

 /* getTabBarView(OwnerClassifiedResponse value) {
    return TabBarView(
        controller: _tabController,
        children: value.ownerClassifiedCategoryList.map<Widget>((dynamicContent) {
          return getClassifiedLayout(value);
        }).toList());
  }*/
}
