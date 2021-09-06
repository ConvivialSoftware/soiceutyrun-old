import 'dart:async';
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
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Models/UploadItem.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseTenantInfo extends StatefulWidget {

  TenantRentalRequest _tenantRentalRequest;
  bool isAdmin;

  BaseTenantInfo(this._tenantRentalRequest, this.isAdmin);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TenantInfoState();
  }
}

class TenantInfoState extends BaseStatefulState<BaseTenantInfo> {

  String societyId;
  String _taskId,_localPath;
  ReceivePort _port = ReceivePort();

  TextEditingController _agreementFromController = TextEditingController();
  TextEditingController _agreementToController = TextEditingController();
  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;
  /*FlutterUploader uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  Map<String, UploadItem> _tasks = {};*/
  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

  @override
  void initState() {
    super.initState();
    getLocalPath();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
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

   /* _progressSubscription = uploader.progress.listen((progress) {
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

  }


  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    //_progressSubscription?.cancel();
    //_resultSubscription?.cancel();
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
    // TODO: implement build

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
              Navigator.of(context).pop();
            },
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          actions: [
            PopupMenuButton(
                icon: AppIcon(Icons.more_vert,
                    iconColor:
                    // isMenuEnable ?
                    GlobalVariables.white
                  // : GlobalVariables.transparent
                ),
                // add this line
                itemBuilder: (_) => <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      child: Container(
                          //width: 200,
                         // height: 30,
                          child: text(AppLocalizations.of(context).translate('renew_agreement'),
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeSMedium)),
                      value: 'renew'),
                  new PopupMenuItem<String>(
                      child: Container(
                         // width: 100,
                         // height: 30,
                          child: text(AppLocalizations.of(context).translate('terminate'),
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeSMedium)),
                      value: 'close'),
                ],
                onSelected: (index) async {
                  switch (index) {
                    case 'renew':
                      print('Id : '+widget._tenantRentalRequest.ID);
                      showRenewAgreementDialog();
                      break;
                    case 'close':
                      showCloseAgreementDialog();
                      break;
                  }
                }),
          ],
          title: AutoSizeText(
            AppLocalizations.of(context).translate('my_tenant'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
        getTenantInfoLayout(),
        /*Container(
          margin: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: AppButton(
                textContent: AppLocalizations.of(context).translate('renew'),
                onPressed: () {

                }),
          ),
        )*/
      ],
    );
  }

  getTenantInfoLayout() {
    List<Member> tenantInfo = List<Member>.from(widget._tenantRentalRequest.tenant_name.map((i) => Member.fromJson(i)));
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppContainer(
              isListItem:true,
              child: Builder(
                  builder: (context) => ListView.builder(
                        // scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            widget._tenantRentalRequest.tenant_name.length,
                        itemBuilder: (context, position) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseDisplayProfileInfo(
                                              tenantInfo[position].ID,
                                              'tenant')));
                            },
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          //margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                          child: tenantInfo[position].PROFILE_PHOTO
                                                  .isEmpty
                                              ? AppAssetsImage(
                                                  GlobalVariables
                                                      .componentUserProfilePath,
                                                  imageWidth: 50.0,
                                                  imageHeight: 50.0,
                                                  borderColor:
                                                      GlobalVariables.grey,
                                                  borderWidth: 1.0,
                                                  fit: BoxFit.cover,
                                                  radius: 25.0,
                                                )
                                              : AppNetworkImage(
                                            tenantInfo[position].PROFILE_PHOTO,
                                                  imageWidth: 50.0,
                                                  imageHeight: 50.0,
                                                  borderColor:
                                                      GlobalVariables.grey,
                                                  borderWidth: 1.0,
                                                  fit: BoxFit.cover,
                                                  radius: 25.0,
                                                )),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            primaryText(
                                              tenantInfo[position].NAME,
                                              maxLine: 2,
                                            ),
                                            tenantInfo[position].MOBILE
                                                        .length >
                                                    0
                                                ? InkWell(
                                                    onTap: () {
                                                      launch("tel://" +
                                                          tenantInfo[position].MOBILE);
                                                    },
                                                    child: secondaryText(
                                                        tenantInfo[position].MOBILE,
                                                        maxLine: 2,
                                                        textColor: GlobalVariables
                                                            .skyBlue),
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      societyId =
                                                          await GlobalFunctions
                                                              .getSocietyId();
                                                      var result = await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BaseEditProfileInfo(
                                                                      tenantInfo[position].ID,
                                                                      societyId)));
                                                      if (result == 'profile') {
                                                        Provider.of<UserManagementResponse>(
                                                                context,
                                                                listen: false)
                                                            .getUnitMemberData();
                                                      }
                                                    },
                                                    child: Container(
                                                      //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: secondaryText(
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                'add_phone'),
                                                        textColor: GlobalVariables
                                                            .skyBlue,
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: AppIconButton(
                                          Icons.share,
                                          iconColor: GlobalVariables.grey,
                                          iconSize: 20.0,
                                          onPressed: () {
                                            String name = tenantInfo[position].NAME;
                                            String title = '';
                                            String text = 'Name : ' +
                                                name +
                                                '\nContact : ' +
                                                tenantInfo[position].MOBILE;
                                            title = tenantInfo[position].NAME;
                                            print('titlee : ' + title);
                                            GlobalFunctions.shareData(
                                                title, text);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  position !=
                                      tenantInfo.length -
                                              1
                                      ? Divider()
                                      : Container(),
                                  /*call.length > 0
                  ? Container(
                      // margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  launch("tel://" + call);
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: AppIconButton(
                                    Icons.call,
                                    iconColor: GlobalVariables.green,
                                    iconSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30, child: verticalDivider()),
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  String name = family
                                      ? _list[position].NAME
                                      : _list[position].STAFF_NAME;
                                  String title = '';
                                  String text =
                                      'Name : ' + name + '\nContact : ' + call;
                                  family
                                      ? title = _list[position].NAME
                                      : title = _list[position].STAFF_NAME;
                                  print('titlee : ' + title);
                                  GlobalFunctions.shareData(title, text);
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: AppIconButton(
                                    Icons.share,
                                    iconColor: GlobalVariables.grey,
                                    iconSize: 20.0,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ))
                  : family
                      ? InkWell(
                            onTap: () async {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseEditProfileInfo(userId, societyId)));
                              if (result == 'profile') {
                                Provider.of<UserManagementResponse>(context,
                                        listen: false)
                                    .getUnitMemberData();
                              }
                            },
                            child: Container(
                              //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                              alignment: Alignment.center,
                              child: text(
                                '+ ' +
                                    AppLocalizations.of(context)
                                        .translate('add_phone'),
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        )
                      : Container()*/
                                ],
                              ),
                            ),
                          );
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
            ),
            //SizedBox(height: 8),
            AppContainer(
              isListItem:true,
              child: Column(
                children: [
                  Row(
                    children: [
                      AppIcon(
                        Icons.date_range,
                        iconColor: GlobalVariables.secondaryColor,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      text(AppLocalizations.of(context).translate('agreement_from') +
                          ' : ',fontSize: GlobalVariables.textSizeMedium),
                      SizedBox(
                        width: 8,
                      ),
                      secondaryText(
                          GlobalFunctions.convertDateFormat(widget._tenantRentalRequest.AGREEMENT_FROM, "dd-MM-yyyy") /*userManagementResponse.tenantListForAdmin. == '0000-00-00'
                          ? ''
                          : GlobalFunctions.convertDateFormat(_profileList[0].DOB,"dd-MM-yyyy")*/
                          ),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      AppIcon(
                        Icons.date_range,
                        iconColor: GlobalVariables.secondaryColor,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      text(AppLocalizations.of(context).translate('agreement_to') +
                          ' : ',fontSize: GlobalVariables.textSizeMedium),
                      SizedBox(
                        width: 8,
                      ),
                      secondaryText(
                          GlobalFunctions.convertDateFormat(widget._tenantRentalRequest.AGREEMENT_TO, "dd-MM-yyyy") /*userManagementResponse.tenantListForAdmin. == '0000-00-00'
                          ? ''
                          : GlobalFunctions.convertDateFormat(_profileList[0].DOB,"dd-MM-yyyy")*/
                          ),
                    ],
                  ),
                ],
              ),
            ),
            AppContainer(
              isListItem: true,
              child: InkWell(
                onTap: (){
                  downloadAttachment(
                      widget._tenantRentalRequest.AGREEMENT, _localPath);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.attach_file,color: GlobalVariables.secondaryColor,),
                    SizedBox(width: 8,),
                    text('Agreement Attachment',textColor: GlobalVariables.skyBlue,fontSize: GlobalVariables.textSizeSMedium)
                  ],
                ),
              ),

            )
          ],
        ),
      ),
    );
  }

  void showRenewAgreementDialog() {

    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter _setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: GlobalVariables.white),
                  // height: MediaQuery.of(context).size.width * 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          child: text(
                            AppLocalizations.of(context)
                                .translate('renew_agreement'),
                            textColor: GlobalVariables.primaryColor,
                            fontSize: GlobalVariables.textSizeLargeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        AppTextField(
                            textHintContent: AppLocalizations.of(context).translate('agreement_from')+"*",
                            controllerCallback: _agreementFromController,
                          readOnly: true,
                          contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          suffixIcon: AppIconButton(
                            Icons.date_range,
                            iconColor: GlobalVariables.secondaryColor,
                            onPressed: () {
                              GlobalFunctions.getSelectedDate(context).then((value) {
                                _agreementFromController.text =
                                    value.day.toString().padLeft(2, '0') +
                                        "-" +
                                        value.month.toString().padLeft(2, '0') +
                                        "-" +
                                        value.year.toString();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        AppTextField(
                          textHintContent: AppLocalizations.of(context).translate('agreement_to')+"*",
                          controllerCallback: _agreementToController,
                            readOnly: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            suffixIcon: AppIconButton(
                              Icons.date_range,
                              iconColor: GlobalVariables.secondaryColor,
                              onPressed: () {
                                GlobalFunctions.getSelectedDate(context).then((value) {
                                  _agreementToController.text =
                                      value.day.toString().padLeft(2, '0') +
                                          "-" +
                                          value.month.toString().padLeft(2, '0') +
                                          "-" +
                                          value.year.toString();
                                });
                              },
                            ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          child: FlatButton.icon(
                                            onPressed: () {
                                              if (isStoragePermission) {
                                                openFile(context,_setState);
                                              } else {
                                                GlobalFunctions.askPermission(
                                                    Permission.storage)
                                                    .then((value) {
                                                  if (value) {
                                                    openFile(context,_setState);
                                                  } else {
                                                    GlobalFunctions.showToast(
                                                        AppLocalizations.of(context)
                                                            .translate(
                                                            'download_permission'));
                                                  }
                                                });
                                              }
                                            },
                                            icon: AppIcon(
                                              Icons.attach_file,
                                              iconColor: GlobalVariables.secondaryColor,
                                              iconSize: 20.0,
                                            ),
                                            label: Flexible(
                                              child: text(
                                                  attachmentFileName != null
                                                      ? attachmentFileName
                                                      : AppLocalizations.of(context)
                                                      .translate('attach_agreement')+'*',
                                                  textColor: GlobalVariables.primaryColor,
                                                  fontSize: GlobalVariables.textSizeSMedium
                                              ),
                                            ),
                                          ),
                                        ),
                                        /*   Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: text(
                                'OR',
                                textColor: GlobalVariables.lightGray,
                              ),
                            ),
                            Container(
                              child: FlatButton.icon(
                                  onPressed: () {
                                    if (isStoragePermission) {
                                      openCamera(context);
                                    } else {
                                      GlobalFunctions.askPermission(
                                              Permission.storage)
                                          .then((value) {
                                        if (value) {
                                          openCamera(context);
                                        } else {
                                          GlobalFunctions.showToast(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'download_permission'));
                                        }
                                      });
                                    }
                                  },
                                  icon: AppIcon(
                                    Icons.camera_alt,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                  label: text(
                                      AppLocalizations.of(context)
                                          .translate('take_picture'),
                                      textColor: GlobalVariables.green)),
                            ),*/
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: AppButton(
                              textContent: AppLocalizations.of(context)
                                  .translate('submit'),
                              onPressed: () async {

                                  if (_agreementFromController.text.length > 0) {
                                    if (_agreementToController.text.length > 0) {
                                      if (attachmentFilePath != null) {
                                        _progressDialog.show();

                                        Provider.of<UserManagementResponse>(context,
                                            listen: false)
                                            .renewAgreement(
                                            widget._tenantRentalRequest.ID,
                                            _agreementFromController.text,
                                            _agreementToController.text,
                                            GlobalFunctions.convertFileToString(attachmentFilePath),
                                            attachmentFileName.substring(attachmentFileName.indexOf(".")+1,attachmentFileName.length),
                                            widget.isAdmin)
                                            .then((value) async {
                                          _progressDialog.hide();

                                          GlobalFunctions.showToast(value.message);
                                          if (value.status) {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
/*
                                            final tag = "File upload ${_tasks.length +
                                                1}";
                                            final taskId = await uploader.enqueue(
                                                url: "https://societyrun.com//Uploads/",
                                                //required: url to upload to
                                                files: [
                                                  FileItem(
                                                      filename: attachmentFileName,
                                                      savedDir: attachmentFilePath
                                                          .replaceAll(
                                                          attachmentFileName, ""),
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
                                                      () =>
                                                      UploadItem(
                                                        id: taskId,
                                                        tag: tag,
                                                        type: MediaType.Pdf,
                                                        status: UploadTaskStatus
                                                            .enqueued,
                                                      ));
                                            });*/
                                          }
                                        });
                                      } else {
                                        GlobalFunctions.showToast('Please Select Agreement File');
                                      }
                                    } else {
                                      GlobalFunctions.showToast('Please Enter End Date');
                                    }
                                  } else {
                                    GlobalFunctions.showToast('Please Enter Start Date');
                                  }

                              }

                              ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));

  }

  void openFile(BuildContext context, StateSetter setState) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      attachmentFileName = attachmentFilePath.substring(
          attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
      print('file Name : ' + attachmentFileName.toString());
      setState(() {});
    });
  }

  void showCloseAgreementDialog() {

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
                            AppLocalizations.of(context).translate('sure_close_agreement'),
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
                              child: FlatButton(
                                onPressed: () {

                                  Provider.of<UserManagementResponse>(context,listen: false).closeAgreement(widget._tenantRentalRequest.ID).then((value) {

                                    GlobalFunctions.showToast(value.message);
                                    if(value.status){
                                      Navigator.of(context).pop();
                                    }

                                  });
                                },
                                child: text(
                                    AppLocalizations.of(context).translate('yes'),
                                    textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeMedium,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: text(
                                    AppLocalizations.of(context).translate('no'),
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
                ),
              );
            }));

  }
}
