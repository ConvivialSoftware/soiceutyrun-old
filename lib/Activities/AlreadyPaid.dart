import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
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

import 'base_stateful.dart';

class BaseAlreadyPaid extends StatefulWidget {
  bool isAdmin;
  Receipt receiptData;
  String invoiceNo;
  double amount;
  int penaltyAmount;
  String mBlock,mFlat;
  BaseAlreadyPaid(this.invoiceNo,this.amount,this.mBlock,this.mFlat,this.penaltyAmount,{this.receiptData,this.isAdmin=false});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AlreadyPaidState();
  }
}

class AlreadyPaidState extends State<BaseAlreadyPaid> {

  List<Bank> _bankList = new List<Bank>();
 // List<BankResponse> _bankResponseList = new List<BankResponse>();
  String paymentType="Cheque";
  //String complaintPriority="No";

  TextEditingController _chequeBankNameController  =  TextEditingController();
  TextEditingController _amountController  =  TextEditingController();
  TextEditingController _penaltyAmountController  =  TextEditingController();
  TextEditingController _noteController  =  TextEditingController();
  TextEditingController _referenceController  = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  var insertedDate;
/*



  List<DropdownMenuItem<String>> __areaListItems = new List<DropdownMenuItem<String>>();
  String _areaSelectedItem;
*/


  List<DropdownMenuItem<String>> __bankListItems =
  new List<DropdownMenuItem<String>>();

  String _bankSelectedItem;
  String _bankAccountNoSelectedItem;

  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;

  ProgressDialog _progressDialog;
  bool isStoragePermission=false;

