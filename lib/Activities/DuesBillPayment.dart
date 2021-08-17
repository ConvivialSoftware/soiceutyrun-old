import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseDuesBillPayment extends StatefulWidget {

  Bills bills;
  BaseDuesBillPayment(this.bills);

  @override
  _BaseDuesBillPaymentState createState() => _BaseDuesBillPaymentState();

}

class _BaseDuesBillPaymentState extends BaseStatefulState<BaseDuesBillPayment> {
  var amount, invoiceNo, referenceNo, billType, orderId;
  ProgressDialog _progressDialog;
  Razorpay _razorpay;
  var userId = "",
      societyId;
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';
  //(widget.bills.AMOUNT- widget.bills.RECEIVED)
  @override
  void initState(){
    amount=(widget.bills.AMOUNT- widget.bills.RECEIVED);
    getSharedPreferenceData();
    Provider.of<UserManagementResponse>(context,listen: false).getPaymentCharges();
    super.initState();
  }

  @override
  void dispose() {
    print('_BaseDuesState dispose');
    if (_razorpay != null) {
      _razorpay.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
        return Scaffold(
          backgroundColor: GlobalVariables.veryLightGray,
          appBar: AppBar(
            title: Text(widget.bills.TYPE == 'Bill' ? 'Maintenance Bill' : widget.bills.TYPE),
            leading: IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back)),
          ),
          body: getBaseDuesBillPaymentLayout(value),
        );
      }),
    );
  }

  Future<void> getSharedPreferenceData() async {
    societyId = await GlobalFunctions.getSocietyId();
    userId = await GlobalFunctions.getUserId();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    // flat = await GlobalFunctions.getFlat();
    // block = await GlobalFunctions.getBlock();
    userType = await GlobalFunctions.getUserType();

    print('societyId : ' + societyId);
    print('UserId : ' + userId);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('userType : ' + userType);
  }

  getBaseDuesBillPaymentLayout(UserManagementResponse value) {

    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40,),
              AppContainer(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text(GlobalFunctions.getCurrencyFormat(amount.toString()),textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeXLarge,fontWeight: FontWeight.bold,isCentered: true),
                    SizedBox(height: 8,),
                    text(widget.bills.HEAD,textColor: GlobalVariables.black,isCentered: true,
                        fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.bold),
                    SizedBox(height: 8,),
                    text('Last Payment Date'+widget.bills.DUE_DATE != null
                        ? GlobalFunctions.convertDateFormat(
                        widget.bills.DUE_DATE,
                        "dd MMM yyyy")
                        : '',textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium,isCentered: true),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                child: AppButton(
                    textContent: AppLocalizations.of(context).translate('pay_now'),
                    padding: EdgeInsets.all(12),
                    onPressed: (){
                  showBottomSheetForPaymentMethod(value);
                }),
              )
            ],
          ),
        ),
      ],
    );

