import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/AWS/AWSClient.dart';
import 'package:societyrun/Activities/AddTenant.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UploadItem.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseAddAgreement extends StatefulWidget {
  String block, flat;
  bool isAdmin;

  BaseAddAgreement(this.block, this.flat, this.isAdmin);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddAgreementState();
  }
}

class AddAgreementState extends BaseStatefulState<BaseAddAgreement> {
  String attachmentFilePath;
  String attachmentFileName;

  TextEditingController _agreementFromController = TextEditingController();
  TextEditingController _agreementToController = TextEditingController();
  TextEditingController _noOfBachelorController = TextEditingController();

  /*List<DropdownMenuItem<String>> _blockListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedBlock;

  List<DropdownMenuItem<String>> _flatListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedFlat;*/

  List<String> _rentedList = new List<String>();
  List<DropdownMenuItem<String>> _rentedToListItems =
  new List<DropdownMenuItem<String>>();
  String _selectedRentedTo;

  String _selectedIssueNOC;

  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

 // List<String> selectedUserList = List<String>();

  /*FlutterUploader uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  Map<String, UploadItem> _tasks = {};*/

  @override
  void initState() {
    super.initState();
    getRentedToData();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });

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
    });*/
  }

  @override
  void dispose() {
    super.dispose();
   // _progressSubscription?.cancel();
    //_resultSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context, value, child) {
        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: GlobalVariables.veryLightGray,
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
                  AppLocalizations.of(context).translate('add_agreement'),
                  textColor: GlobalVariables.white,
                  fontSize: GlobalVariables.textSizeMedium),
            ),
            body: getBaseLayout(value),
          ),
        );
      }),
    );
  }

  getBaseLayout(UserManagementResponse userManagementResponse) {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 200.0),
        getAddAgreementLayout(userManagementResponse),
      ],
    );
  }

  getAddAgreementLayout(UserManagementResponse userManagementResponse) {
    return SingleChildScrollView(
      child: AppContainer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.lightGray,
                    width: 2.0,
                  )),
              child: ButtonTheme(
                child: DropdownButtonFormField(
                  items: _rentedToListItems,
                  value: _selectedRentedTo,
                  onChanged: (value){
                    _selectedRentedTo=value;
                    setState(() {});
                  },
                  isExpanded: true,
                  icon: AppIcon(
                    Icons.keyboard_arrow_down,
                    iconColor: GlobalVariables.mediumGreen,
                  ),
                  decoration: InputDecoration(
                    //filled: true,
                    //fillColor: Hexcolor('#ecedec'),
                      labelText: AppLocalizations.of(context)
                          .translate('rented_to'),
                      labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent))
                    // border: new CustomBorderTextFieldSkin().getSkin(),
                  ),
                ),
              ),
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('start_date')+'*',
              controllerCallback: _agreementFromController,
              readOnly: true,
              contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              suffixIcon: AppIconButton(
                Icons.date_range,
                iconColor: GlobalVariables.mediumGreen,
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
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('end_date')+'*',
              controllerCallback: _agreementToController,
              readOnly: true,
              contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              suffixIcon: AppIconButton(
                Icons.date_range,
                iconColor: GlobalVariables.mediumGreen,
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
            _selectedRentedTo== AppLocalizations.of(context)
                .translate('group_bachelor') ? AppTextField(
                textHintContent: AppLocalizations.of(context).translate('no_of_bachelor'),
                controllerCallback: _noOfBachelorController,
              keyboardType: TextInputType.number,
            ):SizedBox(),
            widget.isAdmin
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('issue_NOC'),
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: InkWell(
                                  //  splashColor: GlobalVariables.mediumGreen,
                                  onTap: () {
                                    _selectedIssueNOC =
                                        AppLocalizations.of(context)
                                            .translate('yes');
                                    setState(() {});
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: _selectedIssueNOC ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('yes')
                                                  ? GlobalVariables.green
                                                  : GlobalVariables.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: _selectedIssueNOC ==
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate('yes')
                                                    ? GlobalVariables.green
                                                    : GlobalVariables
                                                        .mediumGreen,
                                                width: 2.0,
                                              )),
                                          child: AppIcon(Icons.check,
                                              iconColor:
                                                  GlobalVariables.white),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          child: text(
                                            AppLocalizations.of(context)
                                                .translate('yes'),
                                            textColor: GlobalVariables.green,
                                            fontSize: GlobalVariables
                                                .textSizeMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: InkWell(
                                  //  splashColor: GlobalVariables.mediumGreen,
                                  onTap: () {
                                    _selectedIssueNOC =
                                        AppLocalizations.of(context)
                                            .translate('no');
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
                                              color: _selectedIssueNOC ==
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('no')
                                                  ? GlobalVariables.green
                                                  : GlobalVariables.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: _selectedIssueNOC ==
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate('no')
                                                    ? GlobalVariables.green
                                                    : GlobalVariables
                                                        .mediumGreen,
                                                width: 2.0,
                                              )),
                                          child: AppIcon(Icons.check,
                                              iconColor:
                                                  GlobalVariables.white),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          child: text(
                                              AppLocalizations.of(context)
                                                  .translate('no'),
                                              textColor:
                                                  GlobalVariables.green,
                                              fontSize: GlobalVariables
                                                  .textSizeMedium),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
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
                                    openFile(context);
                                  } else {
                                    GlobalFunctions.askPermission(
                                            Permission.storage)
                                        .then((value) {
                                      if (value) {
                                        openFile(context);
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
                                  iconColor: GlobalVariables.mediumGreen,
                                  iconSize: 20.0,
                                ),
                                label: Flexible(
                                  child: text(
                                    attachmentFileName != null
                                        ? attachmentFileName
                                        : AppLocalizations.of(context)
                                            .translate('attach_agreement')+'*',
                                    textColor: GlobalVariables.green,
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
            Container(
              alignment: Alignment.topRight,
              height: 45,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: AppButton(
                textContent: AppLocalizations.of(context).translate('next'),
                onPressed: () {

                  if(verifyInfo()) {
                    AddAgreementInfo agreementInfo = AddAgreementInfo(
                      rentedTo: _selectedRentedTo,
                      startDate: _agreementFromController.text,
                      endDate: _agreementToController.text,
                      noOfBachelor: _noOfBachelorController.text.isEmpty
                          ? '1'
                          : _noOfBachelorController.text,
                      isNocEmail: _selectedIssueNOC,
                      agreementAttachmentPath: attachmentFilePath,
                      block: widget.block,
                      flat: widget.flat,
                      agreementAttachmentName: attachmentFileName
                    );

                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => BaseAddTenant(agreementInfo,widget.isAdmin)));
                  }
                  //verifyInfo();
                  //AWSClient().downloadData('uploads', 'file-sample_150kB.pdf');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getRentedToData() {
    _rentedList = ["Family","Group(Bachelor)","Other"];
    for (int i = 0; i < _rentedList.length; i++) {
      _rentedToListItems.add(DropdownMenuItem(
        value: _rentedList[i],
        child: text(
          _rentedList[i],
          textColor: GlobalVariables.black,
        ),
      ));
    }
    //  _selectedBloodGroup = __bloodGroupListItems[0].value;
  }

  bool verifyInfo() {
    /*if(selectedUserList.isNotEmpty) {

    }else{
      GlobalFunctions.showToast('Please Select User');
    }*/
    if (_selectedRentedTo != null) {
      if (_agreementFromController.text.length > 0) {
        if (_agreementToController.text.length > 0) {
          if (attachmentFilePath != null) {
            return true;
           // addAgreement();
          } else {
            GlobalFunctions.showToast('Please Select Agreement File');
          }
        } else {
          GlobalFunctions.showToast('Please Enter End Date');
        }
      } else {
        GlobalFunctions.showToast('Please Enter Start Date');
      }
    } else {
      GlobalFunctions.showToast('Please Select Rented To');
    }
    return false;
  }

  /*Future<void> addAgreement() async {
    if (_selectedRentedTo ==
        AppLocalizations.of(context).translate('group_bachelor')) {
      _selectedRentedTo = "Group";
    }
    //_progressDialog.show();

    if (attachmentFilePath != null && attachmentFileName != null) {
      print('attachmentFilePath : ' + attachmentFilePath.toString());
      print('attachmentFileName : ' + attachmentFileName.toString());
      print('attachmentFileName : ' +
          attachmentFilePath.replaceAll(attachmentFileName, "").toString());

    *//*  File file = File(attachmentFilePath);
      Uint8List bytes = file.readAsBytesSync();
      _progressDialog.show();
      AWSClient()
          .uploadData('uploads', attachmentFileName, bytes)
          .then((value) {
        _progressDialog.hide();
      });
*//*


       *//*final tag = "File upload ${_tasks.length + 1}";
            final taskId = await uploader.enqueue(
                url: "https://societyrun.com//Uploads/",
                //required: url to upload to
                files: [
                  FileItem(
                      filename: attachmentFileName,
                      savedDir: attachmentFilePath.replaceAll(
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
                        status: UploadTaskStatus.enqueued,
                      ));
            });*//*

    }
    *//*if (!widget.isAdmin) {
      _progressDialog.show();
      Provider.of<UserManagementResponse>(context, listen: false)
          .addAgreement(
              selectedUserList,
              _agreementStartDateController.text,
              _agreementEndDateController.text,
              attachmentFileName,
              _selectedRentedTo)
          .then((value) async {
        _progressDialog.hide();

        GlobalFunctions.showToast(value.message);
        if (value.status) {
           Navigator.of(context).pop();

        }
      });
    }
    else {
      _progressDialog.show();
      Provider.of<UserManagementResponse>(context, listen: false)
          .adminAddAgreement(
              selectedUserList,
              _agreementStartDateController.text,
              _agreementEndDateController.text,
              attachmentFileName,
              _selectedRentedTo,
              widget.block,
              widget.flat,
              _selectedIssueNOC)
          .then((value) async {
        _progressDialog.hide();

        GlobalFunctions.showToast(value.message);
        if (value.status) {
              Navigator.of(context).pop();

        }
      });
    }*//*
  }*/

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      attachmentFileName = attachmentFilePath.substring(
          attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
      print('file Name : ' + attachmentFileName.toString());
      setState(() {});
    });
  }

}

class AddAgreementInfo{

  String rentedTo,startDate,endDate,noOfBachelor,isNocEmail,agreementAttachmentPath,agreementAttachmentName,block,flat;

  AddAgreementInfo({this.rentedTo, this.startDate, this.endDate,
      this.noOfBachelor, this.isNocEmail, this.agreementAttachmentPath,this.block,this.flat,this.agreementAttachmentName});
}