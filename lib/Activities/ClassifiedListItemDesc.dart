import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ClassifiedResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:intl/intl.dart';
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
    extends State<BaseClassifiedListItemDesc> {
  List<ClassifiedImage>? imageList;

  int _current = 0;
  var width,height;
  ProgressDialog? _progressDialog;

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    imageList = List<ClassifiedImage>.from(
        widget.classifiedList.Images.map((i) => ClassifiedImage.fromJson(i)));
    print('imageList : ' + imageList!.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height =  MediaQuery.of(context).size.height;
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: 'Classified Details',
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
    return Column(
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
              margin: EdgeInsets.all(16),
              child: AppButton(textContent: "I'm Interested", onPressed: () {
                  _progressDialog!.show();
                  Provider.of<ClassifiedResponse>(context, listen: false)
                      .interestedClassified(widget.classifiedList.id!)
                      .then((value) {
                  print('then value : '+value.toString());
                    _progressDialog!.dismiss();
                    GlobalFunctions.showToast(value.message!);
                  return showDialog(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
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
                });

              },textColor: GlobalVariables.white,)),
        ),
      ],
    );
  }

  getCreateClassifiedListingLayout() {
   // print('Address : '+widget.classifiedList.Address+','+widget.classifiedList.Locality+' - '+widget.classifiedList.City+(widget.classifiedList.Address.toString().trim().contains(widget.classifiedList.PinCode.toString().trim()) ? '': ' '));
    return SingleChildScrollView(
      child: AppContainer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CarouselSlider.builder(
              itemCount: imageList!.length,
              options: CarouselOptions(
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              itemBuilder: (context, index,item) {
                return Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: Stack(
                          children: <Widget>[
                            CachedNetworkImage(
                                imageUrl: imageList![index].Img_Name!,
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
              children: imageList!.map((url) {
                int index = imageList!.indexOf(url);
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
            primaryText(widget.classifiedList.Title,),
            //SizedBox(height: 2),
            secondaryText(widget.classifiedList.Society_Name,),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon(
                  Icons.location_on,
                  iconSize: GlobalVariables.textSizeNormal,
                  iconColor: GlobalVariables.grey,
                ),
                SizedBox(width: 4,),
                Flexible(
                  child: text(
                      widget.classifiedList.Address! +
                          ', ' +
                          widget.classifiedList.Locality! +
                          ', ' +
                          widget.classifiedList.City! +
                          ', ' +
                          widget.classifiedList.Pincode!,
                      /*widget.classifiedList.Address.toString().trim().contains(widget.classifiedList.PinCode.toString().trim()) ? '':widget.classifiedList.Pincode.toString())*/
                      textColor: GlobalVariables.grey,
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
                  child: text(
                      /*'Rs. '+NumberFormat.currency(locale: 'HI',symbol: '',decimalDigits: 2).format(double.parse(widget.classifiedList.Price))*/
                      GlobalFunctions.getCurrencyFormat(
                          widget.classifiedList.Price!),
                      textColor: GlobalVariables.black,
                      fontSize: GlobalVariables.textSizeNormal,
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      color: GlobalVariables.orangeYellow,
                      borderRadius: BorderRadius.circular(5)),
                  child: text(widget.classifiedList.Type,
                      fontSize: GlobalVariables.textSizeSmall,
                      fontWeight: FontWeight.bold,
                      textColor: GlobalVariables.white),
                ),
              ],
            ),
            //SizedBox(height: 4),
            Divider(),
            //SizedBox(height: 4),
            primaryText('Description',
                textColor: GlobalVariables.primaryColor,),
            SizedBox(height: 8),
            Container(
                //margin: EdgeInsets.only(left: 8),
                child: secondaryText(
                    widget.classifiedList.Description
                    /*+'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                    +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                    +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'
                    +'1BHK luxurious flat in jail Road. Dasak stop. Walking distance from highway. Nice location..'*/
                    ,
                    )),
           // SizedBox(height: 8),
           Divider(),
           // SizedBox(height: 4),
            primaryText('Details',),
            SizedBox(height: 4),
            Container(
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        secondaryText('Posted',),
                        secondaryText(
                          GlobalFunctions.convertDateFormat(
                              widget.classifiedList.C_Date!, 'dd-MM-yyyy'),
                        )
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
                        secondaryText('Posted By',),
                        secondaryText(widget.classifiedList.Name,)
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
    );
  }
}
