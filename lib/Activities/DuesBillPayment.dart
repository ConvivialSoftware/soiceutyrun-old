import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/LoginResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/ccavenue_response.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ccavenue_webview.dart';

const String ccavenuePayment = 'ccavenue';

class BaseDuesBillPayment extends StatefulWidget {
  Bills bills;

  BaseDuesBillPayment(this.bills);

  @override
  _BaseDuesBillPaymentState createState() => _BaseDuesBillPaymentState();
}

class _BaseDuesBillPaymentState extends State<BaseDuesBillPayment> {
  var amount = 0.0, invoiceNo, referenceNo, billType, orderId;
  ProgressDialog? _progressDialog;

  UPIPaymentApps selectedPaymentApp = UPIPaymentApps.googlepay;

  List<UPIPaymentApps> availebleUPIApps = [];

  Razorpay? _razorpay;
  var userId = "", societyId;
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';
  var displayAmount;
  bool _isBusy = false;

  void setBusy(value, state) {
    state(() {
      _isBusy = value;
    });
  }

  //(widget.bills.AMOUNT- widget.bills.RECEIVED)
  @override
  void initState() {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    displayAmount = (widget.bills.AMOUNT! - widget.bills.RECEIVED!);
    initAvailableUPIApps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSharedPreferenceData();

      Provider.of<UserManagementResponse>(context, listen: false)
          .getPayOption(null, null)
          .then((value) {
        _setSelectedPayment();
        Provider.of<UserManagementResponse>(context, listen: false)
            .getPaymentCharges();
      });
    });

    super.initState();
  }

  _setSelectedPayment() {
    Provider.of<UserManagementResponse>(context, listen: false).hasUPIGateway
        ? _selectedPaymentGateway = 'UPI'
        : Provider.of<UserManagementResponse>(context, listen: false)
                .hasCcAvenue
            ? _selectedPaymentGateway = ccavenuePayment
            : _selectedPaymentGateway = 'RazorPay';

    setState(() {});
  }