/*
* Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              text(GlobalFunctions.getCurrencyFormat(amount.toString()),textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.bold),
              SizedBox(height: 8,),
              text(widget.bills.HEAD,textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium),
              SizedBox(height: 8,),
              text('Last Payment Date'+widget.bills.DUE_DATE != null
                  ? GlobalFunctions.convertDateFormat(
                  widget.bills.DUE_DATE,
                  "dd MMM yyyy")
                  : '',textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium),
              AppButton(textContent: AppLocalizations.of(context).translate('pay_now'), onPressed: (){
                showBottomSheetForPaymentMethod(value);
              })
            ],
          ),
*
* */
  }
  String _selectedPaymentGateway = "RazorPay";
  TextEditingController _amountTextController = TextEditingController();
  bool isEditAmount = false;
  void showBottomSheetForPaymentMethod(UserManagementResponse value) {

    if (amount > 0) {
      if (value.payOptionList[0].Status) {
          if (value.hasRazorPayGateway) {


            showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: GlobalVariables.transparent,
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) => getListOfPaymentGateway(
                        context,
                        setState,
                        value)
                );
              },
            );
          /*  showModalBottomSheet(
              isScrollControlled: true,
                backgroundColor: Colors.white,
                context: context,
                builder: (BuildContext context) {
                  return
                });*/

            /*_selectedPaymentGateway = 'RazorPay';
            *//*getListOfPaymentGateway(
                            context,
                            setState,
                            position,
                            value)*//*
          } else if (value.hasPayTMGateway) {
            //Paytm Payment method execute

            _selectedPaymentGateway = 'PayTM';
            print('_selectedPaymentGateway' +
                _selectedPaymentGateway);

            *//*getListOfPaymentGateway(
                            context,
                            setState,
                            position,
                            value),*/
          } else {
            GlobalFunctions.showToast(
                "Online Payment Option is not available.");
          }
        } else {
          GlobalFunctions.showToast(
              "Online Payment Option is not available.");
      }
    } else {
      alreadyPaidDialog(value);
    }
  }


 /* getListOfPaymentGateway(BuildContext context, StateSetter setState, UserManagementResponse value) {
    // GlobalFunctions.showToast(_selectedPaymentGateway.toString());

    print('NoLessPermission : ' +
        AppSocietyPermission.isSocPayAmountNoLessPermission.toString());

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 70.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(20),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: primaryText(
                        AppLocalizations.of(context).translate('change_amount'),
                        textColor: GlobalVariables.black,
                        //fontSize: GlobalVariables.textSizeLargeMedium,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: text(
                            'Rs. ',
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 150,
                          child: TextFormField(
                            controller: _amountTextController,
                            readOnly: isEditAmount ? false : true,
                            cursorColor: GlobalVariables.green,
                            showCursor: isEditAmount ? true : false,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeNormal,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              counterText: "",
                              border: isEditAmount
                                  ? new UnderlineInputBorder(
                                  borderSide:
                                  new BorderSide(color: Colors.green))
                                  : InputBorder.none,
                              // disabledBorder: InputBorder.none,
                              // enabledBorder: InputBorder.none,
                              // errorBorder: InputBorder.none,
                              // focusedBorder: InputBorder.none,
                              // focusedErrorBorder: InputBorder.none,
                              // contentPadding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                        (AppSocietyPermission.isSocPayAmountEditPermission ||
                            AppSocietyPermission.isSocPayAmountNoLessPermission)
                            ? Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: !isEditAmount
                              ? IconButton(
                              icon: AppIcon(
                                Icons.edit,
                                iconColor: GlobalVariables.green,
                                iconSize:
                                GlobalVariables.textSizeLarge,
                              ),
                              onPressed: () {
                                _amountTextController.clear();
                                isEditAmount = true;
                                setState(() {});
                              })
                              : IconButton(
                              icon: AppIcon(
                                Icons.cancel,
                                iconColor: GlobalVariables.grey,
                                iconSize: 24,
                              ),
                              onPressed: () {
                                _amountTextController.clear();
                                _amountTextController.text = amount;
                                isEditAmount = false;
                                setState(() {});
                              }),
                        )
                            : SizedBox(),
                      ],
                    ),
                    (value.hasPayTMGateway || value.hasRazorPayGateway)
                        ? Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      alignment: Alignment.topLeft,
                      child: primaryText(
                        AppLocalizations.of(context)
                            .translate('select_payment_option'),
                        textColor: GlobalVariables.black,
                        //fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                        : Container(),
                    value.hasRazorPayGateway
                        ? Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
                          _selectedPaymentGateway = "RazorPay";
                          setState(() {});
                          // getListOfPaymentGateway();
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color:
                                    _selectedPaymentGateway != "PayTM"
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway !=
                                          "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Image.asset(
                                  GlobalVariables.razorPayIconPath,
                                  height: 40,
                                  width: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    value.hasPayTMGateway
                        ? Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
                          _selectedPaymentGateway = "PayTM";
                          //   getListOfPaymentGateway();
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color:
                                    _selectedPaymentGateway == "PayTM"
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway ==
                                          "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Image.asset(
                                  GlobalVariables.payTMIconPath,
                                  height: 20,
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(10, 15, 0, 5),
                      child: text(
                        AppLocalizations.of(context).translate('trans_charges'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                child: InkWell(
                  onTap: () {
                    print('amount : ' + amount);
                    print('_amountTextController : ' +
                        _amountTextController.text.toString());
                    if (double.parse(_amountTextController.text) <= 0) {
                      GlobalFunctions.showToast(
                          'Amount must be grater than zero');
                    } else if (AppSocietyPermission.isSocPayAmountNoLessPermission) {
                      if (double.parse(amount) <=
                          double.parse(_amountTextController.text)) {
                        Navigator.of(context).pop();
                        redirectToPaymentGateway(_amountTextController.text, value);
                      } else {
                        GlobalFunctions.showToast(
                            'Amount must be Grater or equal to Actual Amount');
                      }
                    } else {
                      Navigator.of(context).pop();
                      redirectToPaymentGateway(_amountTextController.text, value);
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: text(
                        AppLocalizations.of(context).translate('proceed'),
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
*/
  getListOfPaymentGateway(BuildContext context, StateSetter setState, UserManagementResponse value) {
    // GlobalFunctions.showToast(_selectedPaymentGateway.toString());

    _amountTextController.text=amount.toString();
    
    print('NoLessPermission : ' + AppSocietyPermission.isSocPayAmountNoLessPermission.toString());
    print('isEdit : '+isEditAmount.toString());

    return Container(
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.only(topLeft:Radius.circular(10.0),topRight: Radius.circular(10.0) )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0,top: 16.0),
            alignment: Alignment.topRight,
            child: AppIconButton(Icons.close,
              iconSize: 24.0,
              onPressed: (){
              Navigator.of(context).pop();
            },)
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            width: double.infinity,
            decoration: boxDecoration(
                bgColor: GlobalVariables.lightGreen,radius: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin:EdgeInsets.only(left: 16),
                    child: AppAssetsImage(GlobalVariables.receiptIconPath,imageWidth: 30.0,imageHeight: 30.0,)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    /*text("Paying"),
                    SizedBox(height: 4,),*/
                    //text(widget.bills.HEAD,fontSize: GlobalVariables.textSizeMedium,textColor: GlobalVariables.black,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: text(
                            'Rs. ',
                            textColor: GlobalVariables.black,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          width: 150,
                          child: TextFormField(
                            controller: _amountTextController,
                            readOnly: isEditAmount ? false : true,
                            cursorColor: GlobalVariables.green,
                            showCursor: isEditAmount ? true : false,
                            keyboardType: TextInputType.number,
                            //keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeNormal,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              counterText: "",
                              border: isEditAmount
                                  ? new UnderlineInputBorder(
                                  borderSide:
                                  new BorderSide(color: Colors.green))
                                  : InputBorder.none,
                              // disabledBorder: InputBorder.none,
                              // enabledBorder: InputBorder.none,
                              // errorBorder: InputBorder.none,
                              // focusedBorder: InputBorder.none,
                              // focusedErrorBorder: InputBorder.none,
                              // contentPadding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                        (AppSocietyPermission.isSocPayAmountEditPermission ||
                            AppSocietyPermission.isSocPayAmountNoLessPermission)
                            ? Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: !isEditAmount
                              ? IconButton(
                              icon: AppIcon(
                                Icons.edit,
                                iconColor: GlobalVariables.green,
                                iconSize:
                                GlobalVariables.textSizeLarge,
                              ),
                              onPressed: () {
                                _amountTextController.clear();
                                isEditAmount = true;
                                setState(() {});
                              })
                              : IconButton(
                              icon: AppIcon(
                                Icons.cancel,
                                iconColor: GlobalVariables.grey,
                                iconSize: 24,
                              ),
                              onPressed: () {
                                _amountTextController.clear();
                                _amountTextController.text = amount.toString();
                                isEditAmount = false;
                                setState(() {});
                              }),
                        )
                            : SizedBox(),
                      ],
                    ),

                  ],
                ),
                //toolBarTitle("\$122.50").paddingTop(spacing_standard_new),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16),
            width: double.infinity,
            decoration: boxDecoration(radius: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                /*(value.hasPayTMGateway || value.hasRazorPayGateway)
                    ? Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  alignment: Alignment.topLeft,
                  child: primaryText(
                    AppLocalizations.of(context)
                        .translate('select_payment_option'),
                    textColor: GlobalVariables.black,
                    //fontSize: GlobalVariables.textSizeMedium,
                    fontWeight: FontWeight.normal,
                  ),
                )
                    : Container(),*/
                value.hasRazorPayGateway
                    ? Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: InkWell(
                    //  splashColor: GlobalVariables.mediumGreen,
                    onTap: () {
                      _selectedPaymentGateway = "RazorPay";
                      setState(() {});
                      // getListOfPaymentGateway();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color:
                                _selectedPaymentGateway != "PayTM"
                                    ? GlobalVariables.green
                                    : GlobalVariables.white,
                                borderRadius:
                                BorderRadius.circular(5),
                                border: Border.all(
                                  color: _selectedPaymentGateway !=
                                      "PayTM"
                                      ? GlobalVariables.green
                                      : GlobalVariables.mediumGreen,
                                  width: 2.0,
                                )),
                            child: AppIcon(Icons.check,
                                iconColor: GlobalVariables.white),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Image.asset(
                              GlobalVariables.razorPayIconPath,
                              height: 40,
                              width: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : Container(),
                value.hasPayTMGateway
                    ? Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: InkWell(
                    //  splashColor: GlobalVariables.mediumGreen,
                    onTap: () {
                      _selectedPaymentGateway = "PayTM";
                      //   getListOfPaymentGateway();
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color:
                                _selectedPaymentGateway == "PayTM"
                                    ? GlobalVariables.green
                                    : GlobalVariables.white,
                                borderRadius:
                                BorderRadius.circular(5),
                                border: Border.all(
                                  color: _selectedPaymentGateway ==
                                      "PayTM"
                                      ? GlobalVariables.green
                                      : GlobalVariables.mediumGreen,
                                  width: 2.0,
                                )),
                            child: AppIcon(Icons.check,
                                iconColor: GlobalVariables.white),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Image.asset(
                              GlobalVariables.payTMIconPath,
                              height: 20,
                              width: 80,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : Container(),

              ],
            ),
          ),
          SizedBox(height: 16,),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 16,right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: text('Preferred Method',textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4,),
                    /*Container(
                      margin: EdgeInsets.only(left: 16),
                      child: text(' UPI : 0 Rs. \n Rupay Debit card : 0 Rs. \n Net Banking : 10 to 20 Rs.',textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeSMedium),
                    ),*/
                    ListView.builder(
                        itemCount: value.preferredMethod.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context,position){
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: text(value.preferredMethod[position].variable+" : ",textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8,),
                            Container(
                              child: text(value.preferredMethod[position].value,textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                      );
                    })
                  ],
                ),
                //SizedBox(height: 16,),
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: text('Other Method',textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4,),
                    ListView.builder(
                        itemCount: value.otherMethod.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context,position){
                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: text(value.otherMethod[position].variable + " : ",textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8,),
                                Container(
                                  child: text(value.otherMethod[position].value,textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                          );
                        })
                  ],
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(10, 15, 0, 5),
            child: text(
              AppLocalizations.of(context).translate('trans_charges'),
              textColor: GlobalVariables.red,
              fontSize: GlobalVariables.textSizeSmall,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(16),
            //padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GlobalVariables.green,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: InkWell(
              onTap: () {
                print('amount : ' + amount.toString());
                print('_amountTextController : ' +
                    _amountTextController.text.toString());
                if (double.parse(_amountTextController.text) <= 0) {
                  GlobalFunctions.showToast(
                      'Amount must be grater than zero');
                } else if (AppSocietyPermission.isSocPayAmountNoLessPermission) {
                  if (double.parse(amount.toString()) <=
                      double.parse(_amountTextController.text)) {
                    Navigator.of(context).pop();
                    redirectToPaymentGateway(_amountTextController.text, value);
                  } else {
                    GlobalFunctions.showToast(
                        'Amount must be Grater or equal to Actual Amount');
                  }
                } else {
                  Navigator.of(context).pop();
                  redirectToPaymentGateway(_amountTextController.text, value);
                }
              },
              child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: text(
                    AppLocalizations.of(context).translate('proceed'),
                    textColor: GlobalVariables.white,
                    fontSize: GlobalVariables.textSizeNormal,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ],
      )
    );
  }

  void alreadyPaidDialog(UserManagementResponse value) {
    showDialog(
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
                          child: AppAssetsImage(
                            GlobalVariables.paidIconPath,
                            imageWidth: 70.0,
                            imageHeight: 70.0,
                          )),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(AppLocalizations.of(context)
                              .translate('already_paid_advance_payment'))),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  alignment: Alignment.topRight,
                                  child: text('Close',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            StatefulBuilder(builder:
                                                (BuildContext context,
                                                StateSetter setState) {
                                              return Dialog(
                                                /*shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                25.0)),*/
                                                backgroundColor:
                                                Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    value),
                                              );
                                            }));
                                  },
                                  child: text('Pay advance',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.green,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  void redirectToPaymentGateway( String textAmount, UserManagementResponse value) {
    if (_selectedPaymentGateway == 'PayTM') {
      //Navigator.of(context).pop();

      showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: displaySocietyRunDisclaimer(value),
                );
              }));
    } else if (_selectedPaymentGateway == 'RazorPay') {
      getRazorPayOrderID(value.payOptionList[0].KEY_ID,
          value.payOptionList[0].SECRET_KEY, double.parse(textAmount), value);
    }
  }

  void getRazorPayOrderID(String razorKey, String secret_key,
      double textAmount, UserManagementResponse UserManagementResponse) {
    final dio = Dio();
    final RestClientRazorPay restClientRazorPay =
    RestClientRazorPay(dio, baseUrl: GlobalVariables.BaseRazorPayURL);
    amount = textAmount * 100;
    invoiceNo = widget.bills.INVOICE_NO;
    _progressDialog.show();
    RazorPayOrderRequest request = new RazorPayOrderRequest(
        amount: amount,
        currency: "INR",
        receipt: widget.bills.BLOCK + ' ' + widget.bills.FLAT + '-' + invoiceNo,
        paymentCapture: 1);
    restClientRazorPay
        .getRazorPayOrderID(request, razorKey, secret_key)
        .then((value) {
      print('getRazorPayOrderID Response : ' + value.toString());
      orderId = value['id'];
      print('id : ' + orderId);
      postRazorPayTransactionOrderID(value['id'], value['amount'].toString(), UserManagementResponse);
    });
  }

  Future<void> postRazorPayTransactionOrderID(String orderId, String amount,UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //String block = await GlobalFunctions.getBlock();
    //String flat = await GlobalFunctions.getFlat();

    restClientERP
        .postRazorPayTransactionOrderID(societyId, widget.bills.BLOCK + ' ' + widget.bills.FLAT, orderId,
        (double.parse(amount) / 100).toString())
        .then((value) {
      print('Value : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        if (_razorpay != null) {
          _razorpay.clear();
        }
        _razorpay = Razorpay();
        _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

        openCheckOut(UserManagementResponse.payOptionList[0].KEY_ID,
            orderId, amount, UserManagementResponse);
      } else {
        GlobalFunctions.showToast(value.message);
      }
    });
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razor Success Response : ' + response.toString());
    // GlobalFunctions.showToast("Success : " + response.paymentId.toString());
    addOnlinePaymentRequest(response.paymentId, 'success', response.orderId);
  }

  _handlePaymentError(PaymentFailureResponse response) {
    print('Razor Error Response : ' + response.message);
    GlobalFunctions.showToast(" " + response.message.toString());
    addOnlinePaymentRequest('', 'failure', orderId);
  }

  _handleExternalWallet(ExternalWalletResponse response) {
    print('Razor ExternalWallet Response : ' + response.toString());
    GlobalFunctions.showToast(
        "ExternalWallet : " + response.walletName.toString());
  }

  void openCheckOut(String razorKey, String orderId,
      String amount, UserManagementResponse UserManagementResponse) {
    //amount = value.billList[position].AMOUNT;
    invoiceNo = widget.bills.INVOICE_NO;
    billType = widget.bills.TYPE == 'Bill'
        ? 'Maintenance Bill'
        : widget.bills.TYPE;
    print('amount : ' + amount.toString());
    print('RazorKey : ' + razorKey.toString());

    var option = {
      'key': razorKey,
      'amount': amount,
      'name': societyName,
      'order_id': orderId,
      'description': widget.bills.BLOCK + ' ' + widget.bills.FLAT + '-' + invoiceNo + '/' + billType,
      'prefill': {'contact': phone, 'email': email}
    };

    try {
      _razorpay.open(option);
    } catch (e) {
      debugPrint(e);
    }
  }

  Future<void> addOnlinePaymentRequest(
      String paymentId, String paymentStatus, String orderId) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //  String block = await GlobalFunctions.getBlock();
    // String flat = await GlobalFunctions.getFlat();

    print("AMOUNT>>>>>>>> $amount");

    String paymentDate = DateTime.now().toLocal().year.toString() +
        "-" +
        DateTime.now().toLocal().month.toString().padLeft(2, '0') +
        "-" +
        DateTime.now().toLocal().day.toString().padLeft(2, '0');

    _progressDialog.show();
    restClientERP
        .addOnlinePaymentRequest(
        societyId,
        widget.bills.FLAT,
        widget.bills.BLOCK,
        invoiceNo,
        (amount / 100).toString(),
        paymentId,
        "Online Transaction",
        "Razorpay",
        paymentDate,
        paymentStatus,
        orderId)
        .then((value) {
      print("add OnlinepaymentRequest response : " + value.toString());
      _progressDialog.hide();
      if (value.status) {
        // Navigator.of(context).pop('back');
        if (paymentStatus == 'success') {
          Provider.of<UserManagementResponse>(context, listen: false)
              .getPayOption(widget.bills.BLOCK,widget.bills.FLAT)
              .then((value) {

          });
          paymentSuccessDialog(paymentId);
        } else {
          paymentFailureDialog();
        }
      } else {
        GlobalFunctions.showToast(value.message);
      }
      amount = null;
      invoiceNo = null;
      billType = null;
      orderId = null;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }
  paymentSuccessDialog(String paymentId) {
    print('paymentId : ' + paymentId.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width / 1.2,
                  color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                  // height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: AppIconButton(
                          Icons.close,
                          iconColor: GlobalVariables.green,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        //color: GlobalVariables.grey,
                        child: AppAssetsImage(
                          GlobalVariables.successIconPath,
                          imageWidth: 80.0,
                          imageHeight: 80.0,
                          //imageColor: GlobalVariables.green,
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('successful_payment'),
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold,
                              textColor: GlobalVariables.black)),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('transaction_id') +
                                ' : ' +
                                paymentId.toString(),
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('thank_you_payment'),
                            textColor: GlobalVariables.skyBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  paymentFailureDialog() {
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
                  //height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: AppIconButton(
                          Icons.close,
                          iconColor: GlobalVariables.green,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        child: AppAssetsImage(
                          GlobalVariables.failureIconPath,
                          imageWidth: 80.0,
                          imageHeight: 80.0,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('failure_to_pay'),
                              textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold,
                              fontSize: GlobalVariables.textSizeMedium)),

                      /* Container(
                           margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                           child: Text(AppLocalizations.of(context)
                               .translate('order_amount'))),*/
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('payment_failed_try_again'),
                              textColor: GlobalVariables.skyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: GlobalVariables.textSizeSMedium)),
                    ],
                  ),
                ),
              );
            }));
  }

  displaySocietyRunDisclaimer(UserManagementResponse value) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('disclaimer'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 250,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                child: text(
                  AppLocalizations.of(context).translate('disclaimer_info'),
                  fontSize: GlobalVariables.textSizeMedium,
                  textColor: GlobalVariables.black,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0)),
                                    child: displayConsumerId(value),
                                  );
                                }));
                      },
                      child: text(
                        AppLocalizations.of(context).translate('proceed'),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('cancel'),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  displayConsumerId(UserManagementResponse UserManagementResponse) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: text(
              consumerId,
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                    icon: AppIcon(
                      Icons.content_copy,
                      iconColor: GlobalVariables.green,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClipboardManager.copyToClipBoard(consumerId)
                          .then((value) {
                        GlobalFunctions.showToast("Copied to Clipboard");
                        launch(
                            UserManagementResponse.payOptionList[0].PAYTM_URL);
                      });
                    }),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: text(
                    AppLocalizations.of(context).translate('copy'),
                    fontSize: GlobalVariables.textSizeSmall,
                    fontWeight: FontWeight.bold,
                    textColor: GlobalVariables.green,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}
