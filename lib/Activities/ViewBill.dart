import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BillDetails.dart';
import 'package:societyrun/Models/BillHeads.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseViewBill extends StatefulWidget {

  String invoiceNo,yearSelectedItem;
  String mBlock,mFLat;
  BaseViewBill(this.invoiceNo,this.yearSelectedItem,this.mBlock,this.mFLat);

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

  String name="",consumerId="",email="";
  String invoiceNo;
  double totalAmount=0.0;
  ViewBillState(this.invoiceNo);

  ProgressDialog _progressDialog;

  TextEditingController _emailTextController = TextEditingController();
  bool isEditEmail = false;
  String _taskId;
  ReceivePort _port = ReceivePort();

  bool isStoragePermission = false;

  @override
  void initState() {
    getSharedPrefData();
    //getTransactionList();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getBillData();

      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {
        if (status == DownloadTaskStatus.complete) {
          _openDownloadedFile(_taskId).then((success) {
            if (!success) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: text('Cannot open this file')));
            }
          });
        } else {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: text('Download failed!')));
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    send.send([id, status, progress]);
  }

  void downloadAttachment(var url, var _localPath) async {
    GlobalFunctions.showToast("Downloading attachment....");
    String localPath = _localPath + Platform.pathSeparator + "Download";
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    _taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: localPath,
      headers: {"auth": "test_for_sql_encoding"},
      //fileName: "SocietyRunImage/Document",
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
      true, // click on notification to open downloaded file (for Android)
    );
  }

  Future<bool> _openDownloadedFile(String id) {
    GlobalFunctions.showToast("Downloading completed");
    return FlutterDownloader.open(taskId: id);
  }


  @override
  Widget build(BuildContext context) {

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
            appBar: AppBar(
              backgroundColor: GlobalVariables.green,
              centerTitle: true,
              elevation: 0,
              actions: [
                AppIconButton(
                    Icons.mail,
                    iconColor: GlobalVariables.white,
                    onPressed: (){
                      emailBillDialog(context);
                    }),
                SizedBox(width: 16,),
                AppIconButton(
                    Icons.download_sharp,
                    iconColor: GlobalVariables.white,
                    onPressed: (){
                      if (isStoragePermission) {
                        print('true');
                        getPDF();
                      } else {
                        GlobalFunctions.askPermission(Permission.storage)
                            .then((value) {
                          if (value) {
                            getPDF();
                          } else {
                            GlobalFunctions.showToast(AppLocalizations.of(context)
                                .translate('download_permission'));
                          }
                        });
                      }

                    }),
                SizedBox(width: 16,),
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
                AppLocalizations.of(context).translate('bill')+ ' #'+invoiceNo,
                textColor: GlobalVariables.white,
              ),
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
            context, 150.0),
        SizedBox(
          child: _billDetailsList.length>0  ?
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: <Widget>[
                  AppContainer(
                    isListItem: true,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: secondaryText(GlobalFunctions.convertDateFormat(_billDetailsList[0].DUE_DATE,"dd-MM-yyyy"),textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium),
                        ),
                        SizedBox(height: 4,),
                        Container(
                          alignment: Alignment.center,
                          child: primaryText(GlobalFunctions.getCurrencyFormat(totalAmount.toString())/*double.parse(totalAmount.toString()).toStringAsFixed(2)*/,textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeXXLarge,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4,),
                        Container(
                          alignment: Alignment.center,
                          child: text(consumerId,textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeLargeMedium,maxLine: 3),
                        )
                      ],
                    ),
                  ),
                  AppContainer(
                    isListItem: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        primaryText("Details",),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: primaryText(AppLocalizations.of(context).translate('name')+ " : ",
                                textColor: GlobalVariables.black,fontWeight: FontWeight.normal
                              ),
                            ),
                            Container(
                              //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                              child: secondaryText(_billDetailsList[0].NAME??'',),
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: primaryText(AppLocalizations.of(context).translate('bill_period')+ " : ",
                                  textColor: GlobalVariables.black,fontWeight: FontWeight.normal
                              ),
                            ),
                            Container(
                              //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                              child: text(_billDetailsList[0]
                                  .TYPE
                                  .toLowerCase()
                                  .toString() ==
                                  'invoice' ?  'NA': (GlobalFunctions.convertDateFormat(_billDetailsList[0].START_DATE,"dd-MM-yyyy") + ' to ' + GlobalFunctions.convertDateFormat(_billDetailsList[0].END_DATE,"dd-MM-yyyy")),
                                  textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeSMedium
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppContainer(
                   isListItem: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        primaryText("Charges",textColor : GlobalVariables.green),
                        Divider(),
                        _billHeadsList.length>0 ? Builder(
                            builder: (context) => ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              // scrollDirection: Axis.vertical,
                              itemCount: _billHeadsList.length,
                              itemBuilder: (context, position) {
                                return Container(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                child: primaryText(_billHeadsList[position].HEAD_NAME,textColor: GlobalVariables.black,fontWeight: FontWeight.normal
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: secondaryText(/*'Rs. '+double.parse(_billHeadsList[position].AMOUNT).toStringAsFixed(2)*/GlobalFunctions.getCurrencyFormat(_billHeadsList[position].AMOUNT.toString()),textColor:  GlobalVariables.red,fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                       SizedBox(height: 4,)
                                      ],
                                    )
                                );
                              }, //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )):Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ) : SizedBox(),
        ),
        /*Padding(
          padding: EdgeInsets.only(left: 16.0,bottom: 8.0,right: 16.0,),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: AppButton(textContent: AppLocalizations.of(context).translate('pay_now'), onPressed: (){
                openBottomSheetPaymentLayout(value);
              }),
            ),
          ),
        )*/
      ],
    );
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
                    child: text(_billHeadsList[position].HEAD_NAME,textColor: GlobalVariables.grey,fontSize: GlobalVariables.textSizeLargeMedium),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: text(GlobalFunctions.getCurrencyFormat(_billHeadsList[position].AMOUNT.toString()),
                      textColor:  GlobalVariables.red,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.bold),
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
   // String flat = await GlobalFunctions.getFlat();
   // String block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    restClientERP.getBillData(societyId,widget.mFLat,widget.mBlock,invoiceNo,widget.yearSelectedItem).then((value) {
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
      BillHeads arrearsBillHeads = BillHeads();
      arrearsBillHeads.AMOUNT = double.parse(value.ARREARS.toString()).toStringAsFixed(2);
      arrearsBillHeads.HEAD_NAME="Arrears";
      totalAmount+= double.parse(value.ARREARS.toString());

      BillHeads penaltyBillHeads = BillHeads();
      penaltyBillHeads.AMOUNT = double.parse(value.PENALTY.toString()).toStringAsFixed(2);
      penaltyBillHeads.HEAD_NAME="Penalty";

      totalAmount+= double.parse(value.PENALTY.toString());
      _billHeadsList.add(arrearsBillHeads);
      _billHeadsList.add(penaltyBillHeads);

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


  void emailBillDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter _stateState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = email;

              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    //  width: MediaQuery.of(context).size.width/2,
                    //  height: MediaQuery.of(context).size.height/3,
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
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: primaryText(
                            'Send #'+_billDetailsList[0].INVOICE_NO+' on below email id',
                           /* GlobalFunctions.convertDateFormat(
                                _billDetailsList[0].START_DATE,
                                'dd-MM-yyyy') +
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _billDetailsList[0].END_DATE, 'dd-MM-yyyy')*/
                              textColor: GlobalVariables.green,
                              fontSize: GlobalVariables.textSizeSMedium,
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
                                    color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.bold
                                ),),
                              ),*/
                                Flexible(
                                  flex: 6,
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
                          height: 45,
                          child: AppButton(
                            textContent: AppLocalizations.of(context).translate('email_now'),
                            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            onPressed: () {
                              GlobalFunctions.checkInternetConnection()
                                  .then((internet) {
                                if (internet) {
                                  if (_emailTextController.text.length > 0) {
                                    Navigator.of(context).pop();
                                    getBillMail(
                                        _billDetailsList[0].INVOICE_NO,
                                        _billDetailsList[0].TYPE,
                                        _emailTextController.text,widget.yearSelectedItem);
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
                          ),
                        ),
                     /*   Container(
                          alignment: Alignment.topRight,
                          //height: 45,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width / 3,
                            child: RaisedButton(
                              color: GlobalVariables.green,
                              onPressed: () {

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
                                    textColor: GlobalVariables.white,
                                    fontSize: GlobalVariables.textSizeMedium,
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ));
            }));
  }

  Future<void> getBillMail(String invoice_no, String type, String emailId,String year) async {
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
   String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getBillMail(societyId, type, invoice_no, _emailTextController.text,year)
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

  Future<void> getPDF() async {

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getBillPDFData(societyId, widget.invoiceNo)
        .then((value) {
      print('Response : ' + value.dataString.toString());

      GlobalFunctions.convertBase64StringToFile(value.dataString,'Bill'+widget.invoiceNo+'.pdf').then((value) {

        if(value){
          GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_success'));
        }else{
          GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_failed'));
        }

      });
      _progressDialog.hide();
    }).catchError((Object obj) {
      print('obj : ' + obj.toString());
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
/*

  String _selectedPaymentGateway = "RazorPay";
  openBottomSheetPaymentLayout(UserManagementResponse value) {

    if (totalAmount > 0) {
      if (value.hasPayTMGateway && value.hasRazorPayGateway) {
        getListOfPaymentGateway(
            context,
            setState,
            0,
            value);
      } else {
        if (value.payOptionList[0].Status) {
          if (value.hasRazorPayGateway) {
            _selectedPaymentGateway = 'RazorPay';
            getListOfPaymentGateway(
                context,
                setState,
                0,
                value);
          } else if (value.hasPayTMGateway) {
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
                        shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),
                        backgroundColor:
                        Colors.transparent,
                        elevation: 0.0,
                        child: getListOfPaymentGateway(
                            context,
                            setState,
                            0,
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
      alreadyPaidDialog(0, value);
    }


   return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 50,
                height: 10,
                decoration: boxDecoration(
                    color: GlobalVariables.transparent,
                    radius: GlobalVariables.textSizeMedium,
                    bgColor: GlobalVariables.lightGray),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: GlobalVariables.white),
                // height: MediaQuery.of(context).size.width * 1.0,
                //child:
              )
            ],
          );
        });

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
                        iconColor: GlobalVariables.green,
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
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 150,
                          child: TextFormField(
                            controller: _amountTextController,
                            readOnly: isEditAmount ? false : true,
                            cursorColor: GlobalVariables.green,
                            showCursor: isEditAmount ? true : false,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: GlobalVariables.green,
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
                                iconColor: GlobalVariables.green,
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
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway !=
                                          "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
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
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway ==
                                          "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
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
                  color: GlobalVariables.green,
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
                                                */
/*shape: RoundedRectangleBorder(
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
                                  },
                                  child: text('Pay advance',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.green,
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
*/

}

class RecentTransaction {
  String transactionTitle;
  String transactionRs;

  RecentTransaction({this.transactionTitle, this.transactionRs});
}


