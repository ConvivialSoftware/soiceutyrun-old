
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseDescriptionOfHomeService extends StatefulWidget {

  Services _services;
  BaseDescriptionOfHomeService(this._services);



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DescriptionOfHomeServiceState();
  }
}

class DescriptionOfHomeServiceState
    extends BaseStatefulState<BaseDescriptionOfHomeService> {
  //List<HomeCareDescription> _homeCareList = List<HomeCareDescription>();

  var name="",mobile="",mail="",photo="";

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _requirementController = TextEditingController();
  TextEditingController _bookingDateController = TextEditingController();
  var width,height;
  List<ServicesCharges> _serviceChargesList;
  ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();
    getSharedPrefData();
    _serviceChargesList = List<ServicesCharges>.from(widget._services.charges
        .map((i) => ServicesCharges.fromJson(i)));
    //getHomeCareDescriptionList();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    width = MediaQuery.of(context).size.width;
    height =  MediaQuery.of(context).size.height;
    // TODO: implement build
    return ChangeNotifierProvider<ServicesResponse>.value(
        value: Provider.of<ServicesResponse>(context),
        child: Consumer<ServicesResponse>(
          builder: (context, value, child) {
            print('Consumer Value : ' + value.servicesList.toString());
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
                    widget._services.Category+ ' Services',
                    style: TextStyle(color: GlobalVariables.white),
                  ),
                ),
                body: getBaseLayout(),
              ),
            );
          },
        ));
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
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      getHomeCareDescriptionListDataLayout(),
                    ],
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
                child: AppButton(textContent: "Book Service", onPressed: () {

                  if(_bookingDateController.text.length>0) {
                    if (_requirementController.text.length > 0) {
                      _progressDialog.show();
                      Provider.of<ServicesResponse>(context, listen: false)
                          .bookServicePerCategory(widget._services.Id,
                          _requirementController.text.toString(),
                          _nameController.text, _mobileController.text,
                          _emailController.text, _bookingDateController.text)
                          .then((value) {
                        _progressDialog.hide();
                        if (value.status) {
                          Navigator.of(context).pop();
                        }
                        _requirementController.text='';
                        _bookingDateController.text='';
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                25.0)),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  child: AppAssetsImage(GlobalVariables.successIconPath,imageWidth: 50.0,imageHeight: 50.0,)
                                              ),
                                              Container(
                                                child: text(value.message,
                                                    fontSize: GlobalVariables
                                                        .textSizeSMedium,
                                                    maxLine: 99),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }));
                      });
                    } else {
                      GlobalFunctions.showToast(
                          'Please Enter Your Requirement');
                    }
                  }else{
                    GlobalFunctions.showToast('Please Select Booking Date');
                  }

                },textColor: GlobalVariables.white,)),
          ),
        ],
      ),
    );
  }

  getHomeCareDescriptionListDataLayout() {


    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 50, 10, 0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(15, 10, 0, 0),
            child: Text(
              widget._services.Name,
              style: TextStyle(
                  color: GlobalVariables.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(15, 5, 0, 0),
            child: Text(
              widget._services.Title,
              style: TextStyle(
                color: GlobalVariables.lightGray,
                fontSize: 14,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Service Description',
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        widget._services.Description,
                        style: TextStyle(
                          color: GlobalVariables.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    /*Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      // color: GlobalVariables.grey,
                      child: Builder(
                          builder: (context) => ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget._services.charges.length,
                              shrinkWrap: true,
                              *//*gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 4),*//*
                              itemBuilder: (BuildContext context, int position) {
                                return getHomeCareDescriptionListItemLayout(
                                    position);
                              })),
                    ),*/
                  ],
                ),
              ),
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 8, top: 8),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: boxDecoration(bgColor: GlobalVariables.orangeYellow, radius: 8),
                  child: FittedBox(child: text(widget._services.Discount+'% Discount', fontSize: GlobalVariables.textSizeSmall, textColor: GlobalVariables.white,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Charges',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Builder(
                      builder: (context) => ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                          itemCount: _serviceChargesList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int position) {
                            return getHomeCareChargesListItemLayout(position);
                          })),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Tell us your requirement',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 100,
                  child: /*AppTextField(textHintContent: 'Write to us about your requirement',
                      controllerCallback: _requirementController,
                    borderColor: GlobalVariables.transparent,
                  ),*/TextField(
                    controller: _requirementController,
                    //maxLines: 99,
                    decoration: InputDecoration(
                      hintText: 'Write to us about your requirement',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: AppTextField(
              textHintContent:
              AppLocalizations.of(context).translate('booking_date'),
              controllerCallback: _bookingDateController,
              borderWidth: 2.0,
              contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              readOnly: true,
              suffixIcon: AppIconButton(
                Icons.date_range,
                iconColor: GlobalVariables.mediumGreen,
                onPressed: () {
                  GlobalFunctions.selectFutureDate(context).then((value) {
                    _bookingDateController.text =
                        value.day.toString().padLeft(2, '0') +
                            "-" +
                            value.month.toString().padLeft(2, '0') +
                            "-" +
                            value.year.toString();
                  });
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Requester Details',
                    style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  /*decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: GlobalVariables.mediumGreen, width: 3.0)),*/
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        photo.isEmpty ? Image.asset(
                          GlobalVariables.componentUserProfilePath,
                          width: 26,
                          height: 26,
                        ): CircleAvatar(
                          radius: 13,
                          backgroundColor: GlobalVariables.mediumGreen,
                          backgroundImage: NetworkImage(photo),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                        color: GlobalVariables.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  //margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                  child: Container(
                                    child: Text(
                                      mail,
                                      style: TextStyle(
                                        color: GlobalVariables.lightGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    mobile,
                                    style: TextStyle(
                                      color: GlobalVariables.lightGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            showBottomSheetEditInfoLayout();
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(
                                  color:GlobalVariables.green,
                                  borderRadius: BorderRadius.circular(30)),
                              child:Icon(Icons.edit,color: GlobalVariables.white,size: 20,)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      /*    Container(
            alignment: Alignment.topLeft,
            height: 45,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: ButtonTheme(
              // minWidth: MediaQuery.of(context).size.width/2,
              child: RaisedButton(
                color: GlobalVariables.green,
                onPressed: () {},
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.green)),
                child: Text(
                  AppLocalizations.of(context).translate('submit'),
                  style: TextStyle(fontSize: GlobalVariables.textSizeMedium),
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

 /* getHomeCareDescriptionListItemLayout(int position) {
    return Container(
      padding: EdgeInsets.all(5),
      //margin: EdgeInsets.fromLTRB(0, 10, 0, 0), // width: 100,
      // color: GlobalVariables.grey,
      child: Container(
        // height: 50,
        child: Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.circular(50)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(
                _homeCareList[0].serviceList[position].serviceName,
                style: TextStyle(color: GlobalVariables.grey),
              ),
            )
          ],
        ),
      ),
    );
  }*/

  getHomeCareChargesListItemLayout(int position) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0), // width: 100,
      // color: GlobalVariables.grey,
      child: Column(
        children: <Widget>[
          Container(
            // height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: GlobalVariables.green,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          _serviceChargesList[position].Service_Title,
                          style: TextStyle(color: GlobalVariables.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _serviceChargesList[position].Service_Price,
                    style: TextStyle(color: GlobalVariables.green),
                  ),
                )
              ],
            ),
          ),
          _serviceChargesList.length-1!=position ? Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Divider(
              color: GlobalVariables.grey,
              height: 3,
            ),
          ):Container()
        ],
      ),
    );
  }

  showBottomSheetEditInfoLayout(){

    return showDialog(
          context: context,
          builder: (BuildContext context) =>
              StatefulBuilder(builder:
                  (BuildContext context,
                  StateSetter _setState) {
                return Dialog(
                  /*shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0)),*/
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: GlobalVariables.white),
                    // height: MediaQuery.of(context).size.width * 1.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 16,
                          ),
                          AppTextField(textHintContent: 'Enter Name', controllerCallback: _nameController),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(textHintContent: 'Enter Email ID', controllerCallback: _emailController),
                          SizedBox(
                            height: 8,
                          ),
                          AppTextField(textHintContent: 'Enter Mobile Number', controllerCallback: _mobileController),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  name = _nameController.text;
                                  mail = _emailController.text;
                                  mobile = _mobileController.text;
                                  setState(() {

                                  });
                                },
                                color: GlobalVariables.green,
                                child: text('Submit',textColor: GlobalVariables.white,fontSize: 14.0,fontWeight: FontWeight.w500)
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }));

  }

 /* getHomeCareDescriptionList() {
    _homeCareList = [
      HomeCareDescription(
          title: "Siddhivinayak Traders",
          subDesc: "AC Repair and Maintanance",
          serviceDesc:
              "Fast and reliable Air-conditioner repair service provider at your door step. Repair Service. "
              "Best Repair Service and installation near you.",
          serviceList: [
            Services(serviceName: "Window AC Servicing"),
            Services(serviceName: "AC Installation"),
            Services(serviceName: "Split AC Repairing"),
            Services(serviceName: "Yearly Maintanance"),
            Services(serviceName: "Ducted AC Repairing"),
          ],
          chargesList: [
            Charges(
                chargesName: "AC Servicing", chargesPrice: "Start from Rs.500"),
            Charges(
                chargesName: "Yearly AMC", chargesPrice: "Start from Rs.1,500"),
            Charges(
                chargesName: "AC Installation",
                chargesPrice: "Start from Rs.1,000"),
          ])
    ];
  }
*/

  Future<void> getSharedPrefData() async {
    name = await GlobalFunctions.getDisplayName();
    mail = await GlobalFunctions.getUserName();
    mobile = await GlobalFunctions.getMobile();
    photo = await GlobalFunctions.getPhoto();

    setState(() {
      _nameController.text=name;
      _emailController.text=mail;
      _mobileController.text=mobile;
    });
  }
}

/*class HomeCareDescription {
  String title, subDesc, serviceDesc;
  List<Services> serviceList;
  List<Charges> chargesList;

  HomeCareDescription(
      {this.title,
      this.subDesc,
      this.serviceDesc,
      this.serviceList,
      this.chargesList});
}

class Services {
  String serviceName;
  Services({this.serviceName});
}

class Charges {
  String chargesName, chargesPrice;
  Charges({this.chargesName, this.chargesPrice});
}*/
