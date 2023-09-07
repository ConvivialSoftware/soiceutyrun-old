import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bank.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAlreadyPaid extends StatefulWidget {
  bool isAdmin;
  Receipt? receiptData;
  String invoiceNo;
  double amount;
  double penaltyAmount;

  String mBlock;
  String mFlat;

  BaseAlreadyPaid(this.invoiceNo, this.amount, this.penaltyAmount,
      {this.receiptData,
      this.isAdmin = false,
      required this.mBlock,
      required this.mFlat});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AlreadyPaidState();
  }
}

class AlreadyPaidState extends State<BaseAlreadyPaid> {
  List<Bank> _bankList = <Bank>[];

  // List<BankResponse> _bankResponseList = new List<BankResponse>();
  String paymentType = "Cheque";

  //String complaintPriority="No";

  TextEditingController _chequeBankNameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  //TextEditingController _penaltyAmountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  List<String> _paidByList = <String>[];
  List<DropdownMenuItem<String>> _paidByListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedPaidBy;

  var insertedDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isValidate = true;

/*



  List<DropdownMenuItem<String>> __areaListItems = new List<DropdownMenuItem<String>>();
  String _areaSelectedItem;
*/

  List<DropdownMenuItem<String>> __bankListItems = <DropdownMenuItem<String>>[];

  String? _bankSelectedItem;
  String? _bankAccountNoSelectedItem;

  String? attachmentFilePath;
  String? attachmentFileName;
  String? attachmentCompressFilePath;

  ProgressDialog? _progressDialog;
  var amount = '0.00';

  /* String invoiceNo;
  double amount;*/
  // AlreadyPaidState(this.invoiceNo,this.amount);

