import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseOwnerClassifiedListItemDesc extends StatefulWidget {

  Classified classifiedList;

  BaseOwnerClassifiedListItemDesc(this.classifiedList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreateClassifiedListingState();
  }
}

class CreateClassifiedListingState
    extends BaseStatefulState<BaseOwnerClassifiedListItemDesc> {
   List<ClassifiedImage> imageList;

  int _current = 0;
  var width,height;

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
        bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            color: GlobalVariables.transparent,
          ),
          padding: EdgeInsets.all(20),
          child: AppButton(textContent: "Interested Customer", onPressed: () {
            showBottomSheet();
          }),
        ),
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
                                  imageUrl: imageList[index].img,
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
                  fontWeight: FontWeight.w500),
              text(widget.classifiedList.Society_Name,
                  fontSize: GlobalVariables.textSizeSMedium,
                  maxLine: 2,
                  textColor: GlobalVariables.grey,
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
                  text(widget.classifiedList.Locality+' - '+widget.classifiedList.City,
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
                    child: text('Rs. '+widget.classifiedList.Price,
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    //padding: EdgeInsets.only(top: 2,bottom: 4,left: 16,right: 16),
                    child: text(widget.classifiedList.Type,
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
                      widget.classifiedList.Description + '\n'+ widget.classifiedList.Property_Details
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

   showBottomSheet(){

     List<Interested> interestedList = List<Interested>.from(widget.classifiedList.Interested
         .map((i) => Interested.fromJson(i)));

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
                   child: Builder(
                       builder: (context) => ListView.builder(
                         // scrollDirection: Axis.vertical,
                         itemCount: interestedList.length,
                         itemBuilder: (context, position) {
                           return Container(
                             padding: EdgeInsets.all(16.0),
                             margin: EdgeInsets.all(8.0),
                             decoration: boxDecoration(radius: 10.0,),
                             child:Row(
                               children: <Widget>[
                                 interestedList[position].Profile_Image.isEmpty
                                     ? Image.asset(
                                   GlobalVariables.componentUserProfilePath,
                                   width: 60,
                                   height: 60,
                                 )
                                     : CircleAvatar(
                                   radius: 30,
                                   backgroundColor: GlobalVariables.mediumGreen,
                                   backgroundImage: NetworkImage(interestedList[position].Profile_Image),
                                 ),
                                 Expanded(
                                   child: Container(
                                     margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                     padding: EdgeInsets.only(left: 8.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                       children: <Widget>[
                                         text(interestedList[position].User_Name,
                                             textColor: GlobalVariables.green,
                                             fontWeight: FontWeight.bold,
                                             fontSize: GlobalVariables.textSizeMedium,
                                             textStyleHeight: 1.0),
                                         SizedBox(height: 2,),
                                         text(interestedList[position].User_Email,
                                             textColor: GlobalVariables.grey,
                                             fontWeight: FontWeight.bold,
                                             fontSize: GlobalVariables.textSizeSmall,
                                             textStyleHeight: 1.0),
                                         SizedBox(height: 3,),
                                         text(interestedList[position].Mobile,
                                             textColor: GlobalVariables.grey,
                                             fontWeight: FontWeight.bold,
                                             fontSize: GlobalVariables.textSizeSmall,
                                             textStyleHeight: 1.0),
                                         SizedBox(height: 3,),
                                         text(interestedList[position].Society_Name,
                                             textColor: GlobalVariables.grey,
                                             fontWeight: FontWeight.bold,
                                             fontSize: GlobalVariables.textSizeSmall,
                                             textStyleHeight: 1.0,maxLine: 2),
                                         SizedBox(height: 3,),
                                         text(interestedList[position].Address,
                                             textColor: GlobalVariables.grey,
                                             fontWeight: FontWeight.bold,
                                             fontSize: GlobalVariables.textSizeSmall,
                                             textStyleHeight: 1.0,maxLine: 5),
                                         //SizedBox(height: 2,),
                                       ],
                                     ),
                                   ),
                                 ),
                                 divider(thickness: 2.0),
                               ],
                             ),
                           );
                         }, //  scrollDirection: Axis.vertical,
                         shrinkWrap: true,
                       )),
                 ),
               )
             ],
           );
         });

   }

}
