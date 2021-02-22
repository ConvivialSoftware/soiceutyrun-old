import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppWidget.dart';

import 'base_stateful.dart';

class BaseClassifiedListItemDesc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreateClassifiedListingState();
  }
}

class CreateClassifiedListingState
    extends BaseStatefulState<BaseClassifiedListItemDesc> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
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
            AppLocalizations.of(context).translate('create_listing'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
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
                    context, 200.0),
                getCreateClassifiedListingLayout(),
                // deleteProfileFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final List<String> imageList = [
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
  ];

  int _current = 0;



  getCreateClassifiedListingLayout() {

    print('_current : '+_current.toString());
    final List<Widget> imageSliders = imageList.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.network(item, fit: BoxFit.cover, width: 1000.0,height: MediaQuery.of(context).size.width * 0.8),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    /*child: Text(
                      'No. ${imageList.indexOf(item)} image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),*/
                  ),
                ),
              ],
            )
        ),
      ),
    )).toList();
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
        padding: EdgeInsets.all(
            10), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CarouselSlider(
              items: imageSliders,
              options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageList.map((url) {
                int index = imageList.indexOf(url);
                print('index : '+index.toString());
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            text('Resale 1bhk luxurious Flat in jail Road. Nasik Road.',
                fontFamily: GlobalVariables.fontBold,
                fontSize: GlobalVariables.textSizeMedium,
                maxLine: 2,
                textColor: GlobalVariables.green,fontWeight: FontWeight.w500),
            SizedBox(height: 4),
            text('Dasak Gaon, Nashik, Maharashtra',
                textColor: GlobalVariables.lightGray,
                fontSize: GlobalVariables.textSizeSmall,
                maxLine: 2),
            SizedBox(height: 4),
            Container(
              alignment: Alignment.topLeft,
              //padding: EdgeInsets.all(4),
              /*decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius:
                  BorderRadius.all(Radius.circular(8))),*/
              child: text('Rs. 1,00,000',
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  child: text(
                      "Real Estate",
                      fontFamily: GlobalVariables.fontBold,
                      fontSize: GlobalVariables.textSizeMedium,
                      fontWeight: FontWeight.bold,
                      textColor: GlobalVariables.grey
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  //padding: EdgeInsets.only(top: 2,bottom: 4,left: 16,right: 16),
                  child: text(
                      "Rent",
                      fontFamily: GlobalVariables.fontBold,
                      fontSize: GlobalVariables.textSizeMedium,
                      fontWeight: FontWeight.bold,
                      textColor: GlobalVariables.grey
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            text('Description',
                textColor: GlobalVariables.green,
                fontSize: GlobalVariables.textSizeLargeMedium,
                fontFamily: GlobalVariables.fontMedium,
            fontWeight: FontWeight.w500),
            SizedBox(height: 8),
            Container(
                margin: EdgeInsets.only(left: 16),
                child: longText(
                    '1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..',
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium,
                    islongTxt: true)),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