  @override
  void initState() {
    super.initState();
    getPaidByData();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
   
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBankData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    if (widget.isAdmin) {
      if (widget.receiptData != null) {
        print('PAYMENT_DATE : ' + widget.receiptData!.PAYMENT_DATE!);
        _dateController.text = GlobalFunctions.convertDateFormat(
            widget.receiptData!.PAYMENT_DATE!, "dd-MM-yyyy");
        insertedDate = widget.receiptData!.PAYMENT_DATE;
        _chequeBankNameController.text = widget.receiptData!.CHEQUE_BANKNAME!;
        _noteController.text = widget.receiptData!.NARRATION!;
        _referenceController.text = widget.receiptData!.REFERENCE_NO!;
        paymentType = widget.receiptData!.TRANSACTION_MODE!;
      }
      amount = double.parse(widget.amount.toString()).toStringAsFixed(
          2); /*-
              double.parse(widget.penaltyAmount.toString()))*/
      amount = double.parse(amount) > 0
          ? _amountController.text =
              double.parse(amount.toString()).toStringAsFixed(2)
          : _amountController.text = '0.00';
    } else {
      amount = (double.parse(widget.amount.toString())).toStringAsFixed(2);
      amount = double.parse(amount) > 0
          ? _amountController.text =
              double.parse(amount.toString()).toStringAsFixed(2)
          : _amountController.text = '0.00';
      _dateController.text =
          DateTime.now().toLocal().day.toString().padLeft(2, '0') +
              "-" +
              DateTime.now().toLocal().month.toString().padLeft(2, '0') +
              "-" +
              DateTime.now().toLocal().year.toString();
      insertedDate = DateTime.now().toLocal().year.toString() +
          "-" +
          DateTime.now().toLocal().month.toString().padLeft(2, '0') +
          "-" +
          DateTime.now().toLocal().day.toString().padLeft(2, '0');
    }
/*    _penaltyAmountController.text =
        double.parse(widget.penaltyAmount.toString()).toStringAsFixed(2);*/
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    print('call build');
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: widget.isAdmin
              ? AppLocalizations.of(context).translate('add_receipt') +
                  ' ' +
                  widget.mBlock +
                  ' ' +
                  widget.mFlat
              : AppLocalizations.of(context).translate('already_paid'),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  void changePaidByDropDownItem(String? value) {
    setState(() {
      _selectedPaidBy = value;
      paymentType = value ?? '';
    });
  }

  void getPaidByData() {
    _paidByList = ["Cash", "Cheque", "NEFT/IMPS/UPI"];
    for (int i = 0; i < _paidByList.length; i++) {
      _paidByListItems.add(DropdownMenuItem(
        value: _paidByList[i],
        child: text(
          _paidByList[i],
          textColor: GlobalVariables.primaryColor,
        ),
      ));
    }
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        getAlreadyPaidLayout(),
      ],
    );
  }

  getAlreadyPaidLayout() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.fromLTRB(18, 40, 18, 40),
          padding: EdgeInsets.all(
              20), // height: MediaQuery.of(context).size.height / 0.5,
          decoration: BoxDecoration(
              color: GlobalVariables.white,
              borderRadius: BorderRadius.circular(10)),
          child: Container(
            child: Column(
              children: <Widget>[
                AppTextField(
                  textHintContent: widget.isAdmin
                      ? 'Receipt Date'
                      : AppLocalizations.of(context).translate('date'),
                  controllerCallback: _dateController,
                  readOnly: true,
                  contentPadding: EdgeInsets.only(top: 14),
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.secondaryColor,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        _dateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                        insertedDate = value.toLocal().year.toString() +
                            "-" +
                            value.toLocal().month.toString().padLeft(2, '0') +
                            "-" +
                            value.day.toString().padLeft(2, '0');
                      });
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.lightGray,
                        width: 2.0,
                      )),
                  child: ButtonTheme(
                    child: DropdownButtonFormField(
                      items: _paidByListItems,
                      value: _selectedPaidBy,
                      onChanged: changePaidByDropDownItem,
                      isExpanded: true,
                      icon: AppIcon(
                        Icons.keyboard_arrow_down,
                        iconColor: GlobalVariables.secondaryColor,
                      ),
                      decoration: InputDecoration(
                          //filled: true,
                          //fillColor: Hexcolor('#ecedec'),
                          labelText: AppLocalizations.of(context)
                                  .translate('paid_by') +
                              '*',
                          labelStyle: TextStyle(
                              color: GlobalVariables.lightGray,
                              fontSize: GlobalVariables.textSizeSMedium),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent))
                          // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                    ),
                  ),
                ),
                paymentType == "Cheque"
                    ? AppTextField(
                        textHintContent: AppLocalizations.of(context)
                            .translate('cheque_bank_name'),
                        controllerCallback: _chequeBankNameController,
                        /*inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(AppRegExpPattern.namePattern)),
                        ],*/
                        validator: (value) {
                          print('validate value : ' + value.toString());
                          if (!GlobalFunctions.isNameValid(value)) {
                            return AppLocalizations.of(context)
                                .translate('invalid_name');
                          }
                          return null;
                        },
                      )
                    : Container(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(
                      0, paymentType == "Cheque" ? 10 : 20, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.lightGray,
                        width: 2.0,
                      )),
                  child: ButtonTheme(
                    child: DropdownButtonFormField(
                      items: __bankListItems,
                      value: _bankSelectedItem,
                      onChanged: changeBankDropDownItem,
                      isExpanded: true,
                      icon: AppIcon(
                        Icons.keyboard_arrow_down,
                        iconColor: GlobalVariables.secondaryColor,
                      ),
                      /*underline: SizedBox(),
                    hint: text(
                      AppLocalizations.of(context).translate('select_bank')+'*',
                      textColor: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium,
                    ),*/
                      decoration: InputDecoration(
                          //filled: true,
                          //fillColor: Hexcolor('#ecedec'),
                          labelText: AppLocalizations.of(context)
                                  .translate('select_bank') +
                              '*',
                          labelStyle: TextStyle(
                              color: GlobalVariables.lightGray,
                              fontSize: GlobalVariables.textSizeSMedium),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent))
                          // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                    ),
                  ),
                ),
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('amount'),
                  controllerCallback: _amountController,
                  keyboardType: TextInputType.number,
                ),
                /*widget.isAdmin
                  ? AppTextField(
                      textHintContent: AppLocalizations.of(context)
                          .translate('penalty_amount'),
                      controllerCallback: _penaltyAmountController,
                      keyboardType: TextInputType.number,
                    )
                  : SizedBox(),*/
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('reference_no') +
                          '*',
                  controllerCallback: _referenceController,
                  /*inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.descriptionPattern)),
                  ],*/
                  validator: (value) {
                    print('validate value : ' + value.toString());
                    if (value.toString().length > 0 && !isValidate) {
                      if (!GlobalFunctions.isDescriptionValid(value)) {
                        return AppLocalizations.of(context)
                            .translate('invalid_reference_number');
                      }
                    }
                    return null;
                  },
                ),
                Container(
                  height: 150,
                  child: AppTextField(
                    textHintContent:
                        AppLocalizations.of(context).translate('enter_note'),
                    controllerCallback: _noteController,
                    /*inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.descriptionPattern)),
                    ],*/
                    validator: (value) {
                      print('validate value : ' + value.toString());
                      if (!GlobalFunctions.isDescriptionValid(value)) {
                        return AppLocalizations.of(context)
                            .translate('invalid_description');
                      }
                      return null;
                    },
                    maxLines: 999,
                    contentPadding: EdgeInsets.only(top: 14),
                  ),
                ),
                widget.isAdmin
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            attachmentFilePath == null
                                ? AppAssetsImage(
                                    GlobalVariables.componentUserProfilePath,
                                    imageWidth: 50.0,
                                    imageHeight: 50.0,
                                    borderColor: GlobalVariables.grey,
                                    borderWidth: 1.0,
                                    fit: BoxFit.cover,
                                    radius: 25.0,
                                  )
                                : attachmentFilePath!.contains(".pdf") ||
                                        attachmentFilePath!.contains(".doc")
                                    ? AppAssetsImage(
                                        attachmentFilePath!.contains(".pdf")
                                            ? GlobalVariables.pdfIconPath
                                            : GlobalVariables
                                                .documentImageIconPath,
                                        imageWidth: 60.0,
                                        imageHeight: 60.0,
                                        borderColor:
                                            GlobalVariables.transparent,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 30.0,
                                      )
                                    : AppFileImage(
                                        attachmentFilePath,
                                        imageWidth: 50.0,
                                        imageHeight: 50.0,
                                        borderColor: GlobalVariables.grey,
                                        borderWidth: 1.0,
                                        fit: BoxFit.cover,
                                        radius: 25.0,
                                      ),
                            Column(
                              children: <Widget>[
                                Container(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      openFile(context);
                                    },
                                    icon: AppIcon(
                                      Icons.attach_file,
                                      iconColor: GlobalVariables.secondaryColor,
                                      iconSize: 20.0,
                                    ),
                                    label: text(
                                        AppLocalizations.of(context)
                                            .translate('attach_photo'),
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: text('OR',
                                      textColor: GlobalVariables.lightGray,
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                                Container(
                                  child: TextButton.icon(
                                      onPressed: () {
                                        openCamera(context);
                                      },
                                      icon: AppIcon(
                                        Icons.camera_alt,
                                        iconColor:
                                            GlobalVariables.secondaryColor,
                                        iconSize: 20.0,
                                      ),
                                      label: text(
                                          AppLocalizations.of(context)
                                              .translate('take_picture'),
                                          textColor:
                                              GlobalVariables.primaryColor,
                                          fontSize:
                                              GlobalVariables.textSizeSMedium)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                Container(
                  alignment: Alignment.topLeft,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: AppButton(
                    textContent:
                        AppLocalizations.of(context).translate('submit'),
                    onPressed: () {
                      if (GlobalFunctions.textFormFieldValidate(_formKey)) {
                        verifyData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void changeBankDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _bankSelectedItem = value;
      for (int i = 0; i < _bankList.length; i++) {
        if (_bankSelectedItem == _bankList[i].BANK_NAME) {
          _bankAccountNoSelectedItem = _bankList[i].ACCOUNT_NO;
          break;
        }
      }
      print('_selctedItem:' + _bankSelectedItem.toString());
    });
  }

  getBankData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog!.show();
    restClientERP.getBankData(societyId, widget.invoiceNo).then((value) {
      print('Response : ' + value.toString());
      _progressDialog!.dismiss();
      List<dynamic> _list = value.bank!;

      _bankList = List<Bank>.from(_list.map((i) => Bank.fromJson(i)));

      //_categorySelectedItem = __categoryListItems[0].value;
      /*if (widget.receiptData != null) {
        getAmountCalculationData();
      }*/
      for (int i = 0; i < _bankList.length; i++) {
        __bankListItems.add(DropdownMenuItem(
          value: _bankList[i].BANK_NAME,
          child: text(
            _bankList[i].BANK_NAME,
            textColor: GlobalVariables.primaryColor,
          ),
        ));
        if (widget.isAdmin) {
          if (widget.receiptData != null) {
            if (widget.receiptData!.BANK_ACCOUNTNO == _bankList[i].ACCOUNT_NO) {
              _bankSelectedItem = _bankList[i].BANK_NAME;
              _bankAccountNoSelectedItem = _bankList[i].ACCOUNT_NO;
            }
          }
        }
      }
      print('bsnk list lenght : ' + _bankList.length.toString());
      setState(() {});
    });
  }

  getAmountCalculationData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    // _progressDialog.show();
    restClientERP
        .amountCalculation(
            societyId, widget.invoiceNo, widget.amount.toString())
        .then((value) {
      //print('Response : ' + value.toString());
      // _progressDialog.dismiss();
      print('bsnk list lenght : ' + value.toString());
      amount = (value.AMOUNT).toString();
      amount = double.parse(amount) > 0
          ? _amountController.text =
              double.parse(amount.toString()).toStringAsFixed(2)
          : _amountController.text = '0.00';
      //_penaltyAmountController.text = value.PENALTY.toString();
      setState(() {});
    });
  }

  Future<void> addPaymentRequest() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //  String block = await GlobalFunctions.getBlock();
    // String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    String? attachmentName;
    String? attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName!;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath!);
    }
/*
    print('Before : Date :'+_dateController.text);
    String date= GlobalFunctions.convertDateFormat(_dateController.text,"yyyy-MM-dd");
    print('Date :'+date);*/
    _progressDialog!.show();
    restClientERP
            .addAlreadyPaidPaymentRequest(
                societyId,
                widget.mFlat,
                widget.mBlock,
                widget.invoiceNo,
                _amountController.text,
                _referenceController.text,
                paymentType,
                _bankAccountNoSelectedItem!,
                insertedDate,
                userId,
                _noteController.text,
                _chequeBankNameController.text.toString(),
                attachment??'',
                "P",
               )
            .then((value) async {
      print("add paymentRequest response : " + value.toString());
      _progressDialog!.dismiss();
      if (value.status!) {
        //   Navigator.of(context).pop();
        if (attachmentFileName != null && attachmentFilePath != null) {
          await GlobalFunctions.removeFileFromDirectory(attachmentFilePath!);
          if (attachmentCompressFilePath!.endsWith(".jpg") ||
              attachmentCompressFilePath!.endsWith(".jpeg") ||
              attachmentCompressFilePath!.endsWith(".png")) {
            await GlobalFunctions.removeFileFromDirectory(
                attachmentCompressFilePath!);
          }
        }
        Provider.of<UserManagementResponse>(context, listen: false)
            .getLedgerData(null, widget.mBlock, widget.mFlat);
        getMessageInfo();
      }
      GlobalFunctions.showToast(value.message!);
    }) /*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    })*/
        ;
  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context, AppFileExtensions.allFileExtensions)
        .then((value) {
      attachmentFilePath = value;
      getCompressFilePath();
    });
  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath = value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath() {
    attachmentFileName = attachmentFilePath!.substring(
        attachmentFilePath!.lastIndexOf('/') + 1, attachmentFilePath!.length);
    print('file Name : ' + attachmentFileName.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      if (attachmentFileName!.contains(".pdf") ||
          attachmentFileName!.contains(".doc")) {
        attachmentCompressFilePath = attachmentFilePath;
        setState(() {});
      } else {
        GlobalFunctions.getFilePathOfCompressImage(attachmentFilePath!,
                value.toString() + '/' + attachmentFileName!)
            .then((value) {
          attachmentCompressFilePath = value.toString();
          print('Cache file path : ' + attachmentCompressFilePath!);
          setState(() {});
        });
      }
    });
  }

  void verifyData() {
    if (_noteController.text.length > 0 &&
        !GlobalFunctions.isDescriptionValid(_noteController.text)) {
      isValidate = false;
    } else {
      isValidate = true;
    }

    if (isValidate) {
      if (_bankSelectedItem != null) {
        if (_referenceController.text.length > 0) {
          if (double.parse(_amountController.text) > 0) {
            if (widget.isAdmin) {
              addApproveReceiptPaymentRequest();
            } else {
              addPaymentRequest();
            }
          } else {
            GlobalFunctions.showToast("Please Enter Valid Amount");
          }
        } else {
          GlobalFunctions.showToast("Please Enter Reference Number");
        }
      } else {
        GlobalFunctions.showToast("Please Select Paid to Bank");
      }
    } else {
      setState(() {});
      return;
    }
  }

  /*getMessageInfo() {

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      width: 250,
     // height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            //margin: EdgeInsets.all(5),
            child: Text(AppLocalizations.of(context).translate('already_paid_true_status'),style: TextStyle(
              color: GlobalVariables.grey, fontSize: 16
            ),),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            alignment: Alignment.topRight,
            child: TextButton(onPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }, child: Text(AppLocalizations.of(context).translate('close'),style: TextStyle(
              color: GlobalVariables.green,fontSize: 14
            ),),),
          ),
        ],
      ),
    );

  }*/

  getMessageInfo() {
    //print('paymentId : ' + paymentId.toString());
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
                            GlobalVariables.successIconPath,
                            imageWidth: 80,
                            imageHeight: 80,
                          ),
                        ),
                        /* Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('successful_payment'))),*/
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('already_paid_status'),
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeNormal,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                    .translate('already_paid_status_desc'),
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.normal)),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
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

  Future<void> addApproveReceiptPaymentRequest() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //  String block = await GlobalFunctions.getBlock();
    // String flat = await GlobalFunctions.getFlat();
    // String userId = await GlobalFunctions.getUserId();
    /* String attachmentName;
    String attachment;

    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }else{
      attachmentName="";
      attachment="";
    }*/
