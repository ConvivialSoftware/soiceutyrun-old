import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BillDetails.dart';
import 'package:societyrun/Models/BillHeads.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseViewBill extends StatefulWidget {

  String invoiceNo;
  BaseViewBill(this.invoiceNo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewBillState(invoiceNo);
  }
}

class ViewBillState extends BaseStatefulState<BaseViewBill> {
  List<RecentTransaction> _recentTransactionList = new List<RecentTransaction>();
  BillViewResponse _billViewList = BillViewResponse();
  List<BillDetails> _billDetailsList = new List<BillDetails>();
  List<BillHeads> _billHeadsList = new List<BillHeads>();

  String name="",consumerId="";
  String invoiceNo;
  double totalAmount=0.0;
  ViewBillState(this.invoiceNo);

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    getSharedPrefData();
    getTransactionList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBillData();

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
            AppLocalizations.of(context).translate('bill')+ ' - '+invoiceNo,
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
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
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0, 20, 0, 0),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context).translate('charges'),style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18,
                          ),),
                        ),
                      ),
                      Flexible(
                      child : _billHeadsList.length>0 ? getBillChargesLayout() : Container(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
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
                                child: Text(AppLocalizations.of(context).translate('total_amount'),style: TextStyle(
                                    color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
                                ),),
                              ),
                              Container(
                                child: Text('Rs. '+totalAmount.toString(),style: TextStyle(
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
    );
  }

  getBillChargesLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(20)),
            child: Builder(
                builder: (context) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    //scrollDirection: Axis.vertical,
                    itemBuilder: (context, position) {
                      return getBillChargesItemLayout(position);
                    },
                    itemCount: _billHeadsList.length)),
          ),
        ],
      ),
    );
  }

  getTransactionList() {
    _recentTransactionList = [
      RecentTransaction(
        transactionTitle: "General Maintenance",
        transactionRs: "Rs. 1,347.00",
      ),
      RecentTransaction(
        transactionTitle: "Sinking Fund",
        transactionRs: "Rs. 57.00",
      ),
      RecentTransaction(
        transactionTitle: "Building Repairs Funds",
        transactionRs: "Rs. 86.00",
      ),
      RecentTransaction(
        transactionTitle: "Parking Charges",
        transactionRs: "Rs. 500.00",
      ),
      RecentTransaction(
        transactionTitle: "Water Charges",
        transactionRs: "Rs. 56.00",
      ),
      RecentTransaction(
        transactionTitle: "Build. Dev. Fund",
        transactionRs: "Rs. 285.00",
      ),
      RecentTransaction(
        transactionTitle: "Accounting Charges",
        transactionRs: "Rs. 135.00",
      ),
      RecentTransaction(
        transactionTitle: "Late Fees",
        transactionRs: "Rs. 0.00",
      ),
      RecentTransaction(
        transactionTitle: "SGST",
        transactionRs: "Rs. 0.00",
      ),
      RecentTransaction(
        transactionTitle: "CGST",
        transactionRs: "Rs. 1,347.00",
      ),
      RecentTransaction(
        transactionTitle: "Arrears",
        transactionRs: "Rs. 0.00",
      ),
      RecentTransaction(
        transactionTitle: "Late Fees/Interest",
        transactionRs: "Rs. 1,347.00",
      ),
    ];
  }

  getBillDetailsLayout() {
    return _billDetailsList.length>0 ? Container(
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
                text: ": "+_billDetailsList[0].NAME,style: TextStyle(color: GlobalVariables.grey,fontSize: 18)
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
                  text:  ": "+GlobalFunctions.convertDateFormat(_billDetailsList[0].C_DATE,"dd-MM-yyyy"),
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
                  text:  ": "+GlobalFunctions.convertDateFormat(_billDetailsList[0].DUE_DATE,"dd-MM-yyyy"),
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
                  text: AppLocalizations.of(context).translate('consumer_id'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                text: ': '+consumerId,
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
                  text: AppLocalizations.of(context).translate('bill_period'),
                  style: TextStyle(color: GlobalVariables.green,fontSize: 18)
              ),
              TextSpan(
                text:  ": "+GlobalFunctions.convertDateFormat(_billDetailsList[0].START_DATE,"dd-MM-yyyy") + ' to ' + GlobalFunctions.convertDateFormat(_billDetailsList[0].END_DATE,"dd-MM-yyyy"),
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
        color: GlobalVariables.mediumGreen,
        height: 3,
      ),
    );

  }

  getBillChargesItemLayout(int position) {

    return Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(_billHeadsList[position].HEAD_NAME,style: TextStyle(
                        color: GlobalVariables.grey,fontSize: 18
                    ),),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Text('Rs. '+_billHeadsList[position].AMOUNT,style: TextStyle(
                      color:  GlobalVariables.red,fontSize: 16,fontWeight: FontWeight.bold
                  ),),
                )
              ],
            ),
            position!=_recentTransactionList.length-1 ? Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Divider(
                color: GlobalVariables.lightGreen,
                height: 3,
              ),
            ):Container(),
          ],
        )
    );

  }

  getBillData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    restClientERP.getBillData(societyId,flat,block,invoiceNo).then((value) {
      print('Response : ' + value.toString());
      _billViewList = value;
      List<dynamic> _listBillDetails = value.BillDetails;
      List<dynamic> _listHeads = value.HEADS;


      print('_listBillDetails : ' + _listBillDetails.toString());
     // print("billdetails :" +_listBillDetails.toString());
     // print("billdetails length:" +_listBillDetails.length.toString());

      _billDetailsList = List<BillDetails>.from(_listBillDetails.map((i)=>BillDetails.fromJson(i)));
      _billHeadsList = List<BillHeads>.from(_listHeads.map((i)=>BillHeads.fromJson(i)));

      for(int i=0;i<_billHeadsList.length;i++){
        double amount = double.parse(_billHeadsList[i].AMOUNT);
        totalAmount+=amount;
      }
        _progressDialog.hide();
        setState(() {});

    })/*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
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


