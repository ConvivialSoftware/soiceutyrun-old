import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/ClassifiedListItemDesc.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/Activities/OwnerServices.dart';
import 'package:societyrun/Activities/ServicesPerCategory.dart';
import 'package:societyrun/Activities/NearByShopPerCategory.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';

class BaseFindServices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DiscoverState();
  }
}

class DiscoverState extends BaseStatefulState<BaseFindServices> {
  var width, height;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 4, vsync: this);
    Provider.of<ServicesResponse>(context,listen: false).getServicesCategory();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return ChangeNotifierProvider<ServicesResponse>.value(
        value: Provider.of<ServicesResponse>(context),
        child: Consumer<ServicesResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.servicesCategoryList.toString());
            return Builder(
              builder: (context) => Scaffold(
                backgroundColor: GlobalVariables.veryLightGray,
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
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseOwnerServices()));
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            AppIcon(
                              Icons.history,
                              iconColor: GlobalVariables.white,
                            ),
                            SizedBox(width: 4,),
                            text(
                              AppLocalizations.of(context).translate('history'),
                              textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeSMedium,
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                  title: text(
                    AppLocalizations.of(context).translate('find_services'),
                    textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium,
                  ),
                  //bottom: getTabLayout(),
                  //elevation: 0,
                ),
                body: value.isLoading ? GlobalFunctions.loadingWidget(context):getServiceLayout(value),
              ),
            );
          },
        ));
  }

  getServiceLayout(ServicesResponse value) {
    print('getClassifiedLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        getServiceTypeDataLayout(value),
      ],
    );
  }

  getServiceTypeDataLayout(ServicesResponse value) {

    return Container(
      margin: EdgeInsets.all(16), //color: GlobalVariables.black,
      child: Container(
          child: Builder(
              builder: (context) =>

                  /*GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: value.servicesCategoryList.length,
                    itemBuilder: (context, position) {
                      print('image : '+value.servicesCategoryList[position].image);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseServicesPerCategory(value.servicesCategoryList[position].Category_Name)));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          //width: width / 4,
                         // height: width / 4,
                          margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: GlobalVariables.white,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(5),
                           // margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  //color: GlobalVariables.lightGray,
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: AppNetworkImage(
                                    value.servicesCategoryList[position].image,
                                    imageWidth:35.0,
                                    imageHeight:35.0,
                                    borderColor: GlobalVariables.grey,
                                    borderWidth: 1.0,
                                    radius: 0.0,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.fromLTRB(2, 5, 2, 4),
                                      child: text(value.servicesCategoryList[position].Category_Name,fontSize: GlobalVariables.textSizeSMedium,maxLine: 2)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, //  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  )*/
            GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: value.servicesCategoryList.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                //setStatusBarColor(Banking_app_Background);
                return InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BaseServicesPerCategory(value.servicesCategoryList[index].Category_Name)));
                  },
                  child: Container(
                   // margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
                    //padding: EdgeInsets.all(6),
                    decoration: boxDecoration(
                       // backgroundColor: Banking_whitePureColor,
                        //boxShadow: defaultBoxShadow(),
                        radius: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AppNetworkImage(
                          value.servicesCategoryList[index].image,
                          imageWidth:30.0,
                          imageHeight:30.0,
                          borderColor: GlobalVariables.grey,
                          borderWidth: 1.0,
                          radius: 0.0,
                        ),
                        SizedBox(height: 8,),
                        text(value.servicesCategoryList[index].Category_Name,
                            fontSize: GlobalVariables.textSizeSmall,
                            isCentered: true,
                            //textAlign: TextAlign.center,
                            maxLine: 2),
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12),
            ),
          )
          ),
    );
  }
}