/*
    print('Before : Date :'+_dateController.text);
    String date= GlobalFunctions.convertDateFormat(_dateController.text,"yyyy-MM-dd");
    print('Date :'+date);*/
    _progressDialog!.show();
    restClientERP
        .addApproveReceiptRequest(
      societyId,
      widget.invoiceNo,
      widget.mBlock + ' ' + widget.mFlat,
      insertedDate,
      _amountController.text,
      //_penaltyAmountController.text,
      _referenceController.text,
      paymentType,
      _bankAccountNoSelectedItem!,
      widget.receiptData == null ? null : widget.receiptData!.ID,
      _noteController.text,
    )
        .then((value) {
      print("addApproveReceiptRequest : " + value.toString());
      _progressDialog!.dismiss();
      if (value.status!) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        /*if(attachmentFileName!=null && attachmentFilePath!=null){
          // GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
          GlobalFunctions.getTemporaryDirectoryPath()
              .then((value) {
            GlobalFunctions.removeAllFilesFromDirectory(
                value);
          });
        }*/
        //Provider.of<UserManagementResponse>(context, listen: false).getLedgerData(null,widget.mBlock,widget.mFlat);
        Provider.of<UserManagementResponse>(context, listen: false)
            .getMonthExpensePendingRequestData();
        //getMessageInfo();
      }
      GlobalFunctions.showToast(value.message!);
    });
  }
}
