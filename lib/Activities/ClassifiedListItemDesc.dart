import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ClassifiedResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseClassifiedListItemDesc extends StatefulWidget {

  Classified classifiedList;

  BaseClassifiedListItemDesc(this.classifiedList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreateClassifiedListingState();
  }
}

class CreateClassifiedListingState
    extends BaseStatefulState<BaseClassifiedListItemDesc> {
   List<ClassifiedImage> imageList;

  int _current = 0;
  var width,height;
   ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    imageList = List<ClassifiedImage>.from(widget.classifiedList.Images
        .map((i) => ClassifiedImage.fromJson(i)));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height =  MediaQuery.of(context).size.height;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
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
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          title: text(
            'Classified Details',
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium,
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
                child: AppButton(textContent: "I'm Interested", onPressed: () {

                  _progressDialog.show();
                  Provider.of<ClassifiedResponse>(context,listen: false).interestedClassified(widget.classifiedList.id).then((value) {
                    print('then value : '+value.toString());
                    _progressDialog.hide();
                    return showDialog(
                        context: context,
                        builder: (BuildContext context) => StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  color: GlobalVariables.transparent,
                                  // width: MediaQuery.of(context).size.width/3,
                                  // height: MediaQuery.of(context).size.height/4,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        child: /*SvgPicture.asset(
                                          GlobalVariables.successIconPath,
                                          width: 50,
                                          height: 50,
                                        ),*/AppAssetsImage(GlobalVariables.successIconPath,imageWidth: 50.0,imageHeight: 50.0,)
                                      ),
                                      /*Container(
                                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                          child: Text(AppLocalizations.of(context)
                                              .translate('successful_payment'))),*/
                                      Container(
                                        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                        child: text(value.message,fontSize: GlobalVariables.textSizeSMedium,textColor: GlobalVariables.black,fontWeight: FontWeight.w500,maxLine: 99),
                                      ),
                                      /*Container(
                                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: Text(AppLocalizations.of(context)
                                              .translate('thank_you_payment'))),*/
                                    ],
                                  ),
                                ),
                              );
                            }));
                    GlobalFunctions.showToast(value.message);
                  });

                },textColor: GlobalVariables.white,)),
          ),
        ],
      ),
    );
  }

  getCreateClassifiedListingLayout() {
    print('Address : '+widget.classifiedList.Address+','+widget.classifiedList.Locality+' - '+widget.classifiedList.City+(widget.classifiedList.Address.toString().trim().contains(widget.classifiedList.PinCode.toString().trim()) ? '': ' '));
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
                                  imageUrl: imageList[index].Img_Name,
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
                  //print('_current : ' + _current.toString());
                  //('index : ' + index.toString());
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
              text(widget.classifiedList.Title,
                  fontSize: GlobalVariables.textSizeMedium,
                  maxLine: 2,
                  textColor: GlobalVariables.green,
                  fontWeight: FontWeight.bold),
              //SizedBox(height: 2),
              text(widget.classifiedList.Society_Name,
                  fontSize: GlobalVariables.textSizeSMedium,
                  maxLine: 2,
                  textColor: GlobalVariables.grey,
                  fontWeight: FontWeight.w500),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon(
                    Icons.location_on,
                    iconSize: GlobalVariables.textSizeNormal,
                    iconColor: GlobalVariables.lightGray,
                  ),
                  SizedBox(width: 4,),
                  Flexible(
                    child: text(widget.classifiedList.Address+', '+widget.classifiedList.Locality+', '+widget.classifiedList.City+', '+widget.classifiedList.Pincode,
                        /*widget.classifiedList.Address.toString().trim().contains(widget.classifiedList.PinCode.toString().trim()) ? '':widget.classifiedList.Pincode.toString())*/
                        textColor: GlobalVariables.lightGray,
                        fontSize: GlobalVariables.textSizeSmall,
                        maxLine: 4),
                  ),
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
                    child: text('Rs. '+widget.classifiedList.Price,
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    //padding: EdgeInsets.only(top: 2,bottom: 4,left: 16,right: 16),
                    child: text(widget.classifiedList.Type,
                        fontSize: GlobalVariables.textSizeSmall,
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
                      widget.classifiedList.Description
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
                          text(GlobalFunctions.convertDateFormat(widget.classifiedList.C_Date, 'dd-MM-yyyy'),
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
                          text(widget.classifiedList.Name,
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
