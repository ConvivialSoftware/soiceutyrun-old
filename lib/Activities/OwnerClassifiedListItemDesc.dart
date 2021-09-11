import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_switch/flutter_custom_switch.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/CreateClassifiedListing.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/OwnerClassifiedResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
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
    extends State<BaseOwnerClassifiedListItemDesc> {
  List<ClassifiedImage> imageList;
  List<Interested> interestedList;

  int _current = 0;
  int inDaysCount = 0;
  var width, height;
  bool isActivationClassified = false;

  ProgressDialog _progressDialog;
  bool isMenuEnable=true;

  @override
  void initState() {
    super.initState();
    imageList = List<ClassifiedImage>.from(
        widget.classifiedList.Images.map((i) => ClassifiedImage.fromJson(i)));
    interestedList = List<Interested>.from(
        widget.classifiedList.Interested.map((i) => Interested.fromJson(i)));
    inDaysCount = GlobalFunctions.getDaysFromDate(
        DateTime.now().toIso8601String(), widget.classifiedList.C_Date);
    print('DaysCount : ' + inDaysCount.toString());

    if (widget.classifiedList.Status
        .toLowerCase()
        .trim() ==
        'active'){
      isMenuEnable=true;
    }else if (widget.classifiedList.Status
        .toLowerCase()
    .trim() ==
    'active' &&
    inDaysCount < 30){
      isMenuEnable=true;
    }else if (inDaysCount > 30){
      isMenuEnable=true;
    }else{
      isMenuEnable=false;
    }

  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<OwnerClassifiedResponse>.value(
        value: Provider.of<OwnerClassifiedResponse>(context),
        child: Consumer<OwnerClassifiedResponse>(
          builder: (context, value, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: GlobalVariables.primaryColor,
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
                actions: [
                  PopupMenuButton(
                      icon: AppIcon(Icons.more_vert, iconColor: isMenuEnable ? GlobalVariables.white : GlobalVariables.transparent),
                      // add this line
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                            if (widget.classifiedList.Status
                                    .toLowerCase()
                                    .trim() ==
                                'active')
                              new PopupMenuItem<String>(
                                  child: Container(
                                      width: 100,
                                      height: 30,
                                      child: text("Remove",
                                          textColor: GlobalVariables.black,
                                          fontSize: GlobalVariables.textSizeSMedium)),
                                  value: 'remove'),
                            if (widget.classifiedList.Status
                                        .toLowerCase()
                                        .trim() ==
                                    'active' &&
                                inDaysCount < 30)
                              new PopupMenuItem<String>(
                                  child: Container(
                                      width: 100,
                                      height: 30,
                                      child: text("Edit",
                                          textColor: GlobalVariables.black,
                                          fontSize: GlobalVariables.textSizeSMedium)),
                                  value: 'edit'),
                            if (inDaysCount > 30)
                              new PopupMenuItem<String>(
                                  child: Container(
                                      width: 100,
                                      height: 30,
                                      child: text("Activate This Ads",
                                          textColor: GlobalVariables.black,
                                          fontSize: GlobalVariables.textSizeSMedium)),
                                  value: 'active'),
                          ],
                      onSelected: (index) async {
                        switch (index) {
                          case 'remove':
                            deleteClassifiedItemLayout();
                            break;
                          case 'edit':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseCreateClassifiedListing(
                                          true,
                                          classified: widget.classifiedList,
                                        ))).then((value) {
                              //GlobalFunctions.setBaseContext(context);
                            });
                            break;
                          case 'active':
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          'sure_active_ads'),
                                                      fontSize: GlobalVariables.textSizeLargeMedium,
                                                      textColor:
                                                          GlobalVariables.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Container(
                                                      child: FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _progressDialog
                                                                .show();
                                                            Provider.of<OwnerClassifiedResponse>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .activeClassifiedStatus(
                                                                    widget
                                                                        .classifiedList
                                                                        .id)
                                                                .then((value) {
                                                              _progressDialog
                                                                  .hide();
                                                              GlobalFunctions
                                                                  .showToast(value
                                                                      .message);
                                                            });
                                                          },
                                                          child: text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'yes'),
                                                                textColor:
                                                                    GlobalVariables
                                                                        .primaryColor,
                                                                fontSize: GlobalVariables.textSizeMedium,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                          )),
                                                    ),
                                                    Container(
                                                      child: FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'no'),
                                          textColor:
                                                                    GlobalVariables
                                                                        .primaryColor,
                                                                fontSize: GlobalVariables.textSizeMedium,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }));
                            break;
                        }
                      })
                ],
                title: text(
                  AppLocalizations.of(context).translate('create_listing'),
                    textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium,
                ),
              ),
              body: getBaseLayout(value),
              bottomNavigationBar: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: GlobalVariables.transparent,
                ),
                padding: EdgeInsets.all(20),
                child: AppButton(
                    textContent: "Interested Customer (" +
                        interestedList.length.toString() +
                        ")",
                    onPressed: () {
                      if (interestedList.length > 0)
                        showBottomSheet();
                      else
                        GlobalFunctions.showToast(
                            'No Interested Customer Found For This Ads');
                    }),
              ),
            );
          },
        ));
  }

  getBaseLayout(OwnerClassifiedResponse value) {
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
                !value.isLoading
                    ? getCreateClassifiedListingLayout()
                    : SizedBox(),
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
        margin: EdgeInsets.fromLTRB(18, 30, 18, 10),
        padding: EdgeInsets.all(8),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
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
                itemBuilder: (context, index,int item) {
                  return Container(
                      margin: EdgeInsets.all(5.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Stack(
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  print('show pic');
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) => StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            return Dialog(
                                              // backgroundColor: GlobalVariables.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0)),
                                                child: Container(
                                                  // color: GlobalVariables.transparent,
                                                  padding: EdgeInsets.all(16),
                                                  width: 300 ,
                                                  height: 500,
                                                  child: CarouselSlider.builder(
                                                    itemCount: imageList.length,
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
                                                                    imageUrl: imageList[index].Img_Name,
                                                                    fit: BoxFit.fill,
                                                                  ),
                                                                ],
                                                              )));
                                                    },
                                                  ),
                                                ));
                                          }));
                                },
                                child: CachedNetworkImage(
                                    imageUrl: imageList[index].Img_Name,
                                    fit: BoxFit.cover,
                                    width: 1000.0,
                                    height: MediaQuery.of(context).size.width * 0.8),
                              ),
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
                  textColor: GlobalVariables.primaryColor,
                  fontWeight: FontWeight.w500),
              text(widget.classifiedList.Society_Name,
                  fontSize: GlobalVariables.textSizeSmall,
                  maxLine: 2,
                  textColor: GlobalVariables.grey,
                  fontWeight: FontWeight.w500),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(
                    Icons.location_on,
                    iconSize: 20,
                    iconColor: GlobalVariables.lightGray,
                  ),
                  Flexible(
                    child: text(
                        widget.classifiedList.Address +
                            ', ' +
                            widget.classifiedList.Locality +
                            ', ' +
                            widget.classifiedList.City +
                            ', ' +
                            widget.classifiedList.Pincode,
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
                    child: text(/*'Rs. ' + NumberFormat.currency(locale: 'HI',symbol: '',decimalDigits: 2).format(double.parse(widget.classifiedList.Price))*/GlobalFunctions.getCurrencyFormat(widget.classifiedList.Price),
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
                  textColor: GlobalVariables.primaryColor,
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
                  textColor: GlobalVariables.primaryColor,
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
                          text(
                              GlobalFunctions.convertDateFormat(
                                  widget.classifiedList.C_Date, 'dd-MM-yyyy'),
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

  showBottomSheet() {
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
                decoration: boxDecoration(
                    color: GlobalVariables.transparent,
                    radius: GlobalVariables.textSizeMedium,
                    bgColor: GlobalVariables.lightGray),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: GlobalVariables.white),
                // height: MediaQuery.of(context).size.width * 1.0,
                child: Builder(
                    builder: (context) => ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: interestedList.length,
                          itemBuilder: (context, position) {
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.all(8.0),
                              decoration: boxDecoration(
                                radius: 10.0,
                              ),
                              child: Row(
                                children: <Widget>[
                                  interestedList[position].Profile_Image.isEmpty
                                      ? Image.asset(
                                          GlobalVariables
                                              .componentUserProfilePath,
                                          width: 60,
                                          height: 60,
                                        )
                                      : CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              GlobalVariables.secondaryColor,
                                          backgroundImage: NetworkImage(
                                              interestedList[position]
                                                  .Profile_Image),
                                        ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          text(
                                              interestedList[position]
                                                  .User_Name,
                                              textColor: GlobalVariables.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: GlobalVariables
                                                  .textSizeMedium,
                                              textStyleHeight: 1.0),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Uri _emailUri = Uri(
                                                      scheme: 'mailto',
                                                      path: interestedList[
                                                              position]
                                                          .User_Email,
                                                      queryParameters: {
                                                        'subject': ''
                                                      });
                                                  launch(_emailUri.toString());
                                                },
                                                child: text(
                                                    interestedList[position]
                                                        .User_Email,
                                                    textColor:
                                                        GlobalVariables.skyBlue,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: GlobalVariables
                                                        .textSizeSmall,
                                                    textStyleHeight: 1.0),
                                              ),
                                              /*IconButton(icon: Icon(Icons.email,size: 12,),onPressed: (){
                                                launch(interestedList[position]
                                                    .User_Email);
                                              },)*/
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  launch("tel://" +
                                                      interestedList[position]
                                                          .Mobile);
                                                },
                                                child: text(
                                                    interestedList[position]
                                                        .Mobile,
                                                    textColor:
                                                        GlobalVariables.skyBlue,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: GlobalVariables
                                                        .textSizeSmall,
                                                    textStyleHeight: 1.0),
                                              ),
                                              /*IconButton(icon: Icon(Icons.call,size: 24,),onPressed: (){
                                                launch(interestedList[position]
                                                    .User_Email);
                                              },)*/
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          text(
                                              interestedList[position]
                                                  .Society_Name,
                                              textColor: GlobalVariables.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  GlobalVariables.textSizeSmall,
                                              textStyleHeight: 1.0,
                                              maxLine: 2),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          text(interestedList[position].Address,
                                              textColor: GlobalVariables.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  GlobalVariables.textSizeSmall,
                                              textStyleHeight: 1.0,
                                              maxLine: 5),
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
              )
            ],
          );
        });
  }

  List<String> _selectOptionList = List<String>();

  void deleteClassifiedItemLayout() {
    _selectOptionList = List<String>();

    switch (widget.classifiedList.Type.toLowerCase()) {
      case "sell":
        {
          _selectOptionList.add('I sold this item using Societyrun platform');
          _selectOptionList.add('I sold this item using other platform');
          _selectOptionList.add('Do not want to sell this item');
          _selectOptionList.add('Other');
        }
        break;
      case "buy":
        {
          _selectOptionList.add('I got this item using Societyrun platform');
          _selectOptionList.add('I got this item using other platform');
          _selectOptionList.add('Do not want to buy this item');
          _selectOptionList.add('Other');
        }
        break;

      case "rent":
        {
          _selectOptionList.add('I rented this item using Societyrun platform');
          _selectOptionList.add('I rented this item using other platform');
          _selectOptionList.add('Do not want to this item on rent');
          _selectOptionList.add('Other');
        }
        break;
      case "giveaway":
        {}
        break;
    }
    var _selectedText = 'Yes';
    print('_selectOptionList : ' + _selectOptionList.length.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: text(
                              widget.classifiedList.Type.toLowerCase() !=
                                      'giveaway'
                                  ? 'Please select one'
                                  : 'Are you sure you want to remove this add?',
                              maxLine: 3,
                              fontSize: GlobalVariables.textSizeMedium,
                              textColor: GlobalVariables.primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        _selectOptionList.length > 0
                            ? Builder(
                                builder: (context) => ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      // scrollDirection: Axis.vertical,
                                      itemCount: _selectOptionList.length,
                                      itemBuilder: (context, position) {
                                        //print('position : '+position.toString());
                                        //print('_selectOptionList : '+_selectOptionList[position].toString());
                                        return InkWell(
                                          //  splashColor: GlobalVariables.mediumGreen,
                                          onTap: () {
                                            _selectedText =
                                                _selectOptionList[position];
                                            setState(() {
                                              print('selectedText : ' +
                                                  _selectedText);
                                            });
                                            // getListOfPaymentGateway();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      color: _selectedText ==
                                                              _selectOptionList[
                                                                  position]
                                                          ? GlobalVariables
                                                              .primaryColor
                                                          : GlobalVariables
                                                              .white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                        color: _selectedText ==
                                                                _selectOptionList[
                                                                    position]
                                                            ? GlobalVariables
                                                                .primaryColor
                                                            : GlobalVariables
                                                                .secondaryColor,
                                                        width: 2.0,
                                                      )),
                                                  child: AppIcon(Icons.check,
                                                      iconColor: GlobalVariables
                                                          .white),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              10, 0, 0, 0),
                                                      child: text(
                                                          _selectOptionList[
                                                              position],
                                                          fontSize: GlobalVariables.textSizeSMedium,
                                                          textColor:
                                                              GlobalVariables
                                                                  .black,
                                                          maxLine: 3)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }, //  scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                    ))
                            : SizedBox(
                                height: 8,
                              ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          // margin: EdgeInsets.only(left:10,bottom: 8,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: text('Close',
                                        fontSize: GlobalVariables.textSizeMedium,
                                        textColor: GlobalVariables.grey,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                child: InkWell(
                                    onTap: () {
                                      //removeClassifiedItem(_selectedText);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Provider.of<OwnerClassifiedResponse>(
                                              context,
                                              listen: false)
                                          .updateClassifiedStatus(
                                              widget.classifiedList.id,
                                              _selectedText)
                                          .then((value) {
                                        GlobalFunctions.showToast(
                                            value.message);
                                      });
                                    },
                                    child: text(
                                        widget.classifiedList.Type
                                                    .toLowerCase() !=
                                                'giveaway'
                                            ? 'Submit'
                                            : 'Yes',
                                        fontSize: GlobalVariables.textSizeMedium,
                                        textColor: GlobalVariables.primaryColor,
                                        fontWeight: FontWeight.w500)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
            }));
  }
}
