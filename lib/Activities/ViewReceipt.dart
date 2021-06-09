import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

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
            AppIconButton(Icons.mail, onPressed: (){
              emailReceiptDialog(context);
            }),
          ],
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
            AppLocalizations.of(context).translate('receipt')+ ' #'+invoiceNo,
              textColor: GlobalVariables.white,
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

                _receiptList.length>0 ?   Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height / 20, 10, 0),
                      // margin: EdgeInsets.fromLTRB(10, 80, 10, 10),
                      padding: EdgeInsets.all(
                          16), // height: MediaQuery.of(context).size.height / 0.5,
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            child: text(GlobalFunctions.convertDateFormat(_receiptList[0].PAYMENT_DATE,"dd-MM-yyyy") ,textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium),
                          ),
                          SizedBox(height: 4,),
                          Container(
                            alignment: Alignment.center,
                            child: text('Rs. '+double.parse((_receiptList[0].AMOUNT+double.parse(_receiptList[0].PENALTY_AMOUNT)).toString()).toStringAsFixed(2),textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeXXLarge,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4,),
                          Container(
                            alignment: Alignment.center,
                            child: text(consumerId,textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeLargeMedium,maxLine: 3),
                          )
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
                      padding: EdgeInsets.all(
                          10), // height: MediaQuery.of(context).size.height / 0.5,
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: <Widget>[

                          Container(
                            margin: EdgeInsets.fromLTRB(
                                10, 5, 10, 0),
                            alignment: Alignment.topLeft,
                            child: text("Details",textColor : GlobalVariables.green,fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),


                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: text(AppLocalizations.of(context).translate('name')+ " : ",
                                      textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium
                                  ),
                                ),
                                Container(
                                  //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: text(_receiptList[0].NAME,
                                      textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium
                                  ),
                                )
                              ],
                            ),
                          ),


                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: text(AppLocalizations.of(context).translate('transaction_mode')+ " : ",
                                      textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium
                                  ),
                                ),
                                Container(
                                  //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: text(_receiptList[0].TRANSACTION_MODE!=null ? _receiptList[0].TRANSACTION_MODE: '-',
                                      textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: text(AppLocalizations.of(context).translate('reference_no')+ " : ",
                                      textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium
                                  ),
                                ),
                                Container(
                                  //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: text(_receiptList[0].REFERENCE_NO !=null ? _receiptList[0].REFERENCE_NO: '-',
                                      textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: text(AppLocalizations.of(context).translate('narration')+ " : ",
                                      textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeMedium
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    child: text(_receiptList[0].NARRATION!=null ? _receiptList[0].NARRATION : '-',
                                      textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium,maxLine: 99,)
                                    ,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) : SizedBox(),

              ],
            ),
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
                          child: text(
                            GlobalFunctions.convertDateFormat(
                                _receiptList[0].PAYMENT_DATE,
                                'dd-MM-yyyy') /*+
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _receiptList[0].END_DATE, 'dd-MM-yyyy')*/,
                              textColor: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeLargeMedium,
                                fontWeight: FontWeight.bold,
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
                                        ? AppIconButton(
                                          Icons.edit,
                                          iconColor: GlobalVariables.green,
                                          iconSize: 24,
                                        onPressed: () {
                                          _emailTextController.clear();
                                          isEditEmail = true;
                                          _stateState(() {});
                                        })
                                        : AppIconButton(
                                          Icons.cancel,
                                          iconColor: GlobalVariables.grey,
                                          iconSize: 24,
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
                              child: text(
                                AppLocalizations.of(context)
                                    .translate('email_now'),
                                    fontSize: GlobalVariables.textSizeMedium,
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


