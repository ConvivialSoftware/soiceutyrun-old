import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseLedger extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LedgerState();
  }
}

class LedgerState extends BaseStatefulState<BaseLedger> {

  List<Ledger> _ledgerList = new List<Ledger>();

  List<OpeningBalance> _openingBalanceList = new List<OpeningBalance>();

  ProgressDialog _progressDialog;

  double totalOutStanding = 0;

  String openingBalance = "0.0";

  @override
  void initState() {
    super.initState();
    // getTransactionList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getLedgerData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

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
            AppLocalizations.of(context).translate('ledger'),
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
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      10, MediaQuery.of(context).size.height / 30, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text(
                          AppLocalizations.of(context).translate('ledger'),
                          style: TextStyle(
                              color: GlobalVariables.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: Container(
                          child: Icon(
                            Icons.filter,
                            color: GlobalVariables.mediumGreen,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                _ledgerList.length > 0
                    ? Container(
                        margin: EdgeInsets.fromLTRB(10,
                            MediaQuery.of(context).size.height / 12, 10, 100),
                        alignment: Alignment.topLeft,
                        //   margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        // padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: getRecentTransactionLayout(),
                      )
                    : Container(),
                _ledgerList.length > 0
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: GlobalVariables.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('total_outstanding'),
                                  style: TextStyle(
                                      color: GlobalVariables.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "Rs. " + totalOutStanding.toString(),
                                  style: TextStyle(
                                      color: GlobalVariables.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRecentTransactionLayout() {
    return SingleChildScrollView(
      child: Container(
        // padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('opening_balance'),
                        style: TextStyle(
                            color: GlobalVariables.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'Rs. ' + openingBalance,
                      style: TextStyle(
                          color: GlobalVariables.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Builder(
                  builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, position) {
                        return getDateTransactionItemLayout(position);
                      },
                      /* separatorBuilder: (context, position) {
                        return getDateWiseRecentTransactionLayout(position);
                      },*/
                      itemCount: _ledgerList.length)),
            )
          ],
        ),
      ),
    );
  }

  getDateTransactionItemLayout(int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          color: GlobalVariables.lightGreen,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              _ledgerList[position].C_DATE,
              style: TextStyle(color: GlobalVariables.grey, fontSize: 14),
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          _ledgerList[position].LEDGER,
                          style: TextStyle(
                              color: GlobalVariables.grey, fontSize: 18),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_ledgerList[position]
                                .TYPE
                                .toLowerCase()
                                .toString() ==
                            'bill' || _ledgerList[position]
                            .TYPE
                            .toLowerCase()
                            .toString() ==
                            'invoice') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewBill(
                                      _ledgerList[position].RECEIPT_NO)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewReceipt(
                                      _ledgerList[position].RECEIPT_NO)));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Rs. " + _ledgerList[position].AMOUNT.toString(),
                          style: TextStyle(
                              color: _ledgerList[position]
                                          .TYPE
                                          .toLowerCase()
                                          .toString() ==
                                      'bill'
                                  ? GlobalVariables.red
                                  : GlobalVariables.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
                position != _ledgerList.length - 1
                    ? Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Divider(
                          color: GlobalVariables.lightGreen,
                          height: 3,
                        ),
                      )
                    : Container(),
              ],
            ))
      ],
    );
  }

  /* getDateWiseRecentTransactionItemLayout(int position) {

    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(_ledgerList[position].LEDGER,style: TextStyle(
                      color: GlobalVariables.mediumGreen,fontSize: 18
                  ),),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Text(_ledgerList[position].AMOUNT.toString(),style: TextStyle(
                    color: _ledgerList[position].TYPE.toLowerCase().toString()=='bill' ? GlobalVariables.green: GlobalVariables.red,fontSize: 16
                ),),
              )
            ],
          ),
          position!=_ledgerList.length-1 ? Container(
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
*/
  /* getDateWiseRecentTransactionLayout(int position) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //  height: 100,
      child: Builder(
          builder: (context) => ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
              itemBuilder: (context, position) {
                return getDateWiseRecentTransactionItemLayout(position);
              },
              itemCount: _ledgerList.length)),
    );
  }*/

  getLedgerData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    restClientERP.getLedgerData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _listLedger = value.ledger;
      List<dynamic> _listOpeningBalance = value.openingBalance;

      //_ledgerResponseList = List<LedgerResponse>.from(_list.map((i)=>Documents.fromJson(i)));

      _ledgerList =
          List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
      _openingBalanceList = List<OpeningBalance>.from(
          _listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));

      openingBalance = _openingBalanceList[0].AMOUNT.toString();

      double totalAmount = 0;
      for (int i = 0; i < _listLedger.length; i++) {
        print("_ledgerList[i].RECEIPT_NO : "+_ledgerList[i].RECEIPT_NO.toString());
        print("_ledgerList[i].TYPE : "+_ledgerList[i].TYPE.toString());
        if (_ledgerList[i].TYPE.toLowerCase().toString() == 'bill') {
          totalAmount += double.parse(_ledgerList[i].AMOUNT);
        } else {
          totalAmount -= double.parse(_ledgerList[i].AMOUNT);
        }
        totalOutStanding = totalAmount + double.parse(openingBalance);
      }

      //_progressDialog.hide();
      Navigator.of(context).pop();
      setState(() {});
    });
  }
}

