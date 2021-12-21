import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
//import 'package:societyrun/Models/MyUnitResponse.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseLedger extends StatefulWidget {

  String? mBlock,mFlat;
  BaseLedger(this.mBlock, this.mFlat);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LedgerState();
  }
}

class LedgerState extends State<BaseLedger> {
  ProgressDialog? _progressDialog;
  List<DropdownMenuItem<String>> _yearListItems =
      <DropdownMenuItem<String>>[];

  String? _yearSelectedItem;

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // getTransactionList();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getLedgerData(null);
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context).translate('ledger'),
            ),
            body: getBaseLayout(value),
          ),
        );
      }),
    );
  }

  getBaseLayout(UserManagementResponse value) {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        value.isLoading ? SizedBox() :
        Container(
          margin: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Container(
                  child: primaryText(
                    AppLocalizations.of(context).translate('ledger'),
                    textColor: GlobalVariables.white,
                        //fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: ButtonTheme(
                  //alignedDropdown: true,
                  child: DropdownButton(
                    items: _yearListItems,
                    onChanged: (value) {
                      _yearSelectedItem = value as String?;
                      print('_selctedItem:' +
                          _yearSelectedItem.toString());

                      getLedgerData(_yearSelectedItem);
                    },
                    value: _yearSelectedItem,
                    underline: SizedBox(),
                    isExpanded: true,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.white,
                    ),
                    iconSize: 20,
                    selectedItemBuilder: (BuildContext context) {
                      // String txt =  _societyListItems.elementAt(position).value;
                      return _yearListItems.map((e) {
                        return Container(
                            alignment: Alignment.center,
                            //margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                            child: text(
                              _yearSelectedItem,
                              textColor: GlobalVariables.white,
                                fontSize: GlobalVariables.textSizeSmall
                            ));
                      }).toList();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        value.isLoading ? GlobalFunctions.loadingWidget(context) :   value.ledgerList.length > 0
            ? Container(
                margin: EdgeInsets.fromLTRB(16, 70, 16, 100),
                alignment: Alignment.topLeft,
                //   margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                // padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10)),
                child: getRecentTransactionLayout(value),
              )
            : GlobalFunctions.noDataFoundLayout(context, "No Data Found"),
        value.isLoading ? SizedBox(): value.ledgerList.length > 0 ? Align(
                alignment: Alignment.bottomCenter,
                child: AppContainer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: primaryText(
                          AppLocalizations.of(context)
                              .translate('total_outstanding'),
                          textColor: GlobalVariables.black,
                        ),
                      ),
                      Container(
                        child: primaryText(
                          "Rs. " +
                              value.totalOutStanding.toStringAsFixed(2),
                          textColor: GlobalVariables.red,
                           // fontSize: GlobalVariables.textSizeLargeMedium
                        ),
                      )
                    ],
                  ),
                ),
              ) : SizedBox()

      ],
    );
  }

  getRecentTransactionLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Container(
        // padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (value.openingBalanceRemark.length > 0) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: text(
                                    value.openingBalanceRemark,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    maxLine: 99,
                                  ),
                                ),
                              ),
                            );
                          }));
                }
                // GlobalFunctions.showToast(openingBalanceRemark);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: primaryText(
                          AppLocalizations.of(context)
                              .translate('opening_balance'),
                          textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: primaryText(
                        'Rs. ' + value.openingBalance,
                        textColor: GlobalVariables.red,
                            //fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                        return getDateTransactionItemLayout(position, value);
                      },
                      /* separatorBuilder: (context, position) {
                        return getDateWiseRecentTransactionLayout(position);
                      },*/
                      itemCount: value.ledgerList.length)),
            )
          ],
        ),
      ),
    );
  }

  getDateTransactionItemLayout(int position, UserManagementResponse value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          color: GlobalVariables.AccentColor,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: text(
              value.ledgerList[position].C_DATE,
              textColor: GlobalVariables.grey, fontSize: GlobalVariables.textSizeSMedium,
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          value.ledgerList[position].LEDGER,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (value.ledgerList[position].TYPE!
                                    .toLowerCase()
                                    .toString() ==
                                'bill' ||
                            value.ledgerList[position].TYPE!
                                    .toLowerCase()
                                    .toString() ==
                                'invoice') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewBill(
                                      value.ledgerList[position].RECEIPT_NO,
                                      _yearSelectedItem,widget.mBlock,widget.mFlat)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewReceipt(
                                      value.ledgerList[position].RECEIPT_NO,
                                      _yearSelectedItem,widget.mBlock,widget.mFlat)));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          "Rs. " +
                              double.parse(value.ledgerList[position].AMOUNT
                                      .toString())
                                  .toStringAsFixed(2),
                          textColor: value.ledgerList[position].TYPE!
                                          .toLowerCase()
                                          .toString() ==
                                      'bill'
                                  ? GlobalVariables.red
                                  : GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                position != value.ledgerList.length - 1
                    ? Divider()
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

  getLedgerData(var year) async {
    Provider.of<UserManagementResponse>(context, listen: false)
        .getLedgerData(year,widget.mBlock!,widget.mFlat!)
        .then((value) {
      _yearListItems = <DropdownMenuItem<String>>[];
      if (UserManagementResponse.listYear.length > 0) {
        for (int i = 0; i < UserManagementResponse.listYear.length; i++) {
          print('_listYear : ' +
              UserManagementResponse.listYear[i].Active_account.toString());
          print('_listYear : ' + UserManagementResponse.listYear[i].years.toString());
          if (UserManagementResponse.listYear[i].Active_account
                  .toString()
                  .toLowerCase() ==
              'yes') {
            if (_yearListItems.length == 0) {
              _yearListItems.add(DropdownMenuItem(
                value: UserManagementResponse.listYear[i].years,
                child: text(
                  UserManagementResponse.listYear[i].years,
                  textColor: GlobalVariables.primaryColor,
                  fontSize: GlobalVariables.textSizeSmall
                ),
              ));
            } else {
              print('insert at 0 ');
              _yearListItems.insert(
                  0,
                  DropdownMenuItem(
                    value: UserManagementResponse.listYear[i].years,
                    child: text(
                      UserManagementResponse.listYear[i].years,
                      textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeSmall
                    ),
                  ));
              if (_yearSelectedItem == null) {
                _yearSelectedItem = UserManagementResponse.listYear[i].years;
                print('_yearSelectedItem : ' + _yearSelectedItem!);
              }
            }
          } else {
            _yearListItems.add(DropdownMenuItem(
              value: UserManagementResponse.listYear[i].years,
              child: text(
                UserManagementResponse.listYear[i].years,
                textColor: GlobalVariables.primaryColor,
                  fontSize: GlobalVariables.textSizeSmall
              ),
            ));
          }
        }
        if (_yearSelectedItem == null) {
          _yearSelectedItem = UserManagementResponse.listYear[0].years;
        }
      }
    });
  }
}
