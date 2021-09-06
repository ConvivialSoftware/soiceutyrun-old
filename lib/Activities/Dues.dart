
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AlreadyPaid.dart';
import 'package:societyrun/Activities/DuesBillPayment.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseDues extends StatefulWidget {

  bool isAdmin;
  String mBlock,mFlat;
  BaseDues({this.isAdmin=false,this.mBlock,this.mFlat});

  @override
  _BaseDuesState createState() => _BaseDuesState();
}

class _BaseDuesState extends BaseStatefulState<BaseDues> {

  Razorpay _razorpay;
  String _selectedPaymentGateway = "RazorPay";
  Map<String, String> _duesMap = Map<String, String>();
  bool hasPayTMGateway = false;
  bool hasRazorPayGateway = false;
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _amountTextController = TextEditingController();
  bool isEditEmail = false;
  bool isEditAmount = false;
  var amount, invoiceNo, referenceNo, billType, orderId,duesRs = "", duesDate = "";

  var userId = "",
      societyId;
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';
  ProgressDialog _progressDialog;

  @override
  void initState() {
    print('_BaseDuesState init');
    getSharedPreferenceDuesData();
    getSharedPreferenceData();
    //if(widget.isAdmin)
      getDuesData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: widget.isAdmin ? AppBar(
              backgroundColor: GlobalVariables.primaryColor,
              centerTitle: true,
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
                widget.mBlock+' '+widget.mFlat+'-'+AppLocalizations.of(context).translate('dues'),
                textColor: GlobalVariables.white,
              ),
            ) : PreferredSize(child: SizedBox(), preferredSize: Size(0, 0),),
            backgroundColor: GlobalVariables.veryLightGray,
            body: value.isLoading ?GlobalFunctions.loadingWidget(context) : getMyDuesLayout(value),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    print('_BaseDuesState dispose');
    if (_razorpay != null) {
      _razorpay.clear();
    }
    super.dispose();
  }

  getSharedPreferenceDuesData() {
    GlobalFunctions.getSharedPreferenceDuesData().then((map) {
      _duesMap = map;
      duesRs = _duesMap[GlobalVariables.keyDuesRs];
      duesDate = _duesMap[GlobalVariables.keyDuesDate];
      setState(() {});
    });
  }

  getMyDuesLayout(UserManagementResponse value) {
    print('getMyDuesLayout Tab call');
    return GlobalVariables.isERPAccount
        ? SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
              context, 150.0),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Builder(
                      builder: (context) => ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: value.billList.length,
                        itemBuilder: (context, position) {
                          return getBillListItemLayout(
                              position, context, value);
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
                ),
                SizedBox(
                  height: 8,
                ),
                value.pendingList.length > 0
                    ? Container(
                  alignment: Alignment.topLeft,
                  //color: GlobalVariables.white,
                  margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: text(
                    AppLocalizations.of(context)
                        .translate('pending_transaction'),
                    textColor: GlobalVariables.black,
                    fontSize: GlobalVariables.textSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : Container(),
                value.pendingList.length > 0
                    ? Container(
                  margin: EdgeInsets.fromLTRB(16.0,16.0,16.0,8.0),
                  color: GlobalVariables.white,
                  child: Builder(
                      builder: (context) => ListView.builder(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount:
                        /*value.pendingList.length >= 3
                                        ? 3
                                        : */
                        value.pendingList.length,
                        itemBuilder: (context, position) {
                          return getPendingListItemLayout(
                              position, value);
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
                )
                    : Container(),
                SizedBox(
                  height: 8,
                ),
                value.ledgerList.length > 0
                    ? Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        //color: GlobalVariables.white,
                        child: text(
                          AppLocalizations.of(context)
                              .translate('recent_transaction'),
                          textColor: GlobalVariables.black,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseLedger(widget.mBlock,widget.mFlat)));
                        },
                        child: smallTextContainerOutlineLayout(
                            AppLocalizations.of(context)
                                .translate('see_all')),
                      )
                    ],
                  ),
                )
                    : Container(),
                value.ledgerList.length > 0
                    ? Container(
                  margin: EdgeInsets.all(16.0),
                  color: GlobalVariables.white,
                  child: Builder(
                      builder: (context) => ListView.builder(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: value.ledgerList.length >= 3
                            ? 3
                            : value.ledgerList.length,
                        itemBuilder: (context, position) {
                          return getListItemLayout(
                              position, value);
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
                )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    )
        : getNoERPAccountLayout();
  }


  getBillListItemLayout(
      int position, BuildContext context, UserManagementResponse value) {
    return Align(
      alignment: Alignment.center,
      child: AppContainer(
        isListItem: true,
        child: Stack(
          children: <Widget>[
            Container(
              //margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  GlobalVariables.whileBGPath,
                ),
              ),
            ),
            Container(
              //margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment:CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                          getBillTypeColor(value.billList[position].TYPE),
                        ),
                        child: text(
                          value.billList[position].TYPE != null
                              ? value.billList[position].TYPE == 'Bill'
                              ? 'Maintenance Bill'
                              : value.billList[position].TYPE
                              : '',
                          textColor: GlobalVariables.white,
                          fontSize: GlobalVariables.textSizeSmall,
                        ),
                      ),
                      (value.billList[position].AMOUNT -
                          value.billList[position].RECEIVED) <=
                          0
                          ? text(
                        'Paid',
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeSMedium,
                        fontWeight: FontWeight.bold,
                      )
                          : text(
                        getBillPaymentStatus(position, value),
                        textColor:
                        getBillPaymentStatusColor(position, value),
                        fontSize: GlobalVariables.textSizeSMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          GlobalFunctions.getCurrencyFormat((value.billList[position].AMOUNT -
                    value.billList[position].RECEIVED)
                        .toString()) ,/*+
                              double.parse((value.billList[position].AMOUNT -
                                  value.billList[position].RECEIVED)
                                  .toString())
                                  .toStringAsFixed(2)*/
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        text(
                          value.billList[position].DUE_DATE != null
                              ? GlobalFunctions.convertDateFormat(
                              value.billList[position].DUE_DATE,
                              "dd-MM-yyyy")
                              : '',
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: GlobalVariables.secondaryColor,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Divider(
                      height: 1,
                      color: GlobalVariables.secondaryColor,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (value.billList[position].TYPE
                                .toLowerCase()
                                .toString() ==
                                'bill' ||
                                value.billList[position].TYPE
                                    .toLowerCase()
                                    .toString() ==
                                    'invoice') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewBill(
                                          value.billList[position].INVOICE_NO,
                                          null,widget.mBlock,widget.mFlat)));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewReceipt(
                                          value.billList[position].INVOICE_NO,
                                          null,widget.mBlock,widget.mFlat)));
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.visibility,
                                    iconColor: GlobalVariables.secondaryColor,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('view'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        !widget.isAdmin ? InkWell(
                          onTap: () {
/*

                            if (value.payOptionList.length > 0) {
                              print(value.payOptionList[0].KEY_ID.toString());

                              if (value.payOptionList[0].KEY_ID != null &&
                                  value.payOptionList[0].KEY_ID.length > 0 &&
                                  value.payOptionList[0].SECRET_KEY != null &&
                                  value.payOptionList[0].SECRET_KEY.length > 0) {
                                hasRazorPayGateway = true;
                              }
                              if (value.payOptionList[0].PAYTM_URL != null &&
                                  value.payOptionList[0].PAYTM_URL.length > 0) {
                                hasPayTMGateway = true;
                              }
                              print('hasPayTMGateway' + hasPayTMGateway.toString());
                              print(
                                  'hasRazorPayGateway' + hasRazorPayGateway.toString());
                            }*/

                          /*  print(
                                'hasPayTMGateway' + hasPayTMGateway.toString());
                            print('hasRazorPayGateway' +
                                hasRazorPayGateway.toString());
                            _amountTextController.text = double.parse(
                                (value.billList[position].AMOUNT -
                                    value.billList[position].RECEIVED)
                                    .toString())
                                .toStringAsFixed(2);
                            amount = _amountTextController.text;
                            if (value.billList[position].AMOUNT -
                                value.billList[position].RECEIVED >
                                0) {
                              if (hasPayTMGateway && hasRazorPayGateway) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                            StateSetter setState) {
                                          return Dialog(
                                            *//*shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0)),*//*
                                            backgroundColor: Colors.transparent,
                                            elevation: 0.0,
                                            child: getListOfPaymentGateway(
                                                context,
                                                setState,
                                                position,
                                                value),
                                          );
                                        }));
                              } else {
                                if (value.payOptionList[0].Status) {
                                  if (hasRazorPayGateway) {
                                    _selectedPaymentGateway = 'RazorPay';
                                    //redirectToPaymentGateway(position);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            StatefulBuilder(builder:
                                                (BuildContext context,
                                                StateSetter setState) {
                                              return Dialog(
                                                *//*shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),*//*
                                                backgroundColor:
                                                Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position,
                                                    value),
                                              );
                                            }));
                                  } else if (hasPayTMGateway) {
                                    //Paytm Payment method execute

                                    _selectedPaymentGateway = 'PayTM';
                                    print('_selectedPaymentGateway' +
                                        _selectedPaymentGateway);

                                    //redirectToPaymentGateway(position);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            StatefulBuilder(builder:
                                                (BuildContext context,
                                                StateSetter setState) {
                                              return Dialog(
                                                *//*shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),*//*
                                                backgroundColor:
                                                Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position,
                                                    value),
                                              );
                                            }));
                                  } else {
                                    GlobalFunctions.showToast(
                                        "Online Payment Option is not available.");
                                  }
                                } else {
                                  GlobalFunctions.showToast(
                                      "Online Payment Option is not available.");
                                }
                              }
                            } else {
                              alreadyPaidDialog(position, value);
                            }*/
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseDuesBillPayment(value.billList[position])));
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.payment,
                                    iconColor: GlobalVariables.secondaryColor,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ):SizedBox(),
                        InkWell(
                          onTap: () {
                            emailBillDialog(context, position, value);
                            // getBillMail(value.billList[position].INVOICE_NO,value.billList[position].TYPE);
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.mail,
                                    iconColor: GlobalVariables.secondaryColor,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    !widget.isAdmin ? AppLocalizations.of(context)
                                        .translate('get_bill') : AppLocalizations.of(context).translate('send_bill'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if(!AppSocietyPermission.isSocHideAlreadyPaidPermission) {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseAlreadyPaid(
                                              value.billList[position]
                                                  .INVOICE_NO,
                                              value.billList[position].AMOUNT,
                                              widget.mBlock, widget.mFlat,value.billList[position].PENALTY_REM,isAdmin: widget.isAdmin,)));
                              if (result == 'back') {
                                Provider.of<UserManagementResponse>(context,
                                    listen: false)
                                    .getAllBillData(
                                    widget.mBlock, widget.mFlat);
                              }
                            }else{
                              GlobalFunctions.showAdminPermissionDialogToAccessFeature(context,true);
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: /*true ? */AppIcon(
                                    Icons.check_circle,
                                    iconColor: GlobalVariables.secondaryColor,
                                  ) //: AppAssetsImage(GlobalVariables.alreadyPaidImagePath,imageHeight: 18.0,imageWidth: 18.0,),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    !widget.isAdmin ? AppLocalizations.of(context)
                                        .translate('already_paid') : AppLocalizations.of(context).translate('payment'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getBillTypeColor(String billType) {
    switch (billType) {
      case "Bill":
        {
          return GlobalVariables.orangeYellow;
        }
        break;
      case "Electricity Bills":
        {
          return GlobalVariables.lightOrange;
        }
        break;
      case "Miscellaneous Bills":
        {
          return GlobalVariables.primaryColor;
        }
        break;
      default:
        {
          return GlobalVariables.skyBlue;
        }
        break;
    }
  }

  getPendingListItemLayout(var position, UserManagementResponse value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // SizedBox(height: 30,),
        Container(
          padding: EdgeInsets.all(5),
          color: GlobalVariables.AccentColor,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: text(
              value.pendingList[position].PAYMENT_DATE.length > 0
                  ? GlobalFunctions.convertDateFormat(
                  value.pendingList[position].PAYMENT_DATE, 'dd-MM-yyyy')
                  : "",
              textColor: GlobalVariables.grey,
              fontSize: GlobalVariables.textSizeSMedium,
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
                          value.pendingList[position].REFERENCE_NO,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseViewReceipt(
                                    null,
                                    /*UserManagementResponse.listYear[0].years*/
                                    null,widget.mBlock,widget.mFlat,receipt: value.pendingList[position],)));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          GlobalFunctions.getCurrencyFormat(value.pendingList[position].AMOUNT.toString())
                              /*double.parse(value.pendingList[position].AMOUNT
                                  .toString())
                                  .toStringAsFixed(2)*/,
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeSMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }

  duesLayout() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        // color: GlobalVariables.black,
        //width: MediaQuery.of(context).size.width / 1.2,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
          elevation: 1.0,
          margin: EdgeInsets.all(20),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    GlobalVariables.whileBGPath,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          AppLocalizations.of(context).translate('total_due'),
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),
                        text(
                          AppLocalizations.of(context).translate('due_date'),
                          textColor: GlobalVariables.secondaryColor,
                          fontSize: GlobalVariables.textSizeMedium,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          GlobalFunctions.getCurrencyFormat(duesRs),
                          textColor: GlobalVariables.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        text(
                          duesDate,
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Container(
                      color: GlobalVariables.secondaryColor,
                      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Divider(
                        height: 1,
                        color: GlobalVariables.secondaryColor,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: text(
                          AppLocalizations.of(context).translate('pay_now'),
                          textColor: GlobalVariables.primaryColor,
                          fontSize: GlobalVariables.textSizeMedium,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getBillPaymentStatus(int position, UserManagementResponse value) {
    String status = '';

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine =
    DateTime.parse(value.billList[position].DUE_DATE.toString());
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      status = "Overdue";
    } else if (days == 0) {
      status = "Due Today";
    } else if (days >= -2 && days < 0) {
      status = 'Due in ' + (days * (-1)).toString() + ' day';
    } else {
      status = 'Due Date';
    }
    return status;
  }

  getBillPaymentStatusColor(int position, UserManagementResponse value) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine =
    DateTime.parse(value.billList[position].DUE_DATE.toString());
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      return Color(0xFFc0392b);
    } else if (days == 0) {
      return Color(0xFFf39c12);
    } else if (days >= -2 && days < 0) {
      return Color(0xFFf39c12);
    } else {
      return GlobalVariables.secondaryColor;
    }
  }

  getListOfPaymentGateway(BuildContext context, StateSetter setState,
      int position, UserManagementResponse value) {
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
                    Align(
                      alignment: Alignment.topRight,
                      child: AppIconButton(
                        Icons.close,
                        iconColor: GlobalVariables.primaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
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
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 150,
                          child: TextFormField(
                            controller: _amountTextController,
                            readOnly: isEditAmount ? false : true,
                            cursorColor: GlobalVariables.primaryColor,
                            showCursor: isEditAmount ? true : false,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: GlobalVariables.primaryColor,
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
                                iconColor: GlobalVariables.primaryColor,
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
                    (hasPayTMGateway || hasRazorPayGateway)
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
                    hasRazorPayGateway
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
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway !=
                                          "PayTM"
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
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
                    hasPayTMGateway
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
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway ==
                                          "PayTM"
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
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
                  color: GlobalVariables.primaryColor,
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
                        redirectToPaymentGateway(
                            position, _amountTextController.text, value);
                      } else {
                        GlobalFunctions.showToast(
                            'Amount must be Grater or equal to Actual Amount');
                      }
                    } else {
                      Navigator.of(context).pop();
                      redirectToPaymentGateway(
                          position, _amountTextController.text, value);
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

  void redirectToPaymentGateway(
      int position, String textAmount, UserManagementResponse value) {
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
      getRazorPayOrderID(position, value.payOptionList[0].KEY_ID,
          value.payOptionList[0].SECRET_KEY, double.parse(textAmount), value);
    }
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
                        textColor: GlobalVariables.primaryColor,
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
                        textColor: GlobalVariables.primaryColor,
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
                      iconColor: GlobalVariables.primaryColor,
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
                    textColor: GlobalVariables.primaryColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  getListItemLayout(var position, UserManagementResponse value) {
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
              textColor: GlobalVariables.grey,
              fontSize: GlobalVariables.textSizeSMedium,
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
                          value.ledgerList[position].TYPE == 'Bill'
                              ? 'Maintenance Bill'
                              : value.ledgerList[position].TYPE,
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (value.ledgerList[position].TYPE
                            .toLowerCase()
                            .toString() ==
                            'bill' ||
                            value.ledgerList[position].TYPE
                                .toLowerCase()
                                .toString() ==
                                'invoice') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewBill(
                                      value.ledgerList[position].RECEIPT_NO,
                                      UserManagementResponse
                                          .listYear[0].years,widget.mBlock,widget.mFlat)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseViewReceipt(
                                      value.ledgerList[position].RECEIPT_NO,
                                      UserManagementResponse
                                          .listYear[0].years,widget.mBlock,widget.mFlat)));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: text(
                          GlobalFunctions.getCurrencyFormat(value.ledgerList[position].AMOUNT.toString())
                              /*double.parse(value.ledgerList[position].AMOUNT
                                  .toString())
                                  .toStringAsFixed(2)*/,
                          textColor: value.ledgerList[position].TYPE
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
              ],
            ))
      ],
    );
  }

  void alreadyPaidDialog(int position, UserManagementResponse value) {
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
                                                    position,
                                                    value),
                                              );
                                            }));
                                  },
                                  child: text('Pay advance',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.primaryColor,
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


  void emailBillDialog(
      BuildContext context, int position, UserManagementResponse value) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = email;

              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: AppIconButton(
                            Icons.close,
                            iconColor: GlobalVariables.grey,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: primaryText(
                            'Send #'+value.billList[position].INVOICE_NO+' on below email id',
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeSMedium
                            /*GlobalFunctions.convertDateFormat(
                                value.billList[position].START_DATE,
                                'dd-MMM-yy') +
                                ' To ' +
                                GlobalFunctions.convertDateFormat(
                                    value.billList[position].END_DATE,
                                    'dd-MMM-yy'),*/
                          ),
                        ),
                        Divider(),
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
                                    color: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.bold
                                ),),
                              ),*/
                                Flexible(
                                  flex: 6,
                                  child: Container(
                                    //margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: TextFormField(
                                      controller: _emailTextController,
                                      cursorColor: GlobalVariables.primaryColor,
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
                                        icon: AppIcon(
                                          Icons.edit,
                                          iconColor: GlobalVariables.primaryColor,
                                          iconSize: 24,
                                        ),
                                        onPressed: () {
                                          _emailTextController.clear();
                                          isEditEmail = true;
                                          setState(() {});
                                        })
                                        : IconButton(
                                        icon: AppIcon(
                                          Icons.cancel,
                                          iconColor: GlobalVariables.grey,
                                          iconSize: 24,
                                        ),
                                        onPressed: () {
                                          _emailTextController.clear();
                                          _emailTextController.text = email;
                                          isEditEmail = false;
                                          setState(() {});
                                        }),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          height: 45,
                          child: AppButton(
                            textContent: AppLocalizations.of(context).translate('email_now'),
                            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            onPressed: () {
                              GlobalFunctions.checkInternetConnection()
                                  .then((internet) {
                                if (internet) {
                                  if (_emailTextController.text.length >
                                      0) {
                                    Navigator.of(context).pop();
                                    getBillMail(
                                        value.billList[position].INVOICE_NO,
                                        value.billList[position].TYPE,
                                        _emailTextController.text,
                                        null);
                                  } else {
                                    GlobalFunctions.showToast(
                                        'Please Enter Email ID');
                                  }
                                } else {
                                  GlobalFunctions.showToast(AppLocalizations
                                      .of(context)
                                      .translate(
                                      'pls_check_internet_connectivity'));
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ));
            }));
  }

  getNoERPAccountLayout() {
    return Container(
      padding: EdgeInsets.all(50),
      //margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      color: GlobalVariables.white,
      //width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              GlobalVariables.creditCardPath,
              width: 300,
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: text(
              AppLocalizations.of(context).translate('erp_acc_not'),
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeLargeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width / 2,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: ButtonTheme(
              //minWidth: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                color: GlobalVariables.primaryColor,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseAboutSocietyRunInfo()));
                },
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.primaryColor)),
                child: text(
                  AppLocalizations.of(context).translate('i_am_interested'),
                  fontSize: GlobalVariables.textSizeMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                          iconColor: GlobalVariables.primaryColor,
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
                            textColor: GlobalVariables.primaryColor,
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
                          iconColor: GlobalVariables.primaryColor,
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

  void getRazorPayOrderID(int position, String razorKey, String secret_key,
      double textAmount, UserManagementResponse UserManagementResponse) {
    final dio = Dio();
    final RestClientRazorPay restClientRazorPay =
    RestClientRazorPay(dio, baseUrl: GlobalVariables.BaseRazorPayURL);
    amount = textAmount * 100;
    invoiceNo = UserManagementResponse.billList[position].INVOICE_NO;
    _progressDialog.show();
    RazorPayOrderRequest request = new RazorPayOrderRequest(
        amount: amount,
        currency: "INR",
        receipt: widget.mBlock + ' ' + widget.mFlat + '-' + invoiceNo,
        paymentCapture: 1);
    restClientRazorPay
        .getRazorPayOrderID(request, razorKey, secret_key)
        .then((value) {
      print('getRazorPayOrderID Response : ' + value.toString());
      orderId = value['id'];
      print('id : ' + orderId);
      postRazorPayTransactionOrderID(value['id'], value['amount'].toString(),
          position, UserManagementResponse);
    });
  }

  Future<void> postRazorPayTransactionOrderID(String orderId, String amount,
      int position, UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //String block = await GlobalFunctions.getBlock();
    //String flat = await GlobalFunctions.getFlat();

    restClientERP
        .postRazorPayTransactionOrderID(societyId, widget.mBlock + ' ' + widget.mFlat, orderId,
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

        openCheckOut(position, UserManagementResponse.payOptionList[0].KEY_ID,
            orderId, amount, UserManagementResponse);
      } else {
        GlobalFunctions.showToast(value.message);
      }
    });
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
        widget.mFlat,
        widget.mBlock,
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
              .getPayOption(widget.mBlock,widget.mFlat)
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

  void openCheckOut(int position, String razorKey, String orderId,
      String amount, UserManagementResponse UserManagementResponse) {
    //amount = value.billList[position].AMOUNT;
    invoiceNo = UserManagementResponse.billList[position].INVOICE_NO;
    billType = UserManagementResponse.billList[position].TYPE == 'Bill'
        ? 'Maintenance Bill'
        : UserManagementResponse.billList[position].TYPE;
    print('amount : ' + amount.toString());
    print('RazorKey : ' + razorKey.toString());

    var option = {
      'key': razorKey,
      'amount': amount,
      'name': societyName,
      'order_id': orderId,
      'description': widget.mBlock + ' ' + widget.mFlat + '-' + invoiceNo + '/' + billType,
      'prefill': {'contact': phone, 'email': email}
    };

    try {
      _razorpay.open(option);
    } catch (e) {
      debugPrint(e);
    }
  }

  Future<void> getBillMail(
      String invoice_no, String type, String emailId, String year) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getBillMail(
        societyId, type, invoice_no, _emailTextController.text, year)
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

  void getDuesData() {
    if (GlobalVariables.isERPAccount) {
      Provider.of<UserManagementResponse>(context, listen: false)
          .getPayOption(widget.mBlock,widget.mFlat)
          .then((payOptionList) {
        if (payOptionList.length > 0) {
          print(payOptionList[0].KEY_ID.toString());

          if (payOptionList[0].KEY_ID != null &&
              payOptionList[0].KEY_ID.length > 0 &&
              payOptionList[0].SECRET_KEY != null &&
              payOptionList[0].SECRET_KEY.length > 0) {
            hasRazorPayGateway = true;
          }
          if (payOptionList[0].PAYTM_URL != null &&
              payOptionList[0].PAYTM_URL.length > 0) {
            hasPayTMGateway = true;
          }
          print('hasPayTMGateway' + hasPayTMGateway.toString());
          print(
              'hasRazorPayGateway' + hasRazorPayGateway.toString());
        }
        setState(() {});
      });
    }
  }
}
