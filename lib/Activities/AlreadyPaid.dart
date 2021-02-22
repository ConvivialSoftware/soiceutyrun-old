import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bank.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

import 'base_stateful.dart';

class BaseAlreadyPaid extends StatefulWidget {
  String invoiceNo;
  double amount;
  BaseAlreadyPaid(this.invoiceNo,this.amount);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AlreadyPaidState(invoiceNo,amount);
  }
}

class AlreadyPaidState extends BaseStatefulState<BaseAlreadyPaid> {

  List<Bank> _bankList = new List<Bank>();
 // List<BankResponse> _bankResponseList = new List<BankResponse>();
  String paymentType="Cheque";
  //String complaintPriority="No";

  TextEditingController _chequeBankNameController  =  TextEditingController();
  TextEditingController _amountController  =  TextEditingController();
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

  String invoiceNo;
  double amount;
  AlreadyPaidState(this.invoiceNo,this.amount);

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
    _dateController.text = DateTime.now().toLocal().day.toString().padLeft(2,'0')+"-"+DateTime.now().toLocal().month.toString().padLeft(2,'0')+"-"+DateTime.now().toLocal().year.toString();
    insertedDate = DateTime.now().toLocal().year.toString()+"-"+DateTime.now().toLocal().month.toString().padLeft(2,'0')+"-"+DateTime.now().toLocal().day.toString().padLeft(2,'0');
    _amountController.text=double.parse(amount.toString()).toStringAsFixed(2);
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
              Navigator.pop(context,'back');
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('already_paid'),
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
      height: MediaQuery.of(context).size.height,
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
                getAlreadyPaidLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAlreadyPaidLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              /*Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('raise_new_ticket'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),*/
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    style: TextStyle(
                        color: GlobalVariables.green
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        hintText: "Date",
                        hintStyle: TextStyle(color: GlobalVariables.veryLightGray),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: (){
                            // GlobalFunctions.showToast('iDate icon click');
                            GlobalFunctions.getSelectedDate(context).then((value){
                              _dateController.text = value.day.toString().padLeft(2,'0')+"-"+value.month.toString().padLeft(2,'0')+"-"+value.year.toString();
                              insertedDate =value.toLocal().year.toString()+"-"+value.toLocal().month.toString().padLeft(2,'0')+"-"+value.day.toString().padLeft(2,'0');
                            });
                          },
                          icon: Icon(
                            Icons.date_range,
                            color: GlobalVariables.mediumGreen,
                          ),
                        )),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                    color: paymentType== "Cheque" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: paymentType== "Cheque" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "Cheque",
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
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
                                    color: paymentType!= "Cheque" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: paymentType!= "Cheque" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "NEFT/IMPS",
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
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
              paymentType== "Cheque" ? Container(
                //  height: 150,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: _chequeBankNameController,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                      AppLocalizations.of(context).translate('cheque_bank_name'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ):Container(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, paymentType== "Cheque" ? 10:20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: __bankListItems,
                    value: _bankSelectedItem,
                    onChanged: changeBankDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('select_bank')+'*',
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              Container(
                //  height: 150,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  //readOnly: true,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                      AppLocalizations.of(context).translate('amount'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              Container(
                //  height: 150,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: _referenceController,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                      AppLocalizations.of(context).translate('reference_no')+'*',
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: TextField(
                  controller: _noteController,
                  maxLines: 99,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('enter_note'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width:50,
                      height: 50,
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      decoration: attachmentFilePath==null ? BoxDecoration(
                        color: GlobalVariables.mediumGreen,
                        borderRadius: BorderRadius.circular(25),

                      ) : BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: FileImage(File(attachmentFilePath)),
                              fit: BoxFit.cover
                          ),
                          border: Border.all(color: GlobalVariables.green,width: 2.0)
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
                            icon: Icon(
                              Icons.attach_file,
                              color: GlobalVariables.mediumGreen,
                            ),
                            label: Text(
                              AppLocalizations.of(context).translate('attach_photo'),
                              style: TextStyle(color: GlobalVariables.green),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            'OR',
                            style: TextStyle(color: GlobalVariables.lightGray),
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
                              icon: Icon(
                                Icons.camera_alt,
                                color: GlobalVariables.mediumGreen,
                              ),
                              label: Text(
                                AppLocalizations.of(context)
                                    .translate('take_picture'),
                                style: TextStyle(color: GlobalVariables.green),
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
                child: ButtonTheme(
                  // minWidth: MediaQuery.of(context).size.width/2,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {

                      verifyData();

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: GlobalVariables.green)),
                    child: Text(
                      AppLocalizations.of(context).translate('submit'),
                      style: TextStyle(fontSize: GlobalVariables.textSizeMedium),
                    ),
                  ),
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
    restClientERP.getBankData(societyId,invoiceNo).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.bank;

      _bankList = List<Bank>.from(_list.map((i)=>Bank.fromJson(i)));

      for(int i=0;i<_bankList.length;i++){
        __bankListItems.add(DropdownMenuItem(
          value: _bankList[i].BANK_NAME,
          child: Text(
            _bankList[i].BANK_NAME,
            style: TextStyle(color: GlobalVariables.green),
          ),
        ));
      }
      print('bsnk list lenght : '+_bankList.length.toString());
      //_categorySelectedItem = __categoryListItems[0].value;
      _progressDialog.hide();
      setState(() {
      });

    });
  }


  Future<void> addPaymentRequest() async {

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
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
    restClientERP.addAlreadyPaidPaymentRequest(societyId, flat, block,invoiceNo,_amountController.text,
        _referenceController.text,paymentType,_bankAccountNoSelectedItem,insertedDate,userId,_noteController.text,_chequeBankNameController.text.toString(),attachment,"P").then((value) {
      print("add paymentRequest response : "+ value.toString());
      _progressDialog.hide();
      if(value.status){
     //   Navigator.of(context).pop();
        if(attachmentFileName!=null && attachmentFilePath!=null){
          GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
        }
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

        addPaymentRequest();

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
                    borderRadius: BorderRadius.circular(25.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: GlobalVariables.transparent,
                   width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: SvgPicture.asset(
                          GlobalVariables.successIconPath,
                          width: 80,
                          height: 80,
                        ),
                      ),
                     /* Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('successful_payment'))),*/
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('already_paid_status'),style: TextStyle(
                            color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold
                          ),)
                      ),Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('already_paid_status_desc'),style: TextStyle(
                            color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.normal
                          ),)
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: Alignment.topRight,
                        child: FlatButton(onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }, child: Text(AppLocalizations.of(context).translate('okay'),style: TextStyle(
                            color: GlobalVariables.green,fontSize: 20,fontWeight: FontWeight.bold
                        ),),),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

}

