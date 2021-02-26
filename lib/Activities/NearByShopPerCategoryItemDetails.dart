import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/utils/AppButton.dart';
import 'package:societyrun/utils/AppWidget.dart';

class NearByShopPerCategoryItemDetails extends StatefulWidget {
  @override
  NearByShopPerCategoryItemDetailsState createState() =>
      NearByShopPerCategoryItemDetailsState();
}

class NearByShopPerCategoryItemDetailsState
    extends State<NearByShopPerCategoryItemDetails> {
  var urlImg =
      "https://iqonic.design/themeforest-images/prokit/images/theme3/t3_dish3.jpg";

  //var urlImg ="https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_dish1.png";
  //var urlImg ="https://iqonic.design/themeforest-images/prokit/images/theme3/t3_ic_profile.jpg";

  var width, height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    GlobalFunctions.changeStatusColor(GlobalVariables.transparent);
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.white,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.green,
            ),
          ),
          title: Text(
            'Items Details',
            style: TextStyle(color: GlobalVariables.green, fontSize: 16),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.lightCyan,
      ),
      child: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                Container(
                  color: GlobalVariables.lightCyan,
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 8,right: 8,top: 8),
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(GlobalVariables.spacing_standard_new),
                              child: Column(
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
                                  Image.asset(
                                    GlobalVariables.sofaIconPath,
                                    width: width,
                                    height: width * 0.6,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(
                                    height: GlobalVariables.spacing_xlarge,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: boxDecoration(radius: 10,bgColor: GlobalVariables.white),
                                    padding: EdgeInsets.all(16),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: Column(
                                            children: [
                                              Container(
                                                //color: GlobalVariables.grey,
                                                padding: EdgeInsets.only(top: 8/*,left: 16*/),
                                                alignment: Alignment.center,
                                                child: text('Super Daily',
                                                    textColor: GlobalVariables.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: GlobalVariables.textSizeLargeMedium,maxLine: 2),
                                              ),
                                              divider(),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: text(
                                                        'Pay 50% less for your daily groceries.(First 5 Orders)',
                                                        textColor:
                                                        GlobalVariables.green,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: GlobalVariables.textSizeMedium,
                                                        maxLine: 4),
                                                  ),
                                                  SizedBox(
                                                    width: 16,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 8),
                                                    child: SvgPicture.asset(
                                                      GlobalVariables.whatsAppIconPath,
                                                      height: 20,
                                                      width: 20,
                                                      color: GlobalVariables.green,
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
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: GlobalVariables.spacing_standard,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: text(
                                                        'Woodsworth is our premium homegrown label thats part classic, part contemporary.',
                                                        textColor: GlobalVariables.grey,
                                                        fontSize: GlobalVariables.textSizeSMedium,
                                                        maxLine: 5),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                      child: Container(
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              size: 24,
                                                              color: GlobalVariables.green,
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Flexible(
                                                                child: text(
                                                                    'Kamala Cross Jwel of Pimpari Pune',
                                                                    fontSize: GlobalVariables.textSizeSMedium,
                                                                    maxLine: 10)),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          transform: Matrix4.translationValues(0.0, -70.0, 0.0),
                                          decoration: BoxDecoration(
                                              color: GlobalVariables.veryLightGray,
                                              border: Border.all(
                                                  color: GlobalVariables
                                                      .green,
                                                  width: 1.0), shape: BoxShape.circle),
                                          child: new CircleAvatar(
                                            backgroundColor: GlobalVariables.lightGray,
                                            child: Container(
                                              //margin: EdgeInsets.only(top: 8),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.only(left: 16,right: 16,top: 16),
                                                child: Image.asset(GlobalVariables
                                                    .superDailyIconPath)
                                            ),
                                            radius: 50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    decoration:
                                    boxDecoration(radius: 10),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: text(
                                            AppLocalizations.of(context)
                                                .translate('offer_details'),
                                            textColor: GlobalVariables.green,
                                            fontWeight: FontWeight.w500,
                                            fontSize: GlobalVariables.textSizeMedium,),
                                          alignment: Alignment.topLeft,
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Builder(
                                            builder: (context) => ListView.builder(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              itemCount: 5,
                                              itemBuilder: (context, position) {
                                                return Container(
                                                  margin:
                                                  EdgeInsets.only(left: 10),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                            EdgeInsets.only(
                                                                top: 8),
                                                            width: 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                GlobalVariables
                                                                    .green,
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Flexible(
                                                              child: Container(
                                                                  child: text(
                                                                      position % 2 ==
                                                                          0
                                                                          ? 'The offer is only applicable on abc.com'
                                                                          : 'You can avail a flat 25% discount on a minimum purchase of INR 999 using this voucher on the website.',
                                                                      fontSize:
                                                                      GlobalVariables.textSizeSMedium,
                                                                      maxLine: 99,
                                                                      textColor:
                                                                      GlobalVariables
                                                                          .grey))),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 32,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              //  scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    decoration:
                                    boxDecoration(radius: 10),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: text(
                                            AppLocalizations.of(context)
                                                .translate('terms_conn'),
                                            textColor: GlobalVariables.green,
                                            fontWeight: FontWeight.w500,
                                            fontSize: GlobalVariables.textSizeMedium,),
                                          alignment: Alignment.topLeft,
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Builder(
                                            builder: (context) => ListView.builder(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              itemCount: 5,
                                              itemBuilder: (context, position) {
                                                return Container(
                                                  margin:
                                                  EdgeInsets.only(left: 10),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                            EdgeInsets.only(
                                                                top: 8),
                                                            width: 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                GlobalVariables
                                                                    .green,
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Flexible(
                                                              child: Container(
                                                                  child: text(
                                                                      position % 2 ==
                                                                          0
                                                                          ? 'The offer is only applicable on abc.com'
                                                                          : 'You can avail a flat 25% discount on a minimum purchase of INR 999 using this voucher on the website.',
                                                                      fontSize:
                                                                      GlobalVariables.textSizeSMedium,
                                                                      maxLine: 99,
                                                                      textColor:
                                                                      GlobalVariables
                                                                          .grey))),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 32,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              //  scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: width,
              margin: EdgeInsets.all(10),
              child: AppButton(textContent: "Get Code", onPressed: () {
                showBottomSheet();
              },textColor: GlobalVariables.white,),
            ),
          ),
        ],
      ),
    );
  }

  showBottomSheet(){

    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 50,
                height: 10,
                decoration: boxDecoration(color: GlobalVariables.transparent, radius: 16, bgColor: GlobalVariables.lightGray),
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: GlobalVariables.white),
                 // height: MediaQuery.of(context).size.width * 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 16,
                        ),
                        text('Pay 50% less for your daily groceries.(First 5 Orders)', fontSize: GlobalVariables.textSizeLargeMedium,textColor: GlobalVariables.green,maxLine: 3,fontWeight: FontWeight.w500,),
                        SizedBox(
                          height: 8,
                        ),
                        longText('lots of ingredient used like paneer, tortilla,onion, tomato, peas,lots of ingredient used like paneer, tortilla,onion, tomato, peas,', islongTxt: true, textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 6,
                              child: DottedBorder(
                                child: Container(
                                  //decoration: boxDecoration(radius: 1.0,color: GlobalVariables.lightGray),
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: text('VDHAR34SDGHFHFY-HFFJ345HFY13DHDBHF',textColor: GlobalVariables.black,fontSize: 14.0,maxLine: 1,fontWeight: FontWeight.w500)),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Icon(Icons.content_copy,color: GlobalVariables.skyBlue,size: 24,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            /*Flexible(
                                flex: 2,
                                child: text('Copy',textColor: GlobalVariables.skyBlue,fontWeight: FontWeight.w500,fontSize: GlobalVariables.textSizeMedium)
                            )*/
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: FlatButton(
                                onPressed: () {
                                },
                                color: GlobalVariables.green,
                                child: text('Redeem',textColor: GlobalVariables.white,fontSize: 14.0,fontWeight: FontWeight.w500)
                            ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        });

  }

  Widget mInfo() {
    return Container(
      margin: EdgeInsets.all(GlobalVariables.spacing_standard_new),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          longText(
              'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ' +
                  'lots of ingredient used like paneer, tortilla,onion, tomato, peas, ',
              textColor: GlobalVariables.grey,
              islongTxt: true,
              fontSize: GlobalVariables.textSizeMedium),
          SizedBox(
            height: GlobalVariables.spacing_standard_new,
          ),
          Divider(
            height: 1,
            color: GlobalVariables.lightGray,
          ),
          SizedBox(
            height: GlobalVariables.spacing_standard_new,
          ),
        ],
      ),
    );
  }
}

