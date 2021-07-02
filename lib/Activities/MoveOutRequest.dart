import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/MoveOutRequestUserDetails.dart';
import 'package:societyrun/Activities/StaffCategory.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/PollOption.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseMoveOutRequest extends StatefulWidget {

  BaseMoveOutRequest();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MoveOutRequestState();
  }
}

class MoveOutRequestState extends BaseStatefulState<BaseMoveOutRequest>
    with SingleTickerProviderStateMixin {
  //TabController _tabController;

/*
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '',userType='';
*/

  String _taskId,_localPath;
  ReceivePort _port = ReceivePort();
  ProgressDialog _progressDialog;
  
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
    Provider.of<UserManagementResponse>(context,listen: false).getMoveOutRequest();
    super.initState();

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

    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context,value,child){
          return Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: GlobalVariables.green,
                centerTitle: true,
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
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getMoveOutRequestLayout(value),
            ),
          );
        },
      ),
    );
  }

  getMoveOutRequestLayout(UserManagementResponse value) {
    // print('MyTicketLayout Tab Call');
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
                    context, 150.0),
               value.moveOutRequestList.length>0 ? getMoveOutRequestListDataLayout(value): GlobalFunctions.loadingWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMoveOutRequestListDataLayout(UserManagementResponse value) {
    return SingleChildScrollView(
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
                  itemCount: value.moveOutRequestList.length,
                  itemBuilder: (context, position) {
                    return getMoveOutRequestListItemLayout(position,value);
                  }, //  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                )),
          ),
        ],
      ),
    );
  }

  getMoveOutRequestListItemLayout(int position, UserManagementResponse value) {
    List<Tenant> tenantDetailsList = List<Tenant>.from(value
        .moveOutRequestList[position].tenant_name
        .map((i) => Tenant.fromJson(i)));
    var tenantName = '';
    for (int i = 0; i < tenantDetailsList.length; i++) {
      tenantName += ',' + tenantDetailsList[i].NAME;
    }

    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> BaseMoveOutRequestUserDetails(value.moveOutRequestList[position])));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    //  color:GlobalVariables.grey,
                                    child: text(tenantName.replaceFirst(",", ""),
                                        textColor: GlobalVariables.green,
                                        fontSize:
                                        GlobalVariables.textSizeLargeMedium,
                                        fontWeight: FontWeight.bold,
                                        textStyleHeight: 1.0),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(15, 3, 15, 5),
                                decoration: boxDecoration(
                                  bgColor: GlobalVariables.skyBlue,
                                  color: GlobalVariables.white,
                                  radius: GlobalVariables.textSizeNormal,
                                ),
                                child: text(
                                    tenantDetailsList[0].BLOCK +
                                        ' ' +
                                        tenantDetailsList[0].FLAT,
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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
                                    GlobalFunctions.convertDateFormat(value.moveOutRequestList[position].AGREEMENT_TO, "dd-MM-yyyy"),
                                    fontSize: GlobalVariables.textSizeSMedium,
                                    textColor: GlobalVariables.black,
                                    textStyleHeight: 1.0),
                              ),
                            ],
                          ),
                          /*     SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: (){
                                  if(value.moveOutRequestList[position].AGREEMENT.isNotEmpty) {
                                    downloadAttachment(
                                        value.moveOutRequestList[position]
                                            .AGREEMENT, _localPath);
                                  }else{
                                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                                  }
                                },
                                child: Row(
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
                                  if(value.moveOutRequestList[position].TENANT_CONSENT.isNotEmpty) {
                                    downloadAttachment(
                                        value.moveOutRequestList[position]
                                            .TENANT_CONSENT, _localPath);
                                  }else{
                                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                                  }
                                },
                                child: Row(
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
                            children: [
                              InkWell(
                                onTap: (){
                                  if(value.moveOutRequestList[position].OWNER_CONSENT.isNotEmpty) {
                                    downloadAttachment(
                                        value.moveOutRequestList[position]
                                            .OWNER_CONSENT, _localPath);
                                  }else{
                                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                                  }
                                },
                                child: Row(
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
                                  if(value.moveOutRequestList[position].AUTH_FORM.isNotEmpty) {
                                    downloadAttachment(
                                        value.moveOutRequestList[position]
                                            .AUTH_FORM, _localPath);
                                  }else{
                                    GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                                  }
                                },
                                child: Row(
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
                          Container(
                            child: Builder(
                                builder: (context) => ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: tenantDetailsList.length,
                                  itemBuilder: (context, position) {
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            if(tenantDetailsList[position].POLICE_VERIFICATION.isNotEmpty) {
                                              downloadAttachment(
                                                  tenantDetailsList[position].POLICE_VERIFICATION, _localPath);
                                            }else{
                                              GlobalFunctions.showToast(AppLocalizations.of(context).translate('document_not_available'));
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                  child: AppIcon(
                                                    Icons.attach_file,
                                                    iconColor: GlobalVariables.skyBlue,
                                                  )),
                                              SizedBox(width: 4,),
                                              Container(
                                                child: text(
                                                    tenantDetailsList[position].NAME+"'s "+AppLocalizations.of(context)
                                                        .translate('police_verification'),
                                                    fontSize: GlobalVariables.textSizeMedium,
                                                    textColor: GlobalVariables.skyBlue,
                                                    textStyleHeight: 1.0),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        )
                                      ],
                                    );
                                  },
                                  //  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                )),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  

}