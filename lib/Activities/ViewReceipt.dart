import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseViewReceipt extends StatefulWidget {

  String invoiceNo,yearSelectedItem;
  BaseViewReceipt(this.invoiceNo, this.yearSelectedItem);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewReceiptState(invoiceNo);
  }
}

class ViewReceiptState extends BaseStatefulState<BaseViewReceipt> {
  ReceiptViewResponse _receiptViewList = ReceiptViewResponse();
  List<Receipt> _receiptList = new List<Receipt>();

  String name="",consumerId="",email="";
  String invoiceNo;
  ViewReceiptState(this.invoiceNo);

  ProgressDialog _progressDialog;
  TextEditingController _emailTextController = TextEditingController();
  bool isEditEmail = false;

  @override
  void initState() {
    super.initState();
    getSharedPrefData();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getReceiptData();

      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(icon: Icon(Icons.mail), onPressed: (){
              emailReceiptDialog(context);
            }),
          ],
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
            AppLocalizations.of(context).translate('receipt')+ ' - '+invoiceNo,
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return _receiptList.length>0 ? Container(
      width: MediaQuery.of(context).size.width,
     // height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 150.0),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      10, MediaQuery.of(context).size.height / 30, 10, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context).translate('details'),style: TextStyle(
                            color: GlobalVariables.white,fontSize: 18,
                          ),),
                        ),
                      ),
                      getBillDetailsLayout(),
                     /* Container(
                        margin: EdgeInsets.fromLTRB(
                            0, 20, 0, 0),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context).translate('charges'),style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18,
                          ),),
                        ),
                      ),*/
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          alignment : Alignment.bottomCenter,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: GlobalVariables.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(AppLocalizations.of(context).translate('paid_amount'),style: TextStyle(
                                    color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
                                ),),
                              ),
                              Container(
                                child: Text('Rs. '+double.parse((_receiptList[0].AMOUNT+double.parse(_receiptList[0].PENALTY_AMOUNT)).toString()).toStringAsFixed(2),style: TextStyle(
                                    color: GlobalVariables.red,fontSize: 18,fontWeight: FontWeight.bold
                                ),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ) : Container();
  }

  getBillDetailsLayout() {
    return _receiptList.length>0 ? Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GlobalVariables.white,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child:RichText(text: TextSpan(children: [
              TextSpan(
                text: AppLocalizations.of(context).translate('name'),
                style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                text: ": "+_receiptList[0].NAME,style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
          getDivider(),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child: RichText(text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context).translate('date'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                  text:  ": "+ (_receiptList[0].PAYMENT_DATE.length > 0 ? GlobalFunctions.convertDateFormat(_receiptList[0].PAYMENT_DATE,"dd-MM-yyyy") : "" ),
                  style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
          getDivider(),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child: RichText(text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context).translate('due_date'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                  text:  ": "+(_receiptList[0].PAYMENT_DATE.length > 0 ? GlobalFunctions.convertDateFormat(_receiptList[0].PAYMENT_DATE,"dd-MM-yyyy") : "" ),
                  style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
          getDivider(),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child:RichText(text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context).translate('transaction_mode'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                text: ': '+(_receiptList[0].TRANSACTION_MODE!=null ? _receiptList[0].TRANSACTION_MODE: '-'),
                  style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
          getDivider(),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child:RichText(text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context).translate('reference_no'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                text:  ": "+(_receiptList[0].REFERENCE_NO !=null ? _receiptList[0].REFERENCE_NO: '-'),
                  style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
          getDivider(),
          Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            child:RichText(text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context).translate('narration'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                  text:  ": "+(_receiptList[0].NARRATION!=null ? _receiptList[0].NARRATION : '-'),
                  style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
              )
            ])),
          ),
        ],
      ),
    ) : Container();
  }

  Future<void> getSharedPrefData() async {
    email = await GlobalFunctions.getUserName();
    name = await GlobalFunctions.getDisplayName();
    consumerId = await GlobalFunctions.getConsumerID();
    setState(() {});
  }

  getDivider() {

    return Container(
      child: Divider(
        color: GlobalVariables.mediumGreen,
        height: 3,
      ),
    );

  }

  getReceiptData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    restClientERP.getReceiptData(societyId, flat, block, invoiceNo,widget.yearSelectedItem).then((value) {
      _progressDialog.hide();
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;

      _receiptList = List<Receipt>.from(_list.map((i) => Receipt.fromJson(i)));

      setState(() {});

      //getAllBillData();
    })/*.catchError((Object obj) {
      //   if(_progressDialog.isShowing()){
      //    _progressDialog.hide();
      //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            //getAllBillData();
          }
          break;
        default:
      }
    })*/;
  }


  void emailReceiptDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter _stateState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = email;

              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    //  width: MediaQuery.of(context).size.width/2,
                    //  height: MediaQuery.of(context).size.height/3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                            GlobalFunctions.convertDateFormat(
                                _receiptList[0].PAYMENT_DATE,
                                'dd-MM-yyyy') /*+
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _receiptList[0].END_DATE, 'dd-MM-yyyy')*/,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Divider(
                            thickness: 1.5,
                            color: GlobalVariables.grey,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            // color: GlobalVariables.mediumGreen,
                            // margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                /*   Container(
                                child: Text(AppLocalizations.of(context).translate('email_bill_to'),style: TextStyle(
                                    color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.bold
                                ),),
                              ),*/
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: TextFormField(
                                      controller: _emailTextController,
                                      cursorColor: GlobalVariables.green,
                                      keyboardType: TextInputType.emailAddress,
                                      showCursor: isEditEmail ? true : false,
                                      decoration: InputDecoration(
                                        border: isEditEmail
                                            ? new UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.green))
                                            : InputBorder.none,
                                        contentPadding: EdgeInsets.all(5),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: !isEditEmail
                                        ? IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: GlobalVariables.green,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          _emailTextController.clear();
                                          isEditEmail = true;
                                          _stateState(() {});
                                        })
                                        : IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: GlobalVariables.grey,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          _emailTextController.clear();
                                          _emailTextController.text = email;
                                          isEditEmail = false;
                                          _stateState(() {});
                                        }),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          //height: 45,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width / 3,
                            child: RaisedButton(
                              color: GlobalVariables.green,
                              onPressed: () {
                                GlobalFunctions.checkInternetConnection()
                                    .then((internet) {
                                  if (internet) {
                                    if (_emailTextController.text.length > 0) {
                                      Navigator.of(context).pop();
                                      getReceiptMail(_receiptList[0].RECEIPT_NO, _emailTextController.text,widget.yearSelectedItem);
                                    } else {
                                      GlobalFunctions.showToast(
                                          'Please Enter Email ID');
                                    }
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context).translate(
                                            'pls_check_internet_connectivity'));
                                  }
                                });
                              },
                              textColor: GlobalVariables.white,
                              //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                  BorderSide(color: GlobalVariables.green)),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('email_now'),
                                style: TextStyle(
                                    fontSize: GlobalVariables.textSizeMedium),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            }));
  }

  Future<void> getReceiptMail(String invoice_no, String emailId,String year) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getReceiptMail(societyId, invoice_no, _emailTextController.text,year)
        .then((value) {
      print('Response : ' + value.toString());

      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
    }).catchError((Object obj) {
      if (_progressDialog.isShowing()) {
        _progressDialog.hide();
      }
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

}

class RecentTransaction {
  String transactionTitle;
  String transactionRs;

  RecentTransaction({this.transactionTitle, this.transactionRs});
}


