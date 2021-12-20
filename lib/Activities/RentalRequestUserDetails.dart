import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AppNotificationSettings.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseRentalRequestUserDetails extends StatefulWidget {
  TenantRentalRequest rentalRequest;

  BaseRentalRequestUserDetails(this.rentalRequest);

  @override
  _BaseRentalRequestUserDetailsState createState() =>
      _BaseRentalRequestUserDetailsState();
}

class _BaseRentalRequestUserDetailsState
    extends State<BaseRentalRequestUserDetails> {
  List<Tenant> tenantDetailsList = List<Tenant>();
  String _taskId, _localPath;
  ReceivePort _port = ReceivePort();
  ProgressDialog _progressDialog;
  bool isStoragePermission = false;
  @override
  void initState() {
    super.initState();

    tenantDetailsList = List<Tenant>.from(
        widget.rentalRequest.tenant_name.map((i) => Tenant.fromJson(i)));

    print(tenantDetailsList.toString());
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
          title: text(
              AppLocalizations.of(context).translate('rental_request') +
                  ' ' +
                  tenantDetailsList[0].BLOCK +
                  ' ' +
                  tenantDetailsList[0].FLAT,
              textColor: GlobalVariables.white,
              fontSize: GlobalVariables.textSizeMedium),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
        getRentalRequestUserDetailsLayout(),
      ],
    );
  }

  getRentalRequestUserDetailsLayout() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8,),
            AppContainer(
              isListItem: true,
              child: Row(
                children: [
                  Container(
                    child: AppAssetsImage(
                      widget.rentalRequest.RENTED_TO.toLowerCase()=='family' ? GlobalVariables.familyImagePath
                          : widget.rentalRequest.RENTED_TO.toLowerCase()=='group'? GlobalVariables.bachelorsImagePath
                          : GlobalVariables.commercialImagePath,
                      imageWidth: 60.0,
                      imageHeight: 60.0,
                      borderColor: GlobalVariables.transparent,
                      borderWidth: 0.0,
                      fit: BoxFit.cover,
                      //radius: 30.0,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Container(
                            child: AppIcon(
                              Icons.date_range,
                              iconColor: GlobalVariables.grey,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            child: text(
                                'Expires on '+GlobalFunctions.convertDateFormat(
                                    widget.rentalRequest.AGREEMENT_TO,
                                    "dd-MM-yyyy"),
                                fontSize: GlobalVariables.textSizeSMedium,
                                textColor: GlobalVariables.black,
                                textStyleHeight: 1.0),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.rentalRequest.AGREEMENT.isNotEmpty) {
                                print("storagePermiassion : " +
                                    isStoragePermission.toString());
                                if (isStoragePermission) {
                                  downloadAttachment(widget.rentalRequest.AGREEMENT, _localPath);
                                } else {
                                  GlobalFunctions.askPermission(Permission.storage)
                                      .then((value) {
                                    if (value) {
                                      downloadAttachment(widget.rentalRequest.AGREEMENT, _localPath);
                                    } else {
                                      GlobalFunctions.showToast(AppLocalizations.of(context)
                                          .translate('download_permission'));
                                    }
                                  });
                                }
                             //   downloadAttachment(widget.rentalRequest.AGREEMENT, _localPath);
                              } else {
                                GlobalFunctions.showToast(
                                    AppLocalizations.of(context)
                                        .translate('document_not_available'));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: AppIcon(
                                  Icons.attach_file,
                                  iconColor: GlobalVariables.skyBlue,
                                )),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  child: text(
                                      AppLocalizations.of(context)
                                          .translate('agreement'),
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.skyBlue,
                                      textStyleHeight: 1.0),
                                ),
                              ],
                            ),
                          ),
                          /*  InkWell(
                        onTap: (){
                          if(widget.rentalRequest.TENANT_CONSENT.isNotEmpty) {
                            downloadAttachment(
                                widget.rentalRequest
                                    .TENANT_CONSENT, _localPath);
                          }else{
                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                child: AppIcon(
                                  Icons.attach_file,
                                  iconColor: GlobalVariables.skyBlue,
                                )),
                            SizedBox(width: 4,),
                            Container(
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('tenant_consent'),
                                  fontSize: GlobalVariables.textSizeMedium,
                                  textColor: GlobalVariables.skyBlue,
                                  textStyleHeight: 1.0),
                            ),
                          ],
                        ),
                      ),*/
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ))
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          if(widget.rentalRequest.OWNER_CONSENT.isNotEmpty) {
                            downloadAttachment(
                                widget.rentalRequest
                                    .OWNER_CONSENT, _localPath);
                          }else{
                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                child: AppIcon(
                                  Icons.attach_file,
                                  iconColor: GlobalVariables.skyBlue,
                                )),
                            SizedBox(width: 4,),
                            Container(
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('owner_consent'),
                                  fontSize: GlobalVariables.textSizeMedium,
                                  textColor: GlobalVariables.skyBlue,
                                  textStyleHeight: 1.0),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          if(widget.rentalRequest.AUTH_FORM.isNotEmpty) {
                            downloadAttachment(
                                widget.rentalRequest
                                    .AUTH_FORM, _localPath);
                          }else{
                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                child: AppIcon(
                                  Icons.attach_file,
                                  iconColor: GlobalVariables.skyBlue,
                                )),
                            SizedBox(width: 4,),
                            Container(
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('authorization_form'),
                                  fontSize: GlobalVariables.textSizeMedium,
                                  textColor: GlobalVariables.skyBlue,
                                  textStyleHeight: 1.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),*/
                ],
              ),
            ),
            Container(
              child: Builder(
                  builder: (context) => ListView.builder(
                        // scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tenantDetailsList.length,
                        itemBuilder: (context, position) {
                          return getRentalRequestListItemLayout(position);
                        }, //  scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      )),
            ),
            Container(
              alignment: Alignment.topRight,
              height: 45,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: AppButton(
                textContent: AppLocalizations.of(context).translate('Approve'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: approveMemberLayout(),
                            );
                          }));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getRentalRequestListItemLayout(int position) {
    return InkWell(
      onTap: () {},
      child: AppContainer(
        isListItem: true,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    // padding: EdgeInsets.all(20),
                    // alignment: Alignment.center,
                    /* decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25)),*/
                    child: tenantDetailsList[position].PROFILE_PHOTO.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 60.0,
                            imageHeight: 60.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 30.0,
                          )
                        : AppNetworkImage(
                            tenantDetailsList[position].PROFILE_PHOTO,
                            imageWidth: 60.0,
                            imageHeight: 60.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 30.0,
                          )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: text(tenantDetailsList[position].NAME,
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          child: text(tenantDetailsList[position].ADDRESS,
                              textColor: GlobalVariables.grey,
                              fontSize: GlobalVariables.textSizeSMedium,),
                        ),
                        /*SizedBox(
                          height: 4,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: text(
                            tenantDetailsList[position].BLOCK +
                                ' ' +
                                tenantDetailsList[position].FLAT,
                            fontSize: GlobalVariables.textSizeSMedium,
                            textColor: GlobalVariables.grey,
                            textStyleHeight: 1.0
                          ),
                        ),*/
                        SizedBox(
                          height: 4,
                        ),
                        tenantDetailsList[position].EMAIL.isNotEmpty
                            ? Container(
                                child: text(tenantDetailsList[position].EMAIL,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                    textStyleHeight: 1.0),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 4,
                        ),
                        tenantDetailsList[position].MOBILE.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: text(tenantDetailsList[position].MOBILE,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.grey,
                                    textStyleHeight: 1.0),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
               /* Container(
                  child: IconButton(
                      icon: AppIcon(
                        Icons.attach_file,
                        iconColor: GlobalVariables.skyBlue,
                        iconSize: GlobalVariables.textSizeLarge,
                      ),
                      onPressed: () {
                        if(tenantDetailsList[position].POLICE_VERIFICATION.isNotEmpty) {
                          downloadAttachment(
                              tenantDetailsList[position].POLICE_VERIFICATION, _localPath);
                        }else{
                          GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                        }
                      }),
                )*/
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (tenantDetailsList[position].IDENTITY_PROOF.isNotEmpty) {
                      print("storagePermiassion : " +
                          isStoragePermission.toString());
                      if (isStoragePermission) {
                        downloadAttachment(tenantDetailsList[position].IDENTITY_PROOF, _localPath);
                      } else {
                        GlobalFunctions.askPermission(Permission.storage)
                            .then((value) {
                          if (value) {
                            downloadAttachment(tenantDetailsList[position].IDENTITY_PROOF, _localPath);
                          } else {
                            GlobalFunctions.showToast(AppLocalizations.of(context)
                                .translate('download_permission'));
                          }
                        });
                      }
                      //   downloadAttachment(widget.rentalRequest.AGREEMENT, _localPath);
                    } else {
                      GlobalFunctions.showToast(
                          AppLocalizations.of(context)
                              .translate('document_not_available'));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: AppIcon(
                            Icons.attach_file,
                            iconColor: GlobalVariables.skyBlue,
                          )),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        child: text(
                            AppLocalizations.of(context)
                                .translate('identity_proof'),
                            fontSize: GlobalVariables.textSizeMedium,
                            textColor: GlobalVariables.skyBlue,
                            textStyleHeight: 1.0),
                      ),
                    ],
                  ),
                ),
                /*  InkWell(
                        onTap: (){
                          if(widget.rentalRequest.TENANT_CONSENT.isNotEmpty) {
                            downloadAttachment(
                                widget.rentalRequest
                                    .TENANT_CONSENT, _localPath);
                          }else{
                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                child: AppIcon(
                                  Icons.attach_file,
                                  iconColor: GlobalVariables.skyBlue,
                                )),
                            SizedBox(width: 4,),
                            Container(
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('tenant_consent'),
                                  fontSize: GlobalVariables.textSizeMedium,
                                  textColor: GlobalVariables.skyBlue,
                                  textStyleHeight: 1.0),
                            ),
                          ],
                        ),
                      ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController _reasonController = TextEditingController();

  approveMemberLayout() {
    return Container(
      padding: EdgeInsets.all(16),
    //  width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              'Rental Request',
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.primaryColor,
              fontWeight: FontWeight.bold,
              isCentered: true,
            ),
          ),
          Container(
            height: 100,
            child: AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('special_notes') + '*',
              controllerCallback: _reasonController,
              maxLines: 99,
              contentPadding: EdgeInsets.only(top: 14),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            child: text(
              AppLocalizations.of(context).translate('rental_request_approve'),
              fontSize: GlobalVariables.textSizeSMedium,
              textColor: GlobalVariables.black,
             // fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                    onPressed: () {
                      if (_reasonController.text.length > 0) {
                        Navigator.of(context).pop();

                        _progressDialog.show();
                        Provider.of<UserManagementResponse>(context,
                                listen: false)
                            .nocApprove(
                                widget.rentalRequest.ID,
                                tenantDetailsList[0].BLOCK,
                                tenantDetailsList[0].FLAT,
                                _reasonController.text)
                            .then((value) {
                          _progressDialog.hide();
                          GlobalFunctions.showToast(value.message);
                          if (value.status) {
                            Navigator.of(context).pop();
                          }
                        });
                      } else {
                        GlobalFunctions.showToast('Please Enter Note');
                      }
                    },
                    child: text(AppLocalizations.of(context).translate('Approve'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                /*Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('no'),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),*/
              ],
            ),
          )
        ],
      ),
    );
  }
}
