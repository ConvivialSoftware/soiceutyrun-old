import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BillDetails.dart';
import 'package:societyrun/Models/BillHeads.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseViewReceipt extends StatefulWidget {

  String invoiceNo;
  BaseViewReceipt(this.invoiceNo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewReceiptState(invoiceNo);
  }
}

class ViewReceiptState extends BaseStatefulState<BaseViewReceipt> {
  ReceiptViewResponse _receiptViewList = ReceiptViewResponse();
  List<Receipt> _receiptList = new List<Receipt>();

  String name="",consumerId="";
  String invoiceNo,receiptPrefix='';
  ViewReceiptState(this.invoiceNo);

  ProgressDialog _progressDialog;

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
          backgroundColor: GlobalVariables.darkBlue,
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
            receiptPrefix+invoiceNo,
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
                                child: Text('Rs. '+_receiptList[0].AMOUNT.toString().toString(),style: TextStyle(
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
                style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
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
                  style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
              ),
              TextSpan(
                  text:  ": "+GlobalFunctions.convertDateFormat(_receiptList[0].PAYMENT_DATE,"dd-MM-yyyy"),
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
                  style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
              ),
              TextSpan(
                  text:  ": "+GlobalFunctions.convertDateFormat(_receiptList[0].PAYMENT_DATE,"dd-MM-yyyy"),
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
                  style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
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
                  style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
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
                  style: TextStyle(color: GlobalVariables.darkBlue,fontSize: 18)
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

  void getSharedPrefData() {

    GlobalFunctions.getDisplayName().then((value){
      name = value;
      GlobalFunctions.getConsumerID().then((val){
        consumerId=val;
        setState(() {
        });
      });
    });
  }

  getDivider() {

    return Container(
      child: Divider(
        color: GlobalVariables.mediumBlue,
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
    restClientERP.getReceiptData(societyId, flat, block, invoiceNo).then((value) {
      _progressDialog.hide();
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;
      receiptPrefix = value.RECEIPT_PREFIX;

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

}

class RecentTransaction {
  String transactionTitle;
  String transactionRs;

  RecentTransaction({this.transactionTitle, this.transactionRs});
}