//get ios installed UPI apps
  initAvailableUPIApps() async {
    // if (Platform.isIOS) {
    //   UPIPaymentApps.values.forEach((upi) async {
    //     final isInstalled = await LaunchApp.isAppInstalled(
    //         iosUrlScheme: GlobalFunctions.getiOSUrlScheme(upi));
    //     selectedPaymentApp = upi;
    //     if (isInstalled) {
    //       availebleUPIApps.add(upi);
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    print('_BaseDuesState dispose');
    if (_razorpay != null) {
      _razorpay!.clear();
    }
    super.dispose();
  }

  // Widget _getPendingPaymentBanner(UpiPending pending) => Container(
  //       decoration: BoxDecoration(
  //           border: Border.all(color: GlobalVariables.darkRedColor, width: .3),
  //           borderRadius: BorderRadius.all(Radius.circular(8)),
  //           color: GlobalVariables.darkRedColor.withOpacity(.2)),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Icon(
  //             Icons.timelapse_outlined,
  //             color: GlobalVariables.darkRedColor,
  //           ).paddingAll(8),
  //           Flexible(
  //             child: text(
  //                 'We are still processing your previous transaction for amount ${pending.AMOUNT} (${pending.ORDER_ID}).+ We request you to wait for 30 mins. If you still wish to proceed with the current transaction, please proceed',
  //                 fontSize: 16,
  //                 textColor: GlobalVariables.darkRedColor),
  //           )
  //         ],
  //       ).paddingAll(8),
  //     ).paddingOnly(left: 16, right: 16, top: 16);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context, value, child) {
        return Scaffold(
          backgroundColor: GlobalVariables.veryLightGray,
          appBar: CustomAppBar(
            title: widget.bills.TYPE! == 'Bill'
                ? 'Maintenance Bill'
                : widget.bills.TYPE!,
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
  }

  getBaseDuesBillPaymentLayout(UserManagementResponse value) {
    return Stack(
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // value.pendingPayments.isNotEmpty
              //     ? _getPendingPaymentBanner(value.pendingPayments[0])
              //     : const SizedBox(),
            
              AppContainer(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text(
                        GlobalFunctions.getCurrencyFormat(
                            displayAmount.toString()),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeXLarge,
                        fontWeight: FontWeight.bold,
                        isCentered: true),
                    SizedBox(
                      height: 8,
                    ),
                    text(widget.bills.HEAD,
                        textColor: GlobalVariables.black,
                        isCentered: true,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                    SizedBox(
                      height: 8,
                    ),
                    text(
                        widget.bills.DUE_DATE?.isNotEmpty ?? false
                            ? 'Due On ' +
                                GlobalFunctions.convertDateFormat(
                                    widget.bills.DUE_DATE!, "dd MMM yyyy")
                            : '',
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium,
                        isCentered: true),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: value.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : AppButton(
                        textContent:
                            AppLocalizations.of(context).translate('pay_now'),
                        padding: EdgeInsets.all(12),
                        onPressed: () {
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

  String _selectedPaymentGateway = "";
  TextEditingController _amountTextController = TextEditingController();
  bool isEditAmount = false;

  void showBottomSheetForPaymentMethod(UserManagementResponse value) async {
    _amountTextController.clear();
    // amount = (widget.bills.AMOUNT - widget.bills.RECEIVED);
    _amountTextController.text = (displayAmount).toString();
    isEditAmount = false;

    if ((displayAmount) > 0) {
      if (value.payOptionList[0].Status!) {
        if (value.hasRazorPayGateway ||
            value.hasPayTMGateway ||
            value.hasUPIGateway ||
            value.hasCcAvenue) {
          final result = await showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: GlobalVariables.transparent,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      getListOfPaymentGateway(context, setState, value));
            },
          );

          // value.getAllBillData(
          //     widget.bills.BLOCK ?? '', widget.bills.FLAT ?? '');
        } else {
          showNoPaymentDialog(context);
        }
      } else {
        showNoPaymentDialog(context);
      }
    } else {
      alreadyPaidDialog(value);
    }
  }

  getListOfPaymentGateway(BuildContext context, StateSetter setState,
      UserManagementResponse value) {
    return Container(
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 16.0, top: 16.0),
                alignment: Alignment.topRight,
                child: AppIconButton(
                  Icons.close,
                  iconSize: 24.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
            Container(
              margin: EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: boxDecoration(
                  bgColor: GlobalVariables.AccentColor, radius: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 16),
                      child: AppAssetsImage(
                        GlobalVariables.receiptIconPath,
                        imageWidth: 30.0,
                        imageHeight: 30.0,
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
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
                              cursorColor: GlobalVariables.primaryColor,
                              showCursor: isEditAmount ? true : false,
                              //keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              enableInteractiveSelection: false,
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
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
                                  AppSocietyPermission
                                      .isSocPayAmountNoLessPermission)
                              ? Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: !isEditAmount
                                      ? IconButton(
                                          icon: AppIcon(
                                            Icons.edit,
                                            iconColor:
                                                GlobalVariables.primaryColor,
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
                                            _amountTextController.text =
                                                (displayAmount).toString();
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
            //payusing widget
            _buildPaymentOption(value, setState),
            SizedBox(
              height: 16,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: text('Preferred Method',
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeSMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      /*Container(
                                 margin: EdgeInsets.only(left: 16),
                                 child: text(' UPI : 0 Rs. \n Rupay Debit card : 0 Rs. \n Net Banking : 10 to 20 Rs.',textColor: GlobalVariables.black,fontSize: GlobalVariables.textSizeSMedium),
                               ),*/
                      Builder(builder: (context) {
                        final list = _selectedPaymentGateway == 'RazorPay'
                            ? value.preferredMethod
                            : _selectedPaymentGateway == ccavenuePayment
                                ? value.preferredMethodAvenue
                                : value.preferredMethodUPI;
                        return ListView.builder(
                            itemCount: list.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, position) {
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: text(
                                          list[position].variable! + " : ",
                                          fontSize:
                                              GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      child: text(
                                        list[position].value,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
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
                        child: text('Other Method',
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeSMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Builder(builder: (context) {
                        var list = _selectedPaymentGateway == 'RazorPay'
                            ? value.otherMethod
                            : _selectedPaymentGateway == ccavenuePayment
                                ? value.otherMethodAvenue
                                : value.otherMethodUPI;
                        return ListView.builder(
                            itemCount: list.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, position) {
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: text(
                                          list[position].variable! + " : ",
                                          fontSize:
                                              GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      child: text(
                                        list[position].value,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
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
            _selectedPaymentGateway == 'UPI'
                ? _getUpiPaymentApps(setState)
                : const SizedBox.shrink(),
            _isBusy
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(16),
                    //padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GlobalVariables.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: InkWell(
                      onTap: () {
                        print('amount : ' + (displayAmount).toString());
                        print('_amountTextController : ' +
                            _amountTextController.text.toString());
                        if (double.parse(_amountTextController.text) <= 0) {
                          GlobalFunctions.showToast(
                              'Amount must be greater than zero');
                        } else if (AppSocietyPermission
                            .isSocPayAmountNoLessPermission) {
                          if (double.parse((displayAmount).toString()) <=
                              double.parse(_amountTextController.text)) {
                            redirectToPaymentGateway(
                                _amountTextController.text, value, setState);
                          } else {
                            GlobalFunctions.showToast(
                                'Amount must be greater than or equal to actual amount');
                          }
                        } else {
                          redirectToPaymentGateway(
                              _amountTextController.text, value, setState);
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
        ));
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
                                    if (value.hasRazorPayGateway ||
                                        value.hasPayTMGateway ||
                                        value.hasUPIGateway ||
                                        value.hasCcAvenue) {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor:
                                            GlobalVariables.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (BuildContext context,
                                                      setState) =>
                                                  getListOfPaymentGateway(
                                                      context,
                                                      setState,
                                                      value));
                                        },
                                      );
                                    } else {
                                      showNoPaymentDialog(context);
                                    }
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

  void redirectToPaymentGateway(
      String textAmount, UserManagementResponse value, state) async {
    if (_selectedPaymentGateway == 'PayTM') {
      Navigator.of(context).pop();

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
      Navigator.of(context).pop();
      getRazorPayOrderID(value.payOptionList[0].KEY_ID!,
          value.payOptionList[0].SECRET_KEY!, double.parse(textAmount), value);
    } else if (_selectedPaymentGateway == 'UPI') {
      generateUPIRedirectLink(value, textAmount, state);
    } else if (_selectedPaymentGateway == ccavenuePayment) {
      startCCAvenuePayment(value, textAmount, state);
    }
  }

  void startCCAvenuePayment(
      UserManagementResponse value, textAmount, state) async {
    final bool hasInternet = await GlobalFunctions.checkInternetConnection();

    if (!hasInternet) {
      GlobalFunctions.showToast('No internet connection');
      return;
    }
    final tid = DateTime.now().millisecondsSinceEpoch.toString();

    final params = await getCcAvenueParams(textAmount, state, tid,
        value.payOptionList[0].CCAVENUE_ACCOUNT_ID ?? '');

    if (params.errorMessage != null) {
      GlobalFunctions.showToast(params.errorMessage ?? '');
      return;
    }

    final societyName = await GlobalFunctions.getSocietyName();
    final avenueTitle = '${widget.bills.BLOCK} - $societyName';

    Get.off(() => AvenueWebView(
          avenu: params,
          onTransactionCompleted: (paymentId) {
            checkPaymentStatus(paymentId);
          },
          title: avenueTitle,
        ));
  }

  Future<void> checkPaymentStatus(String orderId) async {
    // try {
    //   final dio = Dio();
    //   final RestClientERP restClient =
    //       RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);

    //   final socId = await GlobalFunctions.getSocietyId();

    //   final status = await restClient.getUPIStatus(socId, orderId);

    //   _handleFlowWithStatus(status);
    // } catch (e) {}
  }

  _handleFlowWithStatus(String status) {
    if (status == 'success') {
      GlobalFunctions.paymentSuccessDialog(context, '');
      return;
    } else if (status == 'failure') {
      GlobalFunctions.paymentFailureDialog(context);
      return;
    } else {
      GlobalFunctions.paymentFailureDialog(context);
      return;
    }
  }

  void generateUPIRedirectLink(
      UserManagementResponse value, textAmount, state) async {
    // final bool hasInternet = await GlobalFunctions.checkInternetConnection();

    // if (!hasInternet) {
    //   GlobalFunctions.showToast('No internet connection');
    //   return;
    // }

    // final tid = await getUPIOrderId(textAmount, state);

    // //validate the tid
    // if (tid.isEmpty) {
    //   GlobalFunctions.showToast(
    //       'Please try again. We are not able to generating Order ID.');

    //   return;
    // }

    // String payeeVpa = '';
    // String payeeName = '';
    // String ref = '';
    // String description =
    //     '${widget.bills.BLOCK} payment for invoice number:${widget.bills.INVOICE_NO ?? ''}';

    // final upiURL = value.payOptionList[0].UPI_URL ?? '';

    // final queryStringMap = Uri.parse(upiURL);

    // // final redirectionURL =
    // //     '$upiURL${widget.bills.BLOCK} ${widget.bills.FLAT}%${widget.bills.INVOICE_NO}&tid=$tid&tn=Payment for Society ${widget.bills.TYPE! == 'Bill' ? 'Maintenance Bill' : widget.bills.TYPE!} of ${GlobalFunctions.getFormattedDateForPayment(widget.bills.C_DATE ?? '')}&am=$textAmount&cu=INR';

    // queryStringMap.queryParameters.forEach((key, value) {
    //   if (key == 'pa') {
    //     payeeVpa = value;
    //   } else if (key == 'pn') {
    //     payeeName = value;
    //   } else if (key == 'tr') {
    //     ref = (value +
    //             '${widget.bills.BLOCK?.split(' ')[1]}${widget.bills.INVOICE_NO}')
    //         .replaceAll("%", '');
    //   }
    // });
    // Get.back();

    // if (Platform.isAndroid) {
    //   //todo debug this on ios
    //   try {
    //     Quantupi upi = Quantupi(
    //       receiverUpiId: payeeVpa,
    //       receiverName: payeeName,
    //       transactionRefId: ref,
    //       merchantId: '8699',
    //       orderId: tid,
    //       appname: QuantUPIPaymentApps.googlepay,
    //       transactionNote: description,
    //       amount: double.parse(textAmount),
    //     );

    //     final response = await upi.startTransaction();

    //     if (response.toLowerCase().contains('success')) {
    //       paymentSuccessDialog('');
    //     } else {
    //       //check payment status
    //       await checkPaymentStatus(tid);
    //     }
    //   } on Exception {
    //     paymentFailureDialog();
    //   }
    // } else {
    //   // final redirectionURL =
    //   //     '$upiURL${widget.bills.BLOCK} ${widget.bills.FLAT}%${widget.bills.INVOICE_NO}&tid=$tid&tn=Payment for Society ${widget.bills.TYPE! == 'Bill' ? 'Maintenance Bill' : widget.bills.TYPE!} of ${GlobalFunctions.getFormattedDateForPayment(widget.bills.C_DATE ?? '')}&am=$textAmount&cu=INR';

    //   final redirectionURL = GlobalFunctions.upiTransactionDetailsToString(
    //     amount: double.parse(textAmount),
    //     payeeAddress: payeeVpa,
    //     payeeName: payeeName,
    //     orderId: tid,
    //     appname: selectedPaymentApp,
    //     transactionNote: description,
    //     transactionRef: ref,
    //     merchantId: '8699',
    //   );
    //   final upiUri = Uri.parse(redirectionURL);

    //   final canLaunch = await canLaunchUrl(upiUri);

    //   if (canLaunch) {
    //     launchUrl(upiUri);
    //     //go to status check screen
    //     Get.to(() => UpicCountDownScreen(
    //           orderId: tid,
    //           onCompleted: () => _goBackAndRefresh(),
    //         ));
    //     return;
    //   } else {
    //     GlobalFunctions.showToast('Sorry, Unable to launch payment app');
    //   }
    // }
  }

  _goBackAndRefresh() async {
    Provider.of<UserManagementResponse>(context, listen: false)
        .getAllBillData(null, null);
    Provider.of<LoginDashBoardResponse>(context, listen: false).getDuesData();
    Get.back();
  }

  // sample dialog widget show the message
  void infoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _getUpiPaymentApps(StateSetter state) => Platform.isAndroid
      ? const SizedBox.shrink()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: text('UPI',
                  textColor: GlobalVariables.primaryColor,
                  fontSize: GlobalVariables.textSizeSMedium,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 4,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    availebleUPIApps.length,
                    (index) => Builder(builder: (context) {
                          final app = availebleUPIApps[index];
                          final selected =
                              selectedPaymentApp == availebleUPIApps[index];
                          return InkWell(
                            onTap: () {
                              state(() {
                                selectedPaymentApp = app;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: selected
                                      ? GlobalVariables.primaryColor
                                          .withOpacity(.7)
                                      : Colors.white,
                                  child: Opacity(
                                    opacity: 1,
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                        'assets/upi/${app.name}.png',
                                      ),
                                    ),
                                  ),
                                ).paddingSymmetric(horizontal: 8, vertical: 8),
                                SizedBox(
                                  height: 64,
                                  child: text(_getUPIAppName(app),
                                      isCentered: true,
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      fontWeight: selected
                                          ? FontWeight.w900
                                          : FontWeight.w400),
                                )
                              ],
                            ),
                          );
                        })),
              ),
            )
          ],
        ).paddingSymmetric(horizontal: 16);

  Future<String> getUPIOrderId(String amountToPay, state) async {
    // try {
    //   setBusy(true, state);
    //   final dio = Dio();
    //   final RestClientERP restClient =
    //       RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);

    //   final socId = await GlobalFunctions.getSocietyId();
    //   final userId = await GlobalFunctions.getUserId();

    //   final result = await restClient.getOrderId(
    //       socId,
    //       amountToPay,
    //       widget.bills.BLOCK ?? '',
    //       widget.bills.INVOICE_NO ?? '',
    //       userId,
    //       'upi');
    //   setBusy(false, state);
    //   return result;
    // } catch (e) {
    //   GlobalFunctions.showToast('Somthing went wrong');
    //   setBusy(false, state);
      return '';
    // }
  }

  Future<AvenueResponse> getCcAvenueParams(
      String amountToPay, state, String tid, String avenueSubAccId) async {
    try {
      setBusy(true, state);
      final dio = Dio();
      final RestClientERP restClient =
          RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);

      final societyId = await GlobalFunctions.getSocietyId();
      final phone = await GlobalFunctions.getMobile();

      final result = await restClient.getAvenueParams(
        tid,
        '+2657114',
        widget.bills.NAME ?? '',
        widget.bills.FLAT ?? '',
        widget.bills.BLOCK ?? '',
        phone,
        widget.bills.Email ?? '',
        amountToPay,
        widget.bills.INVOICE_NO ?? '',
        societyId,
        widget.bills.BLOCK ?? '',
        avenueSubAccId,
      );
      setBusy(false, state);
      return result;
    } catch (e) {
      setBusy(false, state);
      return AvenueResponse(errorMessage: 'Something went wrong');
    }
  }

  void getRazorPayOrderID(String razorKey, String secretKey, double textAmount,
      UserManagementResponse UserManagementResponse) {
    final dio = Dio();
    final RestClientRazorPay restClientRazorPay =
        RestClientRazorPay(dio, baseUrl: GlobalVariables.BaseRazorPayURL);
    amount = textAmount * 100;
    invoiceNo = widget.bills.INVOICE_NO;
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    _progressDialog!.show();
    RazorPayOrderRequest request = new RazorPayOrderRequest(
        amount: amount,
        currency: "INR",
        receipt: widget.bills.BLOCK! + '-' + invoiceNo,
        paymentCapture: 1);
    restClientRazorPay
        .getRazorPayOrderID(request, razorKey, secretKey)
        .then((value) {
      orderId = value['id'];
      postRazorPayTransactionOrderID(value['id'], value['amount'].toString(),
          UserManagementResponse, invoiceNo);
    });
  }

  Future<void> postRazorPayTransactionOrderID(String orderId, String amount,
      UserManagementResponse UserManagementResponse, String invoiceNo) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    restClientERP
        .postRazorPayTransactionOrderID(societyId, widget.bills.BLOCK!, orderId,
            (double.parse(amount) / 100).toString())
        .then((value) {
      _progressDialog!.dismiss();
      if (value.status!) {
        if (_razorpay != null) {
          _razorpay!.clear();
        }
        _razorpay = Razorpay();
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

        openCheckOut(UserManagementResponse.payOptionList[0].KEY_ID!, orderId,
            amount, UserManagementResponse);
      } else {
        GlobalFunctions.showToast(value.message!);
      }
    });
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razor Success Response : ' + response.toString());
    addOnlinePaymentRequest(response.paymentId!, 'success', response.orderId!);
  }

  _handlePaymentError(PaymentFailureResponse response) {
    print('Razor Error Response : ' + response.message!);
    addOnlinePaymentRequest('', 'failure', orderId);
  }

  _handleExternalWallet(ExternalWalletResponse response) {
    print('Razor ExternalWallet Response : ' + response.toString());
    GlobalFunctions.showToast(
        "ExternalWallet : " + response.walletName.toString());
  }

  void openCheckOut(String razorKey, String orderId, String amount,
      UserManagementResponse UserManagementResponse) {
    //amount = value.billList[position].AMOUNT;
    invoiceNo = widget.bills.INVOICE_NO;
    billType =
        widget.bills.TYPE == 'Bill' ? 'Maintenance Bill' : widget.bills.TYPE;
    print('amount : ' + amount.toString());
    print('RazorKey : ' + razorKey.toString());

    var option = {
      'key': razorKey,
      'amount': amount,
      'name': societyName,
      'order_id': orderId,
      'description': widget.bills.BLOCK! +
          ' ' +
          widget.bills.FLAT! +
          '-' +
          invoiceNo +
          '/' +
          billType,
      'prefill': {'contact': phone, 'email': email}
    };

    this.amount = double.parse(amount);
    try {
      _razorpay!.open(option);
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  Future<void> addOnlinePaymentRequest(
      String paymentId, String paymentStatus, String orderId) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    String paymentDate = DateTime.now().toLocal().year.toString() +
        "-" +
        DateTime.now().toLocal().month.toString().padLeft(2, '0') +
        "-" +
        DateTime.now().toLocal().day.toString().padLeft(2, '0');

    // amount = (amount / 100);
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    print("_progressDialog : " + _progressDialog.toString());
    _progressDialog!.show();
    restClientERP
        .addOnlinePaymentRequest(
            societyId,
            widget.bills.FLAT!,
            widget.bills.BLOCK!,
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
      _progressDialog!.dismiss();
      if (value.status!) {
        // Navigator.of(context).pop('back');
        if (paymentStatus == 'success') {
          displayAmount = (displayAmount - (amount / 100));

          Provider.of<UserManagementResponse>(context, listen: false)
              .getPayOption(widget.bills.BLOCK!, widget.bills.FLAT!)
              .then((value) {});
          Provider.of<LoginDashBoardResponse>(context, listen: false)
              .getDuesData()
              .then((value) {});
          setState(() {});
          paymentSuccessDialog(paymentId);
        } else {
          paymentFailureDialog();
        }
      } else {
        GlobalFunctions.showToast(value.message!);
      }
      //   amount = null;
      // invoiceNo = null;
      // billType = null;
      //orderId = null;
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

  paymentSuccessDialog(
    String paymentId,
  ) async {
    await showDialog(
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
                      paymentId.isEmpty
                          ? const SizedBox()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('transaction_id'),
                                      textColor: GlobalVariables.grey,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      fontWeight: FontWeight.normal),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: text(paymentId.toString(),
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('thank_you_payment'),
                            textColor: GlobalVariables.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }));

    _goBackAndRefresh();
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
                              textColor: GlobalVariables.grey,
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
                  child: TextButton(
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
                  child: TextButton(
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
                      FlutterClipboard.copy(consumerId).then((value) {
                        GlobalFunctions.showToast("Copied to Clipboard");
                        launch(
                            UserManagementResponse.payOptionList[0].PAYTM_URL!);
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

  Widget _buildPaymentOption(UserManagementResponse value, StateSetter state) =>
      Container(
        child: Column(children: [
          value.hasUPIGateway
              ? _buildPayOptionTile(
                  value: 'UPI',
                  icon: GlobalVariables.upiPayIconPath,
                  selected: _selectedPaymentGateway == "UPI",
                  onTap: () {
                    _selectedPaymentGateway = 'UPI';
                    state(() {});
                  })
              : SizedBox.shrink(),
          value.hasRazorPayGateway
              ? _buildPayOptionTile(
                  value: 'RazorPay',
                  icon: GlobalVariables.razorPayIconPath,
                  selected: _selectedPaymentGateway == "RazorPay",
                  onTap: () {
                    _selectedPaymentGateway = 'RazorPay';

                    state(() {});
                  })
              : SizedBox.shrink(),
          value.hasPayTMGateway
              ? _buildPayOptionTile(
                  value: 'PayTM',
                  icon: GlobalVariables.payTMIconPath,
                  selected: _selectedPaymentGateway == "PayTM",
                  onTap: () {
                    _selectedPaymentGateway = 'PayTM';
                    state(() {});
                  })
              : SizedBox.shrink(),
          value.hasCcAvenue
              ? _buildPayOptionTile(
                  value: ccavenuePayment,
                  icon: GlobalVariables.ccAvenuePayIconPath,
                  selected: _selectedPaymentGateway == ccavenuePayment,
                  onTap: () {
                    _selectedPaymentGateway = ccavenuePayment;
                    state(() {});
                  })
              : SizedBox.shrink()
        ]),
      );
}

String _getUPIAppName(UPIPaymentApps app) {
  String name = '';
  switch (app) {
    case UPIPaymentApps.googlepay:
      name = 'Google\nPay';
      break;
    case UPIPaymentApps.amazonpay:
      name = 'Amazon\nPay';
      break;
    case UPIPaymentApps.paytm:
      name = 'Paytm';
      break;
    case UPIPaymentApps.phonepe:
      name = 'PhonePe';
      break;
  }
  return name;
}

Widget _buildPayOptionTile(
        {required String value,
        required String icon,
        required bool selected,
        required VoidCallback onTap}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MaterialButton(
        onPressed: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  color: selected
                      ? GlobalVariables.primaryColor
                      : Colors.black12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_outlined,
                  color:
                      selected ? GlobalVariables.primaryColor : Colors.black12,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Image.asset(
                    icon,
                    height: 48,
                    width: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
showNoPaymentDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: AppContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: AppAssetsImage(
                          GlobalVariables.deactivateIconPath,
                          imageWidth: 80,
                          imageHeight: 80,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: text(
                            'Online payment option from app is not yet activated',
                            textColor: GlobalVariables.primaryColor,
                            isCentered: true,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              'Please contact society office or app support team for more information',
                              textColor: GlobalVariables.grey,
                              isCentered: true,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.normal)),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: text(
                              AppLocalizations.of(context).translate('okay'),
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ));
          }));
}

enum UPIPaymentApps { googlepay, amazonpay, paytm, phonepe }