 /* String invoiceNo;
  double amount;*/
 // AlreadyPaidState(this.invoiceNo,this.amount);

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission=value;
    });
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBankData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
    if(widget.isAdmin){
      if(widget.receiptData!=null) {
        print('PAYMENT_DATE : ' + widget.receiptData.PAYMENT_DATE);
        _dateController.text = GlobalFunctions.convertDateFormat(
            widget.receiptData.PAYMENT_DATE, "dd-MM-yyyy");
        insertedDate = widget.receiptData.PAYMENT_DATE;
        _chequeBankNameController.text = widget.receiptData.CHEQUE_BANKNAME;
        _noteController.text = widget.receiptData.NARRATION;
        _referenceController.text = widget.receiptData.REFERENCE_NO;
        paymentType = widget.receiptData.TRANSACTION_MODE;
      }
      _amountController.text=(double.parse(widget.amount.toString())-double.parse(widget.penaltyAmount.toString())).toStringAsFixed(2);
    }else {
      _amountController.text=(double.parse(widget.amount.toString())).toStringAsFixed(2);
      _dateController.text = DateTime
          .now()
          .toLocal()
          .day
          .toString()
          .padLeft(2, '0') + "-" + DateTime
          .now()
          .toLocal()
          .month
          .toString()
          .padLeft(2, '0') + "-" + DateTime
          .now()
          .toLocal()
          .year
          .toString();
      insertedDate = DateTime
          .now()
          .toLocal()
          .year
          .toString() + "-" + DateTime
          .now()
          .toLocal()
          .month
          .toString()
          .padLeft(2, '0') + "-" + DateTime
          .now()
          .toLocal()
          .day
          .toString()
          .padLeft(2, '0');
    }
    _penaltyAmountController.text=double.parse(widget.penaltyAmount.toString()).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    print('call build');
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: AppBar(
          backgroundColor: GlobalVariables.primaryColor,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context,'back');
            },
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          title: text(
            widget.isAdmin?AppLocalizations.of(context).translate('add_receipt')+' '+widget.mBlock+' '+widget.mFlat :AppLocalizations.of(context).translate('already_paid'),
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        getAlreadyPaidLayout(),
      ],
    );
  }

  getAlreadyPaidLayout() {
    return SingleChildScrollView(
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
                textHintContent:
                widget.isAdmin? 'Receipt Date' : AppLocalizations.of(context).translate('date'),
                controllerCallback: _dateController,
                readOnly: true,
                contentPadding: EdgeInsets.only(top: 14),
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.secondaryColor,
                  onPressed: () {
                    GlobalFunctions.getSelectedDate(context).then((value){
                      _dateController.text = value.day.toString().padLeft(2,'0')+"-"+value.month.toString().padLeft(2,'0')+"-"+value.year.toString();
                      insertedDate =value.toLocal().year.toString()+"-"+value.toLocal().month.toString().padLeft(2,'0')+"-"+value.day.toString().padLeft(2,'0');
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
/*
                          AppLocalizations.of(context)
                              .translate('personal')*/
                          paymentType = "Cheque";
                          setState(() {

                          });

                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: paymentType== "Cheque" ? GlobalVariables.primaryColor : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: paymentType== "Cheque" ? GlobalVariables.primaryColor : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: text(
                                  "Cheque",
                                  textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeMedium
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {

                          paymentType = "NEFT/IMPS";
                          setState(() {

                          });

                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: paymentType!= "Cheque" ? GlobalVariables.primaryColor : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: paymentType!= "Cheque" ? GlobalVariables.primaryColor : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: text(
                                  "NEFT/IMPS",
                                  textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              paymentType== "Cheque" ?
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('cheque_bank_name'),
                controllerCallback: _chequeBankNameController,
              ):Container(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, paymentType== "Cheque" ? 10:20, 0, 0),
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
                        labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent))
                      // border: new CustomBorderTextFieldSkin().getSkin(),
                    ),
                  ),
                ),
              ),
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('amount') ,
                controllerCallback: _amountController,
                keyboardType: TextInputType.number,
              ),
              widget.isAdmin ? AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('penalty_amount') ,
                controllerCallback: _penaltyAmountController,
                keyboardType: TextInputType.number,
              ):SizedBox(),
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('reference_no')+'*',
                controllerCallback: _referenceController,
              ),
              Container(
                height: 150,
                child: AppTextField(
                  textHintContent:
                  AppLocalizations.of(context).translate('enter_note'),
                  controllerCallback: _noteController,
                  maxLines: 99,
                  contentPadding: EdgeInsets.only(top: 14),
                ),
              ),
              widget.isAdmin ? SizedBox():Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width:50,
                      height: 50,
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      decoration: attachmentFilePath==null ? BoxDecoration(
                        color: GlobalVariables.secondaryColor,
                        borderRadius: BorderRadius.circular(25),

                      ) : BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: FileImage(File(attachmentFilePath)),
                              fit: BoxFit.cover
                          ),
                          border: Border.all(color: GlobalVariables.primaryColor,width: 2.0)
                      ),
                      //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: FlatButton.icon(
                            onPressed: () {

                              if(isStoragePermission) {
                                openFile(context);
                              }else{
                                GlobalFunctions.askPermission(Permission.storage).then((value) {
                                  if(value){
                                    openFile(context);
                                  }else{
                                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                  }
                                });
                              }

                            },
                            icon: AppIcon(
                              Icons.attach_file,
                              iconColor: GlobalVariables.secondaryColor,
                              iconSize: 20.0,
                            ),
                            label: text(
                              AppLocalizations.of(context).translate('attach_photo'),
                              textColor: GlobalVariables.primaryColor,
                                fontSize: GlobalVariables.textSizeSMedium
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: text(
                            'OR',
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium
                          ),
                        ),
                        Container(
                          child: FlatButton.icon(
                              onPressed: () {

                                if(isStoragePermission) {
                                  openCamera(context);
                                }else{
                                  GlobalFunctions.askPermission(Permission.storage).then((value) {
                                    if(value){
                                      openCamera(context);
                                    }else{
                                      GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                    }
                                  });
                                }

                              },
                              icon: AppIcon(
                                Icons.camera_alt,
                                iconColor: GlobalVariables.secondaryColor,
                                iconSize: 20.0,
                              ),
                              label: text(
                                AppLocalizations.of(context)
                                    .translate('take_picture'),
                                textColor: GlobalVariables.primaryColor,
                                fontSize: GlobalVariables.textSizeSMedium
                              )),
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
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeBankDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _bankSelectedItem = value;
      for(int i=0;i<_bankList.length;i++){
        if(_bankSelectedItem==_bankList[i].BANK_NAME){
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

    _progressDialog.show();
    restClientERP.getBankData(societyId,widget.invoiceNo).then((value) {
      print('Response : ' + value.toString());
      _progressDialog.hide();
      List<dynamic> _list = value.bank;

      _bankList = List<Bank>.from(_list.map((i)=>Bank.fromJson(i)));

      //_categorySelectedItem = __categoryListItems[0].value;
      if(widget.receiptData!=null) {
        getAmountCalculationData();
      }
      for(int i=0;i<_bankList.length;i++){
        __bankListItems.add(DropdownMenuItem(
          value: _bankList[i].BANK_NAME,
          child: text(
            _bankList[i].BANK_NAME,
            textColor: GlobalVariables.primaryColor,
          ),
        ));
        if(widget.isAdmin){
          if(widget.receiptData!=null) {
            if (widget.receiptData.BANK_ACCOUNTNO == _bankList[i].ACCOUNT_NO) {
              _bankSelectedItem = _bankList[i].BANK_NAME;
              _bankAccountNoSelectedItem = _bankList[i].ACCOUNT_NO;
            }
          }
        }
      }
      print('bsnk list lenght : '+_bankList.length.toString());
      setState(() {
      });

    });
  }
  getAmountCalculationData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

   // _progressDialog.show();
    restClientERP.amountCalculation(societyId,widget.invoiceNo,widget.amount.toString()).then((value) {
      //print('Response : ' + value.toString());
     // _progressDialog.hide();
      print('bsnk list lenght : '+value.toString());
      _amountController.text = (value.AMOUNT).toString();
      _penaltyAmountController.text = value.PENALTY.toString();
      setState(() {
      });

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
    String attachmentName;
    String attachment;

    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }else{
      attachmentName="";
      attachment="";
    }
/*
    print('Before : Date :'+_dateController.text);
    String date= GlobalFunctions.convertDateFormat(_dateController.text,"yyyy-MM-dd");
    print('Date :'+date);*/
    _progressDialog.show();
    restClientERP.addAlreadyPaidPaymentRequest(societyId, widget.mFlat, widget.mBlock,widget.invoiceNo,_amountController.text,
        _referenceController.text,paymentType,_bankAccountNoSelectedItem,insertedDate,userId,_noteController.text,_chequeBankNameController.text.toString(),attachment,"P").then((value) {
      print("add paymentRequest response : "+ value.toString());
      _progressDialog.hide();
      if(value.status){
     //   Navigator.of(context).pop();
        if(attachmentFileName!=null && attachmentFilePath!=null){
         // GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
          GlobalFunctions.getTemporaryDirectoryPath()
              .then((value) {
            GlobalFunctions.removeAllFilesFromDirectory(
                value);
          });
        }
        Provider.of<UserManagementResponse>(context, listen: false)
            .getLedgerData(null,widget.mBlock,widget.mFlat);
        getMessageInfo();
      }
      GlobalFunctions.showToast(value.message);

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

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath=value;
      getCompressFilePath();
    });

  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath=value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath(){
    attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
    print('file Name : '+attachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : '+value.toString());
      GlobalFunctions.getFilePathOfCompressImage(attachmentFilePath, value.toString()+'/'+attachmentFileName).then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : '+attachmentCompressFilePath);
        setState(() {
        });
      });
    });
  }

  void verifyData() {


    if(_bankSelectedItem.length>0){

      if(_referenceController.text.length>0){

        if(widget.isAdmin){
          addApproveReceiptPaymentRequest();
        }else {
          addPaymentRequest();
        }
      }else{
        GlobalFunctions.showToast("Please Enter Reference Number");
      }

    }else{
      GlobalFunctions.showToast("Please Select Paid to Bank");
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
            child: FlatButton(onPressed: (){
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
                  child:  Column(
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
                        child: text(AppLocalizations.of(context)
                            .translate('already_paid_status'),textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeNormal,fontWeight: FontWeight.bold
                        ),
                      ),Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(AppLocalizations.of(context)
                              .translate('already_paid_status_desc'),textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.normal
                          )
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: Alignment.topRight,
                        child: FlatButton(onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }, child: text(AppLocalizations.of(context).translate('okay'),textColor: GlobalVariables.primaryColor,fontSize: GlobalVariables.textSizeSMedium,fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
                )
              );
            }));
  }

  Future<void> addApproveReceiptPaymentRequest() async {

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //  String block = await GlobalFunctions.getBlock();
    // String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
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
    _progressDialog.show();
    restClientERP.addApproveReceiptRequest(societyId, widget.mBlock+' '+widget.mFlat,insertedDate,_amountController.text,_penaltyAmountController.text,
        _referenceController.text,paymentType,_bankAccountNoSelectedItem,widget.receiptData==null? null : widget.receiptData.ID,_noteController.text,).then((value) {
      print("addApproveReceiptRequest : "+ value.toString());
      _progressDialog.hide();
      if(value.status){
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
        Provider.of<UserManagementResponse>(context,listen: false).getMonthExpensePendingRequestData();
        //getMessageInfo();
      }
      GlobalFunctions.showToast(value.message);

    });


  }

}

