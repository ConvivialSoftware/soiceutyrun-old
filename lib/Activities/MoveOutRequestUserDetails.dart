import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AppNotificationSettings.dart';
import 'package:societyrun/Activities/ChangePassword.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Feedback.dart';
import 'package:societyrun/Activities/LoginPage.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseMoveOutRequestUserDetails extends StatefulWidget {

  RentalRequest moveOutRequest;

  BaseMoveOutRequestUserDetails(this.moveOutRequest);

  @override
  _BaseMoveOutRequestUserDetailsState createState() => _BaseMoveOutRequestUserDetailsState();
}

class _BaseMoveOutRequestUserDetailsState extends State<BaseMoveOutRequestUserDetails> {

  List<Tenant> tenantDetailsList =  List<Tenant>();
  String _taskId,_localPath;
  ReceivePort _port = ReceivePort();
  ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();

    tenantDetailsList = List<Tenant>.from(widget.moveOutRequest.tenant_name
        .map((i) => Tenant.fromJson(i)));

    print(tenantDetailsList.toString());
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
        appBar: AppBar(
          backgroundColor: GlobalVariables.green,
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
            AppLocalizations.of(context).translate('move_out_request'),
            textColor: GlobalVariables.white, fontSize: GlobalVariables.textSizeMedium
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: double.maxFinite,
      //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 150.0),
                getMoveOutRequestUserDetailsLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMoveOutRequestUserDetailsLayout() {

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
              //padding: EdgeInsets.all(10),
              margin: EdgeInsets.fromLTRB(
                  10, MediaQuery.of(context).size.height / 15, 10, 0),
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
            Card(
              shape: (RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
              elevation: 2.0,
              //  shadowColor: GlobalVariables.green.withOpacity(0.3),
              margin: EdgeInsets.all(20),
              color: GlobalVariables.white,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [

                    SizedBox(
                      height: 4,
                    ),
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
                              GlobalFunctions.convertDateFormat(widget.moveOutRequest.AGREEMENT_TO, "dd-MM-yyyy"),
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
                          onTap: (){
                            if(widget.moveOutRequest.AGREEMENT.isNotEmpty) {
                              downloadAttachment(
                                  widget.moveOutRequest
                                      .AGREEMENT, _localPath);
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
                                        .translate('agreement'),
                                    fontSize: GlobalVariables.textSizeMedium,
                                    textColor: GlobalVariables.skyBlue,
                                    textStyleHeight: 1.0),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            if(widget.moveOutRequest.TENANT_CONSENT.isNotEmpty) {
                              downloadAttachment(
                                  widget.moveOutRequest
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
                          onTap: (){
                            if(widget.moveOutRequest.OWNER_CONSENT.isNotEmpty) {
                              downloadAttachment(
                                  widget.moveOutRequest
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
                            if(widget.moveOutRequest.AUTH_FORM.isNotEmpty) {
                              downloadAttachment(
                                  widget.moveOutRequest
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
                    ),
                  ],
                ),
              ),

            ),
            Container(
              alignment: Alignment.topRight,
              height: 45,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: AppButton(
                textContent: AppLocalizations.of(context).translate('move_out'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              child: deleteFamilyMemberLayout(),
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
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 2.0,
            //  shadowColor: GlobalVariables.green.withOpacity(0.3),
            margin: EdgeInsets.all(10),
            color: GlobalVariables.white,
            child: Column(
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(20),
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
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: text(
                                    tenantDetailsList[position].NAME,
                                    textColor: GlobalVariables.black,
                                    fontSize: GlobalVariables.textSizeLargeMedium,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(
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
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              tenantDetailsList[position].EMAIL.isNotEmpty ? Container(
                                child: text(
                                  tenantDetailsList[position].EMAIL,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.grey,
                                    textStyleHeight: 1.0
                                ),
                              ):SizedBox(),
                              SizedBox(
                                height: 4,
                              ),
                              tenantDetailsList[position].MOBILE.isNotEmpty ? Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: text(
                                  tenantDetailsList[position].MOBILE,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.grey,
                                    textStyleHeight: 1.0
                                ),
                              ):SizedBox(),
                              SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  TextEditingController _reasonController = TextEditingController();
  deleteFamilyMemberLayout() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(AppLocalizations.of(context).translate('sure_move_out'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 100,
            child: AppTextField(
              textHintContent:
              AppLocalizations.of(context).translate('reason') +
                  '*',
              controllerCallback: _reasonController,
              maxLines: 99,
              contentPadding: EdgeInsets.only(top: 14),
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
                      if(_reasonController.text.length>0){
                        Navigator.of(context).pop();
                        moveOutMember();
                      }else{
                        GlobalFunctions.showToast('Please Enter Reason');
                      }
                    },
                    child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.green,
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
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> moveOutMember() async {

    _progressDialog.show();
    Provider.of<UserManagementResponse>(context,listen: false).deactivateUser(widget.moveOutRequest.U_ID, _reasonController.text,tenantDetailsList[0].BLOCK,tenantDetailsList[0].FLAT).then((value) {
      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message);
    });

  }



}
