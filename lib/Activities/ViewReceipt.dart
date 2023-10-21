import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AlreadyPaid.dart';
import 'package:societyrun/Activities/AppStatefulState.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseViewReceipt extends StatefulWidget {
  String? invoiceNo, yearSelectedItem;
  Receipt? receipt;
  String? mBlock, mFLat;
  Ledger? type;

  BaseViewReceipt(
      this.invoiceNo, this.yearSelectedItem, this.mBlock, this.mFLat,
      {this.receipt, this.type});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewReceiptState();
  }
}

class ViewReceiptState extends AppStatefulState<BaseViewReceipt> {
  ReceiptViewResponse _receiptViewList = ReceiptViewResponse();
  List<Receipt> _receiptList = <Receipt>[];

  String name = "", email = "";

  ProgressDialog? _progressDialog;
  TextEditingController _emailTextController = TextEditingController();
  bool isEditEmail = false;

  /*String _taskId;
  ReceivePort _port = ReceivePort();*/
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isCreditDebitNote = false;

  @override
  void initState() {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    isCreditDebitNote = widget.type?.TYPE?.toLowerCase() == 'credit note' ||
        widget.type?.PURPOSE?.toLowerCase() == 'debit note' ||
        widget.type?.TYPE?.toLowerCase() == 'payment';
    getSharedPrefData();
    if (!isCreditDebitNote) {
      if (widget.invoiceNo != null) {
        GlobalFunctions.checkInternetConnection().then((internet) {
          if (internet) {
            getReceiptData();
          } else {
            GlobalFunctions.showToast(AppLocalizations.of(context)
                .translate('pls_check_internet_connectivity'));
          }
        });
      } else {
        _receiptList.add(widget.receipt!);
      }
    } else {
      _receiptList.add(Receipt(
          NAME: widget.type?.NAME ?? '',
          AMOUNT: 1,
          RECEIPT_NO: widget.type?.RECEIPT_NO,
          FLAT_NO: widget.mFLat,
          PURPOSE: widget.type?.PURPOSE,
          PENALTY_AMOUNT: '0',
          STATUS: 'A',
          ATTACHMENT: '',
          INVOICE_NO: widget.type?.RECEIPT_NO,
          REFERENCE_NO: widget.type?.RECEIPT_NO,
          PAYMENT_DATE: widget.type?.C_DATE,
          NARRATION: widget.type?.NARRATION ?? ''));
    }
    /*IsolateNameServer.registerPortWithName(
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

    FlutterDownloader.registerCallback(downloadCallback);*/
    super.initState();
  }

