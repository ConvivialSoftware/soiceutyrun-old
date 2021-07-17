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
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BillDetails.dart';
import 'package:societyrun/Models/BillHeads.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseViewBill extends StatefulWidget {

  String invoiceNo,yearSelectedItem;
  BaseViewBill(this.invoiceNo,this.yearSelectedItem);

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
            SizedBox(width: 8,),
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
            SizedBox(width: 8,),
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
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        _billDetailsList.length>0  ?
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
                        child: primaryText('Rs. '+double.parse(totalAmount.toString()).toStringAsFixed(2),textColor: GlobalVariables.green,fontSize: GlobalVariables.textSizeXXLarge,fontWeight: FontWeight.bold),
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
                            child: secondaryText(_billDetailsList[0].NAME,),
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
                                            child: secondaryText('Rs. '+double.parse(_billHeadsList[position].AMOUNT).toStringAsFixed(2),textColor:  GlobalVariables.red,fontWeight: FontWeight.bold),
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
                  child: text('Rs. '+double.parse(_billHeadsList[position].AMOUNT).toStringAsFixed(2),
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
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    _progressDialog.show();
    restClientERP.getBillData(societyId,flat,block,invoiceNo,widget.yearSelectedItem).then((value) {
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
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    //  width: MediaQuery.of(context).size.width/2,
                    //  height: MediaQuery.of(context).size.height/3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: text(
                            GlobalFunctions.convertDateFormat(
                                _billDetailsList[0].START_DATE,
                                'dd-MM-yyyy') +
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _billDetailsList[0].END_DATE, 'dd-MM-yyyy'),
                              textColor: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeLargeMedium,
                                fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Divider(
                            thickness: 1.5,
                            color: GlobalVariables.grey,
                          ),
                        ),
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
                                  flex: 3,
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
                          //height: 45,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width / 3,
                            child: RaisedButton(
                              color: GlobalVariables.green,
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
                        ),
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
          GlobalFunctions.showToast('check Download folder');
        }else{
          GlobalFunctions.showToast('Download failed');
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

}

class RecentTransaction {
  String transactionTitle;
  String transactionRs;

  RecentTransaction({this.transactionTitle, this.transactionRs});
}


