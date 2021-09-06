
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ServicesResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:intl/intl.dart';
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
                backgroundColor: GlobalVariables.veryLightGray,
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
                  title: text(
                    widget._services.Category+ ' Services',
                    textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeMedium
                  ),
                ),
                body: getBaseLayout(),
              ),
            );
          },
        ));
  }

  getBaseLayout() {
    return Column(
      children: <Widget>[
        Flexible(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                Column(
                  children: <Widget>[
                    getHomeCareDescriptionListDataLayout(),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              width: width,
              margin: EdgeInsets.all(16),
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
    );
  }

  getHomeCareDescriptionListDataLayout() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 16,top: 16),
            child: text(
              widget._services.Name,
              textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeLargeMedium,
                  fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4,),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 16),
            child: text(
              widget._services.Title,
              textColor: GlobalVariables.lightGray,
                fontSize: GlobalVariables.textSizeSMedium,
            ),
          ),
          Stack(
            children: [
              AppContainer(

                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: primaryText(
                        'Service Description',
                      ),
                    ),
                    SizedBox(height: 8,),
                    Container(
                      alignment: Alignment.topLeft,
                      //margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: secondaryText(
                        widget._services.Description,
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
                right: 16,
                top: -5,
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 8, top: 8),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: boxDecoration(bgColor: GlobalVariables.orangeYellow, radius: 5),
                  child: FittedBox(child: text(widget._services.Discount+'% Discount', fontSize: GlobalVariables.textSizeSmall, textColor: GlobalVariables.white,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          AppContainer(
            isListItem: true,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: primaryText(
                    'Charges',
                  ),
                ),
                SizedBox(height: 8,),
                Builder(
                    builder: (context) => ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                        itemCount: _serviceChargesList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int position) {
                          return getHomeCareChargesListItemLayout(position);
                        })),
              ],
            ),
          ),
          AppContainer(
            isListItem: true,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: primaryText(
                    'Tell us your requirement',
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
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppContainer(
            isListItem: true,
            child: AppTextField(
              textHintContent:
              AppLocalizations.of(context).translate('booking_date'),
              controllerCallback: _bookingDateController,
              borderWidth: 2.0,
              contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              readOnly: true,
              suffixIcon: AppIconButton(
                Icons.date_range,
                iconColor: GlobalVariables.secondaryColor,
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
          AppContainer(
           isListItem:true,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: primaryText(
                    'Requester Details',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        photo.isEmpty ? Image.asset(
                          GlobalVariables.componentUserProfilePath,
                          width: 40,
                          height: 40,
                        ): CircleAvatar(
                          radius: 20,
                          backgroundColor: GlobalVariables.secondaryColor,
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
                                  child: primaryText(
                                    name,
                                  ),
                                ),
                                Container(
                                  //margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                  child: Container(
                                    child: secondaryText(
                                      mail,
                                      fontSize: GlobalVariables.textSizeSmall
                                    ),
                                  ),
                                ),
                                Container(
                                  child: secondaryText(
                                    mobile,
                                      fontSize: GlobalVariables.textSizeSmall
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
                                  color:GlobalVariables.primaryColor,
                                  borderRadius: BorderRadius.circular(30)),
                              child:AppIcon(Icons.edit,iconColor: GlobalVariables.white,iconSize: GlobalVariables.textSizeNormal  ,)
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
      margin: EdgeInsets.fromLTRB(0, 4, 0, 0), // width: 100,
      // color: GlobalVariables.grey,
      child: Column(
        children: <Widget>[
          Container(
            // height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: GlobalVariables.primaryColor,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(width: 8,),
                      secondaryText(
                        _serviceChargesList[position].Service_Title,
                        textStyleHeight: 1.0
                      ),
                    ],
                  ),
                ),
                text(
                    GlobalFunctions.getCurrencyFormat((int.parse(_serviceChargesList[position].Service_Price)-(int.parse(_serviceChargesList[position].Service_Price)*int.parse(widget._services.Discount)/100)).toString())
                  /*'Rs. '+NumberFormat.currency(locale: 'HI',symbol: '',decimalDigits: 0).format(double.parse(_serviceChargesList[position].Service_Price))*//*GlobalFunctions.getCurrencyFormat(_serviceChargesList[position].Service_Price)*/,

                textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium,textStyleHeight: 1.0
                )
              ],
            ),
          ),
          _serviceChargesList.length-1!=position ? Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child:Divider()
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
                            alignment: Alignment.topRight,
                            height: 45,
                           // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: AppButton(
                              textContent: AppLocalizations.of(context).translate('submit'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                name = _nameController.text;
                                mail = _emailController.text;
                                mobile = _mobileController.text;
                                setState(() {

                                });
                              },
                            ),
                          ),
                         /* Container(
                            width: MediaQuery.of(context).size.width,
                            child: FlatButton(
                                onPressed: () {

                                },
                                color: GlobalVariables.green,
                                child: text('Submit',textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.w500)
                            ),
                          )*/
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
