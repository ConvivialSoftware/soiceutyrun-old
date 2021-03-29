
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Expense.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Models/VoucherAmount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseExpenseVoucher extends StatefulWidget {

  Expense _expense;
  BaseExpenseVoucher(this._expense);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseVoucherState(_expense);
  }
}

class ExpenseVoucherState extends BaseStatefulState<BaseExpenseVoucher> {


  ProgressDialog _progressDialog;

  Expense _expense;
  ExpenseVoucherState(this._expense);
  var  _localPath;

  String _taskId;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    getLocalPath();
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
                  SnackBar(content: Text('Cannot open this file')));
            }
          });
        } else {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Download failed!')));
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

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
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
          title: AutoSizeText(
            AppLocalizations.of(context).translate('expense_voucher'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: WillPopScope(child: getBaseLayout(), onWillPop: (){
          Navigator.of(context).pop();
          return;
        }),
      ),
    );
  }
  
  getBaseLayout() {
    print('_expense.ATTACHMENT : '+ _expense.ATTACHMENT.toString());
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
                getExpenseVoucherLayout(),
                _expense.ATTACHMENT.isNotEmpty ?  attachExpenseFabLayout(): SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  attachExpenseFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () async {

                downloadAttachment(_expense.ATTACHMENT, _localPath);

              },
              child: Icon(
                Icons.attach_file,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getExpenseVoucherLayout() {

   List<VoucherAmount> _voucherAmountList = List<VoucherAmount>.from(_expense.head_details.map((i) => VoucherAmount.fromJson(i)));
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
            padding: EdgeInsets.all(
                10), // height: MediaQuery.of(context).size.height / 0.5,
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('voucher_number')+ " : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold
                          ),),
                        ),
                        Container(
                       //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(_expense.VOUCHER_NO,style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 18,fontWeight: FontWeight.bold
                          ),),
                        )
                      ],
                    ),
                  ),
                  /*Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('Vendor_name')+ " : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18
                          ),),
                        ),
                        Container(
                         // margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(_expense.name,style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 16
                          ),),
                        )
                      ],
                    ),
                  ),*/
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('amount')+ "(Rs.) : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18
                          ),),
                        ),
                        Container(
                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(double.parse(_expense.AMOUNT.toString()).toStringAsFixed(2),style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 16
                          ),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('transaction_mode')+ " : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18
                          ),),
                        ),
                        Container(
                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(_expense.TRANSACTION_TYPE,style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 16
                          ),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('transaction_number')+ " : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18
                          ),),
                        ),
                        Container(
                          //margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(_expense.REFERENCE_NO,style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 16
                          ),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(AppLocalizations.of(context).translate('from_account')+ " : ",style: TextStyle(
                              color: GlobalVariables.green,fontSize: 18
                          ),),
                        ),
                        Container(
                        //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(_expense.BANK_NAME,style: TextStyle(
                              color: GlobalVariables.grey,fontSize: 16
                          ),),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            child: AutoSizeText(AppLocalizations.of(context).translate('narration')+ " : ",style: TextStyle(
                                color: GlobalVariables.green,fontSize: 18
                            ),),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            //color : GlobalVariables.green,
                            //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: AutoSizeText(_expense.REMARK,style: TextStyle(
                                color: GlobalVariables.grey,fontSize: 16
                            ),maxLines: 2,)
                            ,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
            padding: EdgeInsets.all(
                10), // height: MediaQuery.of(context).size.height / 0.5,
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(
                      10, 5, 10, 0),
                  alignment: Alignment.topLeft,
                  child: AutoSizeText("Head Details",style: TextStyle(
                      color: GlobalVariables.green,fontSize: 18,fontWeight: FontWeight.bold
                  ),),
                ),
                SizedBox(height: 10,),
                _voucherAmountList.length>0 ? Container(
                  //padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(
                      10, 10, 10, 10),
                  child: Builder(
                      builder: (context) => ListView.builder(
                        // scrollDirection: Axis.vertical,
                        itemCount: _voucherAmountList.length,
                        itemBuilder: (context, position) {
                          return Container(
                            child: Row(
                              children: [
                                Flexible(
                                  flex:2,
                                  child: Container(
                                    child: AutoSizeText(_voucherAmountList[position].head_name+' : ',style: TextStyle(
                                        color: GlobalVariables.green,fontSize: 18
                                    ),),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    //color : GlobalVariables.green,
                                    //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                    child: AutoSizeText(_voucherAmountList[position].amount,style: TextStyle(
                                        color: GlobalVariables.grey,fontSize: 16
                                    ),maxLines: 2,)
                                    ,
                                  ),
                                )
                              ],

                            ),
                          );
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
                ):Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

}
