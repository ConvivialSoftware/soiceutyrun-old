import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'base_stateful.dart';

class BaseFeedback extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FeedbackState();
  }
}

class FeedbackState extends BaseStatefulState<BaseFeedback> {

  TextEditingController complaintSubject = TextEditingController();
  TextEditingController complaintDesc = TextEditingController();
  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;
  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) =>
          Scaffold(
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
                AppLocalizations.of(context).translate('feedback'),
                textColor: GlobalVariables.white,fontSize: GlobalVariables.textSizeMedium
              ),
            ),
            body: getBaseLayout(),
          ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
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
                getRaiseTicketLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRaiseTicketLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 40, 18, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            children: <Widget>[
              AppTextField(textHintContent: AppLocalizations.of(context).translate('title'), controllerCallback: complaintSubject),
              /*Container(
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
                  controller: complaintSubject,
                  //maxLines: 99,
                  decoration: InputDecoration(
                      hintText:
                      AppLocalizations.of(context).translate('title'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium),
                      border: InputBorder.none),
                ),
              ),*/
              Container(
                height: 150,
                child: AppTextField(textHintContent: AppLocalizations.of(context)
                    .translate('complaint_desc'), controllerCallback: complaintDesc,maxLines: 99,),
              ),
            /*  Container(
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
                  controller: complaintDesc,
                  maxLines: 99,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .translate('complaint_desc'),
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium),
                      border: InputBorder.none),
                ),
              ),*/
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: attachmentFilePath == null ? BoxDecoration(
                        color: GlobalVariables.secondaryColor,
                        borderRadius: BorderRadius.circular(25),

                      ) : BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: FileImage(File(attachmentFilePath)),
                              fit: BoxFit.cover
                          ),
                          border: Border.all(
                              color: GlobalVariables.primaryColor, width: 2.0)
                      ),
                      //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: FlatButton.icon(
                            onPressed: () {
                              if (isStoragePermission) {
                                openFile(context);
                              } else {
                                GlobalFunctions.askPermission(
                                    Permission.storage).then((value) {
                                  if (value) {
                                    openFile(context);
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context).translate(
                                            'download_permission'));
                                  }
                                });
                              }
                            },
                            icon: AppIcon(
                              Icons.attach_file,
                              iconColor: GlobalVariables.secondaryColor,
                            ),
                            label: text(
                              AppLocalizations.of(context).translate(
                                  'attach_photo'),
                              textColor: GlobalVariables.primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                                      Permission.storage).then((value) {
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
                                iconColor: GlobalVariables.secondaryColor,
                              ),
                              label: text(
                                AppLocalizations.of(context)
                                    .translate('take_picture'),
                               textColor: GlobalVariables.primaryColor,
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
                    color: GlobalVariables.primaryColor,
                    onPressed: () {
                      verifyData();
                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: GlobalVariables.primaryColor)),
                    child: text(
                      AppLocalizations.of(context).translate('submit'),
                      fontSize: GlobalVariables.textSizeMedium,
                      textColor: GlobalVariables.white
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

  Future<void> addComplaint() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String societyName = await GlobalFunctions.getSocietyName();
    String attachmentName;
    String attachment;
    _progressDialog.show();
    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }

    restClient.addFeedback(
        societyId,
        block,
        flat,
        societyName,
        complaintSubject.text,
        complaintDesc.text,
        attachment).then((value) {
      _progressDialog.hide();
      if (value.status) {
        if (attachmentFileName != null && attachmentFilePath != null) {
          //GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
          GlobalFunctions.getTemporaryDirectoryPath()
              .then((value) {
            GlobalFunctions.removeAllFilesFromDirectory(
                value);
          });
        }
        Navigator.of(context).pop();
      }
      GlobalFunctions.showToast(value.message);
    });
  }


  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      getCompressFilePath();
    });
  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath = value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath() {
    attachmentFileName = attachmentFilePath.substring(
        attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
    print('file Name : ' + attachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
          attachmentFilePath, value.toString() + '/' + attachmentFileName)
          .then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentCompressFilePath);
        setState(() {});
      });
    });
  }

  void verifyData() {
    if (complaintSubject.text.length > 0) {
      if (complaintDesc.text.length > 0) {
        addComplaint();
      } else {
        GlobalFunctions.showToast("Please Enter Complaint Description");
      }
    } else {
      GlobalFunctions.showToast("Please Enter Complaint Subject");
    }
  }


}
