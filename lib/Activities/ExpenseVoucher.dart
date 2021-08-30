import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
//import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Expense.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Models/UploadItem.dart';
import 'package:societyrun/Models/VoucherAmount.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

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
  String attachmentFilePath;
  String attachmentFileName;

  String attachmentFileImagePath;
  String attachmentFileImageName;
  String attachmentCompressFileImagePath;

  Expense _expense;

  ExpenseVoucherState(this._expense);

  var _localPath;
  bool isStoragePermission = false;

  String _taskId;
  ReceivePort _port = ReceivePort();
  final GlobalKey<ScaffoldState> _dashboardSacfoldKey =
      new GlobalKey<ScaffoldState>();

  /*FlutterUploader uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  Map<String, UploadItem> _tasks = {};*/

  @override
  void initState() {
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
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
              Scaffold.of(_dashboardSacfoldKey.currentContext).showSnackBar(
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

     /*_progressSubscription = uploader.progress.listen((progress) {
      final task = _tasks[progress.tag];
      print("progress: ${progress.progress} , tag: ${progress.tag}");
      if (task == null) return;
      if (task.isCompleted()) return;
      setState(() {
        _tasks[progress.tag] =
            task.copyWith(progress: progress.progress, status: progress.status);
      });
    });
    _resultSubscription = uploader.result.listen((result) {
      print(
          "id: ${result.taskId}, status: ${result.status}, response: ${result.response}, statusCode: ${result.statusCode}, tag: ${result.tag}, headers: ${result.headers}");

      final task = _tasks[result.tag];
      if (task == null) return;

      setState(() {
        _tasks[result.tag] = task.copyWith(status: result.status);
      });
    }, onError: (ex, stacktrace) {
      print("exception: $ex");
      print("stacktrace: $stacktrace" ?? "no stacktrace");
      final exp = ex as UploadException;
      final task = _tasks[exp.tag];
      if (task == null) return;

      setState(() {
        _tasks[exp.tag] = task.copyWith(status: exp.status);
      });
    });
*/


    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
   // _progressSubscription?.cancel();
   // _resultSubscription?.cancel();
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
        key: _dashboardSacfoldKey,
        backgroundColor: GlobalVariables.veryLightGray,
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
          title: text('Expense #' + _expense.VOUCHER_NO,
              textColor: GlobalVariables.white,
              fontSize: GlobalVariables.textSizeMedium),
        ),
        body: WillPopScope(
            child: getBaseLayout(),
            onWillPop: () {
              Navigator.of(context).pop();
              return;
            }),
      ),
    );
  }

  getBaseLayout() {
    print('_expense.ATTACHMENT : ' + _expense.ATTACHMENT.toString());
    print('_expense.VOUCHER_NO : ' + _expense.VOUCHER_NO.toString());
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
                _expense.ATTACHMENT.isEmpty
                    ? attachExpenseFabLayout()
                    : SizedBox(),
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
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: GlobalVariables.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) =>
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: GlobalVariables.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(
                                        right: 16.0, top: 16.0),
                                    alignment: Alignment.topRight,
                                    child: AppIconButton(
                                      Icons.close,
                                      iconSize: 24.0,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    openFile(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    color: GlobalVariables.transparent,
                                    child: Column(
                                      children: [
                                        AppAssetsImage(
                                          GlobalVariables.pdfIconPath,
                                          imageColor:
                                          GlobalVariables.mediumGreen,
                                          imageWidth: 40,
                                          imageHeight: 40,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(
                                            AppLocalizations.of(context)
                                                .translate('attach_file'),
                                            fontSize: GlobalVariables
                                                .textSizeSMedium,
                                            textColor:
                                            GlobalVariables.skyBlue)
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    openFileImage(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    color: GlobalVariables.transparent,
                                    child: Column(
                                      children: [
                                        AppAssetsImage(
                                          GlobalVariables.imageIconPath,
                                          imageColor:
                                          GlobalVariables.mediumGreen,
                                          imageWidth: 40,
                                          imageHeight: 40,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(
                                            AppLocalizations.of(context)
                                                .translate('attach_photo'),
                                            fontSize: GlobalVariables
                                                .textSizeSMedium,
                                            textColor:
                                            GlobalVariables.skyBlue)
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    openCamera(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    color: GlobalVariables.transparent,
                                    child: Column(
                                      children: [
                                        AppIcon(
                                          Icons.camera_alt_rounded,
                                          iconColor:
                                          GlobalVariables.mediumGreen,
                                          iconSize: 40,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        text(
                                            AppLocalizations.of(context)
                                                .translate('take_picture'),
                                            fontSize: GlobalVariables
                                                .textSizeSMedium,
                                            textColor:
                                            GlobalVariables.skyBlue)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                );
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
    List<VoucherAmount> _voucherAmountList = List<VoucherAmount>.from(
        _expense.head_details.map((i) => VoucherAmount.fromJson(i)));
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 8),
        child: Column(
          children: [
            AppContainer(
              isListItem: true,
              /*margin: EdgeInsets.fromLTRB(10, 80, 10, 10),
              padding: EdgeInsets.all(
                  16), // height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(15)),*/
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    child: text(
                        GlobalFunctions.convertDateFormat(
                            _expense.PAYMENT_DATE, "dd-MM-yyyy"),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: text(
                        GlobalFunctions.getCurrencyFormat(
                            _expense.AMOUNT.toString()),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeXXLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: text(_expense.BANK_NAME,
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeLargeMedium,
                        maxLine: 3),
                  )
                ],
              ),
            ),
            /*Container(
              margin: EdgeInsets.fromLTRB(10, 40, 10, 10),
              padding: EdgeInsets.all(
                  10), // height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: <Widget>[

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
                ],
              ),
            ),*/
            AppContainer(
              isListItem: true,
              /*margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: EdgeInsets.all(
                  10), // height: MediaQuery.of(context).size.height / 0.5,
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(15)),*/
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      "Details",
                      style: TextStyle(
                          color: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeNormal,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _voucherAmountList.length > 0
                      ? Container(
                          //padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    // scrollDirection: Axis.vertical,
                                    itemCount: _voucherAmountList.length,
                                    itemBuilder: (context, position) {
                                      return Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                child: AutoSizeText(
                                                  _voucherAmountList[position]
                                                          .head_name +
                                                      ' : ',
                                                  style: TextStyle(
                                                      color:
                                                          GlobalVariables.black,
                                                      fontSize: GlobalVariables
                                                          .textSizeMedium),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Container(
                                                //color : GlobalVariables.green,
                                                //   margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                                child: AutoSizeText(
                                                  GlobalFunctions
                                                      .getCurrencyFormat(
                                                          _voucherAmountList[
                                                                  position]
                                                              .amount
                                                              .toString()),
                                                  style: TextStyle(
                                                      color:
                                                          GlobalVariables.grey,
                                                      fontSize: GlobalVariables
                                                          .textSizeSMedium),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }, //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        )
                      : Container(),
                  Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Divider(
                        thickness: 0.5,
                        color: GlobalVariables.lightGray,
                      )),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            AppLocalizations.of(context)
                                    .translate('transaction_mode') +
                                " : ",
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium),
                          ),
                        ),
                        Container(
                          //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(
                            _expense.TRANSACTION_TYPE,
                            style: TextStyle(
                                color: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeSMedium),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            AppLocalizations.of(context)
                                    .translate('transaction_number') +
                                " : ",
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium),
                          ),
                        ),
                        Container(
                          //margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(
                            _expense.REFERENCE_NO,
                            style: TextStyle(
                                color: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeSMedium),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            AppLocalizations.of(context)
                                    .translate('from_account') +
                                " : ",
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium),
                          ),
                        ),
                        Container(
                          //  margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: AutoSizeText(
                            _expense.BANK_NAME,
                            style: TextStyle(
                                color: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeSMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: AutoSizeText(
                            AppLocalizations.of(context)
                                    .translate('narration') +
                                " : ",
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: GlobalVariables.textSizeMedium),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            child: text(
                              _expense.REMARK,
                              textColor: GlobalVariables.grey,
                              fontSize: GlobalVariables.textSizeSMedium,
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
            _expense.ATTACHMENT.isNotEmpty
                ? AppContainer(
                    isListItem: true,
                    child: InkWell(
                      onTap: () {
                        if (isStoragePermission) {
                          downloadAttachment(_expense.ATTACHMENT, _localPath);
                        } else {
                          GlobalFunctions.askPermission(Permission.storage)
                              .then((value) {
                            if (value) {
                              downloadAttachment(_expense.ATTACHMENT, _localPath);
                            } else {
                              GlobalFunctions.showToast(AppLocalizations.of(context)
                                  .translate('download_permission'));
                            }
                          });
                        }
                        /* showModalBottomSheet(context: context, builder: (context){
                    return StatefulBuilder(builder: (context,setState){
                      return
                    });
                  });*/
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AppIcon(
                                Icons.attachment,
                                iconColor: GlobalVariables.skyBlue,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: text(
                                    attachmentFileName != null
                                        ? attachmentFileName
                                        : attachmentFileImageName != null
                                            ? attachmentFileImageName
                                            : AppLocalizations.of(context)
                                                .translate('attachment'),
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.skyBlue),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            attachmentFileName != null ||
                attachmentFileImageName != null
                ? Container(
              margin: EdgeInsets.only(top: 16,left: 16),
              alignment: Alignment.topLeft,
              child: AppButton(
                  textContent: 'Update',
                  onPressed: () {
                    updateExpenseAttachment();
                  }),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      attachmentFileName = attachmentFilePath.substring(
          attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
      print('file Name : ' + attachmentFileName.toString());
      print('file type : ' + attachmentFileName.substring(attachmentFileName.indexOf(".")+1,attachmentFileName.length));
      setState(() {
        attachmentFileImageName = null;
        attachmentFileImagePath = null;
        attachmentCompressFileImagePath = null;
      });
    });
  }

  void openFileImage(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFileImagePath = value;
      getCompressFilePath();
    });
  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFileImagePath = value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath() {
    attachmentFileImageName = attachmentFileImagePath.substring(
        attachmentFileImagePath.lastIndexOf('/') + 1,
        attachmentFileImagePath.length);
    print('file Name : ' + attachmentFileImageName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(attachmentFileImagePath,
              value.toString() + '/' + attachmentFileImageName)
          .then((value) {
        attachmentCompressFileImagePath = value.toString();
        print('Cache file path : ' + attachmentCompressFileImagePath);
        print('file type : ' + attachmentFileImageName.substring(attachmentFileImageName.indexOf(".")+1,attachmentFileImageName.length));
        setState(() {
          attachmentFilePath = null;
          attachmentFileName = null;
        });
      });
    });
  }

  Future<void> updateExpenseAttachment() async {
    final Dio dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);

    String encodedFile,fileType;
    if(attachmentFileName != null && attachmentFilePath != null) {
      encodedFile = GlobalFunctions.convertFileToString(attachmentFilePath);
      fileType = attachmentFileName.substring(attachmentFileName.indexOf(".")+1,attachmentFileName.length);
    }else{
      encodedFile = GlobalFunctions.convertFileToString(attachmentCompressFileImagePath);
      fileType = attachmentFileImageName.substring(attachmentFileImageName.indexOf(".")+1,attachmentFileImageName.length);
    }

    String societyId = await GlobalFunctions.getSocietyId();
    restClientERP
        .updateExpenseAttachment(
            societyId,
            widget._expense.VOUCHER_NO,
           encodedFile,fileType)
        .then((value) async {
      GlobalFunctions.showToast(value.message);
      if (value.status) {
        /*if (attachmentFileName != null && attachmentFilePath != null) {
          print('attachmentFilePath : ' + attachmentFilePath.toString());
          print('attachmentFileName : ' + attachmentFileName.toString());
          print('attachmentFileName : ' +
              attachmentFilePath.replaceAll(attachmentFileName, "").toString());

          try {
            final tag = "File upload ${_tasks.length + 1}";
            final taskId = await uploader.enqueue(
                //url: "https://societyrun.com//Uploads/",
                url: "https://housingsocietyerp.com/Uploads/",
                //required: url to upload to
                files: [
                  FileItem(
                      filename: attachmentFileName,
                      savedDir:
                          attachmentFilePath.substring(0,attachmentFilePath.lastIndexOf('/')),
                      fieldname: "file")
                ],
                // required: list of files that you want to upload
                method: UploadMethod.POST,
                // HTTP method  (POST or PUT or PATCH)
                // headers: {"admin": "1234", "admin1": "1234"},
                //  data: {"name": "john"}, // any data you want to send in upload request
                showNotification: true,
                // send local notification (android only) for upload status
                tag: attachmentFileName); // unique tag for upload task

            setState(() {
              _tasks.putIfAbsent(
                  tag,
                  () => UploadItem(
                        id: taskId,
                        tag: tag,
                        type: MediaType.Pdf,
                        status: UploadTaskStatus.enqueued,
                      ));
            });
          } on Exception catch (e) {
            print('Exception :' +e.toString());
          }
        }
*/
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });
  }
}