  /*@override
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
  }*/

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          actions: _receiptList.length > 0 && _receiptList[0].STATUS == 'A'
              ? widget.type?.TYPE?.toLowerCase() == 'payment'
                  ? []
                  : [
                      AppIconButton(Icons.mail,
                          iconColor: GlobalVariables.white, onPressed: () {
                        emailReceiptDialog(context);
                      }),
                      SizedBox(
                        width: 16,
                      ),
                      AppIconButton(Icons.download_sharp,
                          iconColor: GlobalVariables.white, onPressed: () {
                        viewPdfOnline(
                            type: widget.type?.TYPE ?? '',
                            number: widget.invoiceNo ?? '');
                      }),
                      SizedBox(
                        width: 16,
                      ),
                    ]
              : [],
          title: isCreditDebitNote
              ? '${widget.type?.TYPE}#${widget.type?.RECEIPT_NO}'
              : _receiptList.length > 0 && _receiptList[0].STATUS == 'A'
                  ? AppLocalizations.of(context).translate('receipt') +
                      ' #' +
                      widget.invoiceNo!
                  : widget.receipt != null
                      ? widget.receipt!.FLAT_NO!
                      : '',
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return _receiptList.length > 0
        ? SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                _receiptList.length > 0
                    ? Column(
                        children: [
                          AppContainer(
                            child: Column(
                              //mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.topRight,
                                  child: text(
                                      isCreditDebitNote
                                          ? _receiptList[0].PAYMENT_DATE
                                          : GlobalFunctions.convertDateFormat(
                                              _receiptList[0].PAYMENT_DATE!,
                                              "dd-MM-yyyy"),
                                      textColor: GlobalVariables.grey,
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: text(
                                      isCreditDebitNote
                                          ? '₹ ${widget.type?.AMOUNT}'
                                          : GlobalFunctions.getCurrencyFormat(
                                              (_receiptList[0].AMOUNT! +
                                                      double.parse(_receiptList[
                                                                  0]
                                                              .PENALTY_AMOUNT ??
                                                          '0'))
                                                  .toString())
                                      /*  double.parse((_receiptList[0].AMOUNT +
                                                      double.parse(
                                                          _receiptList[0]
                                                              .PENALTY_AMOUNT??'0'))
                                                  .toString())
                                              .toStringAsFixed(2)*/
                                      ,
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeXXLarge,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: text(
                                      _receiptList[0].STATUS == 'A'
                                          ? ''
                                          : '*Unapproved Receipt',
                                      textColor: GlobalVariables.red,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      maxLine: 3),
                                )
                              ],
                            ),
                          ),
                          AppContainer(
                            isListItem: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                primaryText(
                                  "Details",
                                ),
                                Divider(),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: primaryText(
                                            AppLocalizations.of(context)
                                                    .translate('name') +
                                                " : ",
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Container(
                                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                        child: secondaryText(
                                            _receiptList[0].NAME ?? '',
                                            textColor: GlobalVariables.grey,
                                            fontSize: GlobalVariables
                                                .textSizeSMedium),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: primaryText(
                                            AppLocalizations.of(context)
                                                    .translate(
                                                        'transaction_mode') +
                                                " : ",
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Container(
                                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                        child: secondaryText(
                                            _receiptList[0].TRANSACTION_MODE !=
                                                    null
                                                ? _receiptList[0]
                                                    .TRANSACTION_MODE
                                                : '-',
                                            textColor: GlobalVariables.grey,
                                            fontSize: GlobalVariables
                                                .textSizeSMedium),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: primaryText(
                                            AppLocalizations.of(context)
                                                    .translate('reference_no') +
                                                " : ",
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Container(
                                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                        child: secondaryText(
                                            _receiptList[0].REFERENCE_NO != null
                                                ? _receiptList[0].REFERENCE_NO
                                                : '-',
                                            textColor: GlobalVariables.grey,
                                            fontSize: GlobalVariables
                                                .textSizeSMedium),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  child: Row(
                                    //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: primaryText(
                                            AppLocalizations.of(context)
                                                    .translate('narration') +
                                                " : ",
                                            textColor: GlobalVariables.black,
                                            fontSize:
                                                GlobalVariables.textSizeMedium,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Flexible(
                                        child: Container(
                                          child: secondaryText(
                                            _receiptList[0].NARRATION != null
                                                ? _receiptList[0].NARRATION
                                                : '-',
                                            textColor: GlobalVariables.grey,
                                            fontSize:
                                                GlobalVariables.textSizeSMedium,
                                            maxLine: 99,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _receiptList[0].ATTACHMENT!.isNotEmpty
                              ? AppContainer(
                                  isListItem: true,
                                  child: InkWell(
                                    onTap: () {
                                      print(_receiptList[0].ATTACHMENT);
                                      downloadAttachment(
                                          _receiptList[0].ATTACHMENT);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            AppIcon(
                                              Icons.attachment,
                                              iconColor:
                                                  GlobalVariables.skyBlue,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Flexible(
                                              child: text(
                                                  AppLocalizations.of(context)
                                                      .translate('attachment'),
                                                  fontSize: GlobalVariables
                                                      .textSizeSMedium,
                                                  textColor:
                                                      GlobalVariables.skyBlue),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            if (downloading)
                                              Stack(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                children: [
                                                  Container(
                                                    //height: 20,
                                                    //width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      //value: 71.0,
                                                    ),
                                                  ),
                                                  //SizedBox(width: 4,),
                                                  Container(
                                                      child: text(
                                                          downloadRate
                                                              .toString(),
                                                          fontSize:
                                                              GlobalVariables
                                                                  .textSizeSmall,
                                                          textColor:
                                                              GlobalVariables
                                                                  .skyBlue))
                                                ],
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          AppUserPermission.isUserAccountingPermission &&
                                  _receiptList[0].STATUS != 'A'
                              ? Container(
                                  margin: EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 120,
                                        child: AppButton(
                                            textContent:
                                                AppLocalizations.of(context)
                                                    .translate('cancel')
                                                    .toString()
                                                    .toUpperCase(),
                                            onPressed: () {
                                              cancelReceiptRequest(
                                                  _receiptList[0].ID!);
                                            }),
                                      ),
                                      Container(
                                        width: 120,
                                        child: AppButton(
                                            textContent:
                                                AppLocalizations.of(context)
                                                    .translate('approve'),
                                            onPressed: () {
                                              List<String> arr = _receiptList[0]
                                                  .FLAT_NO!
                                                  .split(" ");

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BaseAlreadyPaid(
                                                            _receiptList[0]
                                                                .INVOICE_NO!,
                                                            _receiptList[0]
                                                                .AMOUNT!
                                                                .toDouble(),
                                                            double.parse(
                                                                _receiptList[0]
                                                                    .PENALTY_AMOUNT!),
                                                            receiptData:
                                                                _receiptList[0],
                                                            isAdmin: true,
                                                            mBlock:
                                                                arr[0].trim(),
                                                            mFlat:
                                                                arr[1].trim(),
                                                          )));
                                            }),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          )
        : Container();
  }

  Future<void> getSharedPrefData() async {
    email = await GlobalFunctions.getUserName();
    name = await GlobalFunctions.getDisplayName();
    //consumerId = await GlobalFunctions.getConsumerID();
    setState(() {});
  }

  getDivider() {
    return Container(
      child: Divider(
        color: GlobalVariables.secondaryColor,
        height: 3,
      ),
    );
  }

  getReceiptData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    if (widget.mBlock == null) {
      widget.mBlock = await GlobalFunctions.getBlock();
    }
    if (widget.mFLat == null) {
      widget.mFLat = await GlobalFunctions.getFlat();
    }
    _progressDialog!.show();
    restClientERP
            .getReceiptData(societyId, widget.mFLat!, widget.mBlock!,
                widget.invoiceNo!, widget.yearSelectedItem)
            .then((value) {
      _progressDialog!.dismiss();
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data!;

      _receiptList = List<Receipt>.from(_list.map((i) => Receipt.fromJson(i)));

      setState(() {});

      //getAllBillData();
    }) /*.catchError((Object obj) {
      //   if(_progressDialog.isShowed){
      //    _progressDialog.dismiss();
      //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            //getAllBillData();
          }
          break;
        default:
      }
    })*/
        ;
  }

  void emailReceiptDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter _stateState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = (_receiptViewList.Email != null
                      ? _receiptViewList.Email
                      : email)!;

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
                            'Send #' +
                                _receiptList[0].RECEIPT_NO! +
                                ' on below email id',
                            /* GlobalFunctions.convertDateFormat(
                                _receiptList[0].PAYMENT_DATE,
                                'dd-MM-yyyy') */ /*+
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _receiptList[0].END_DATE, 'dd-MM-yyyy')*/ /*
                            */
                            textColor: GlobalVariables.primaryColor,
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
                                        ? AppIconButton(Icons.edit,
                                            iconColor:
                                                GlobalVariables.primaryColor,
                                            iconSize: 24, onPressed: () {
                                            _emailTextController.clear();
                                            isEditEmail = true;
                                            _stateState(() {});
                                          })
                                        : AppIconButton(Icons.cancel,
                                            iconColor: GlobalVariables.grey,
                                            iconSize: 24, onPressed: () {
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
                            textContent: AppLocalizations.of(context)
                                .translate('email_now'),
                            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            onPressed: () {
                              GlobalFunctions.checkInternetConnection()
                                  .then((internet) {
                                if (internet) {
                                  if (_emailTextController.text.length > 0) {
                                    Navigator.of(context).pop();
                                    getReceiptMail(
                                        _receiptList[0].RECEIPT_NO!,
                                        _emailTextController.text,
                                        widget.yearSelectedItem!);
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
                        /*  Container(
                          alignment: Alignment.topRight,
                          //height: 45,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width / 3,
                            child: MaterialButton(
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

  Future<void> getReceiptMail(
      String invoiceNo, String emailId, String year) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog!.show();
    restClientERP
        .getReceiptMail(societyId, invoiceNo, _emailTextController.text, year)
        .then((value) {
      print('Response : ' + value.toString());

      GlobalFunctions.showToast(value.message!);
      _progressDialog!.dismiss();
    }).catchError((Object obj) {
      if (_progressDialog!.isShowed) {
        _progressDialog!.dismiss();
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

    _progressDialog!.show();
    restClientERP.getReceiptPDFData(societyId, widget.invoiceNo!).then((value) {
      print('Response : ' + value.dataString.toString());

      GlobalFunctions.convertBase64StringToFile(
              value.dataString!, 'Receipt' + widget.invoiceNo! + '.pdf')
          .then((value) {
        if (value) {
          // GlobalFunctions.showToast(
          //     AppLocalizations.of(context).translate('download_folder'));
        } else {
          GlobalFunctions.showToast(
              AppLocalizations.of(context).translate('download_failed'));
        }
      });
      _progressDialog!.dismiss();
    }).catchError((Object obj) {
      print('obj : ' + obj.toString());
      if (_progressDialog!.isShowed) {
        _progressDialog!.dismiss();
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

  void cancelReceiptRequest(String id) {
    showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('sure_cancel_receipt'),
                              fontSize: GlobalVariables.textSizeLargeMedium,
                              textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold),
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
                                    _progressDialog!.show();
                                    Provider.of<UserManagementResponse>(context,
                                            listen: false)
                                        .cancelReceiptRequest(id)
                                        .then((value) {
                                      _progressDialog!.dismiss();
                                      GlobalFunctions.showToast(value.message!);
                                      if (value.status!) {
                                        Navigator.of(
                                                _scaffoldKey.currentContext!)
                                            .pop();
                                        Provider.of<UserManagementResponse>(
                                                context,
                                                listen: false)
                                            .getMonthExpensePendingRequestData();
                                        //  Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('yes'),
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('no'),
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
            }));
  }

  /* void approveReceiptRequest(String id) {

    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: text(
                              AppLocalizations.of(context).translate('sure_cancel_receipt'),
                              fontSize: GlobalVariables.textSizeLargeMedium,
                              textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                child: TextButton(
                                  onPressed: () {
                                   // Navigator.of(context).pop();
                                //    logout(context);
                                  },
                                  child: text(
                                      AppLocalizations.of(context).translate('yes'),
                                      textColor: GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: text(
                                      AppLocalizations.of(context).translate('no'),
                                      textColor: GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeMedium,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              );
            }));

  }*/
}

class RecentTransaction {
  String transactionTitle;
  String transactionRs;

  RecentTransaction(
      {required this.transactionTitle, required this.transactionRs});
}
