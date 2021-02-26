import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppButton.dart';
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
  final List<String> imageList = [
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_dish2.jpg",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_pizza_dialog.png",
    "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_dish1.png",
  ];

  int _current = 0;
  var width,height;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height =  MediaQuery.of(context).size.height;
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
            style: TextStyle(color: GlobalVariables.white, fontSize: 16),
          ),
        ),
        body: getBaseLayout(),
        /*bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            color: GlobalVariables.transparent,
          ),
          padding: EdgeInsets.all(20),
          child: AppButton(textContent: "I'm Interested", onPressed: () {}),
        ),*/
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: width,
                margin: EdgeInsets.all(10),
                child: AppButton(textContent: "I'm Interested", onPressed: () {},textColor: GlobalVariables.white,)),
          ),
        ],
      ),
    );
  }

  getCreateClassifiedListingLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 30, 10, 10),
        padding: EdgeInsets.all(8),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CarouselSlider.builder(
                itemCount: imageList.length,
                options: CarouselOptions(
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
                itemBuilder: (context, index) {
                  return Container(
                      margin: EdgeInsets.all(5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Stack(
                            children: <Widget>[
                              CachedNetworkImage(
                                  imageUrl: imageList[index],
                                  fit: BoxFit.cover,
                                  width: 1000.0,
                                  height:
                                      MediaQuery.of(context).size.width * 0.8),
                            ],
                          )));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageList.map((url) {
                  int index = imageList.indexOf(url);
                  print('_current : ' + _current.toString());
                  print('index : ' + index.toString());
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
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
                  fontSize: GlobalVariables.textSizeMedium,
                  maxLine: 2,
                  textColor: GlobalVariables.green,
                  fontWeight: FontWeight.w500),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: GlobalVariables.lightGray,
                  ),
                  text('Dasak Gaon, Nashik, Maharashtra',
                      textColor: GlobalVariables.lightGray,
                      fontSize: GlobalVariables.textSizeSmall,
                      maxLine: 2),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    //padding: EdgeInsets.all(4),
                    /*decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius:
                        BorderRadius.all(Radius.circular(8))),*/
                    child: text('Rs. 1,00,000',
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    //padding: EdgeInsets.only(top: 2,bottom: 4,left: 16,right: 16),
                    child: text("Rent",
                        fontSize: GlobalVariables.textSizeSMedium,
                        fontWeight: FontWeight.bold,
                        textColor: GlobalVariables.orangeYellow),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: GlobalVariables.lightGray,
              ),
              SizedBox(height: 4),
              text('Description',
                  textColor: GlobalVariables.green,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.w500),
              SizedBox(height: 8),
              Container(
                  //margin: EdgeInsets.only(left: 8),
                  child: longText(
                      '1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..' +
                          '1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                      /*+'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                      +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                      +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                      +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'*/
                      ,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeSMedium,
                      islongTxt: true)),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: GlobalVariables.lightGray,
              ),
              SizedBox(height: 4),
              text('Details',
                  textColor: GlobalVariables.green,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.w500),
              SizedBox(height: 4),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text('Posted',
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.grey),
                          text('24-03-2021',
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.grey)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text('Posted By',
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.grey),
                          text('Poonam Suthar',
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.grey)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}