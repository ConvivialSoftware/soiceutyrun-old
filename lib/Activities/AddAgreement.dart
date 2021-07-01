import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/AWS/AWSClient.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UploadItem.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
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
  String attachmentCompressFilePath;

  TextEditingController _agreementStartDateController = TextEditingController();
  TextEditingController _agreementEndDateController = TextEditingController();

  List<DropdownMenuItem<String>> _blockListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedBlock;

  List<DropdownMenuItem<String>> _flatListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedFlat;

  String _selectedRentedTo;
  String _selectedIssueNOC;

  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

  List<String> selectedUserList = List<String>();

  FlutterUploader uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  Map<String, UploadItem> _tasks = {};

  @override
  void initState() {
    super.initState();
    Provider.of<UserManagementResponse>(context, listen: false)
        .getBlock()
        .then((value) {
      setBlockData(value);
      _selectedBlock = widget.block;
      print('widget.block : ' + widget.block.toString());
      print('widget.flat : ' + widget.flat.toString());
      Provider.of<UserManagementResponse>(context, listen: false)
          .getFlat(widget.block)
          .then((value) {
        setFlatData(value);
      });
    });
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });

    _progressSubscription = uploader.progress.listen((progress) {
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
  }

  @override
  void dispose() {
    super.dispose();
    _progressSubscription?.cancel();
    _resultSubscription?.cancel();
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
                getAddAgreementLayout(userManagementResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAddAgreementLayout(UserManagementResponse userManagementResponse) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(20),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              /*Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: _blockListItems,
                          value: _selectedBlock,
                          onChanged: (value) {
                            _selectedBlock = value;
                            _flatListItems =
                                new List<DropdownMenuItem<String>>();
                            _selectedFlat = null;
                            Provider.of<UserManagementResponse>(context,
                                    listen: false)
                                .getFlat(_selectedBlock)
                                .then((value) {
                              setFlatData(value);
                            });
                          },
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: text(
                            AppLocalizations.of(context).translate('block'),
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: _flatListItems,
                          value: _selectedFlat,
                          onChanged: (value) {
                            _selectedFlat = value;
                            setState(() {});
                          },
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: text(
                            AppLocalizations.of(context).translate('flat'),
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),*/
             /* Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                alignment: Alignment.center,
                child: text(widget.block + ' ' + widget.flat,
                    fontSize: GlobalVariables.textSizeNormal,
                    textColor: GlobalVariables.green,
                    fontWeight: FontWeight.bold),
              ),*/
              Container(
                //   color: GlobalVariables.grey,
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Builder(
                    builder: (context) => ListView.builder(
                          // scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.isAdmin
                              ? userManagementResponse.tenantListForAdmin.length
                              : userManagementResponse.tenantList.length,
                          itemBuilder: (context, position) {
                            return Container(
                              // width: MediaQuery.of(context).size.width / 1.1,
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: GlobalVariables.white),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (selectedUserList.contains(widget
                                                  .isAdmin
                                              ? userManagementResponse
                                                  .tenantListForAdmin[position]
                                                  .ID
                                              : userManagementResponse
                                                  .tenantList[position].ID)) {
                                            selectedUserList.remove(
                                                widget.isAdmin
                                                    ? userManagementResponse
                                                        .tenantListForAdmin[
                                                            position]
                                                        .ID
                                                    : userManagementResponse
                                                        .tenantList[position]
                                                        .ID);
                                          } else {
                                            selectedUserList.add(widget.isAdmin
                                                ? userManagementResponse
                                                    .tenantListForAdmin[
                                                        position]
                                                    .ID
                                                : userManagementResponse
                                                    .tenantList[position].ID);
                                          }

                                          print('inviteUserList : ' +
                                              selectedUserList.toString());
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: selectedUserList.contains(widget
                                                          .isAdmin
                                                      ? userManagementResponse
                                                          .tenantListForAdmin[
                                                              position]
                                                          .ID
                                                      : userManagementResponse
                                                          .tenantList[position]
                                                          .ID)
                                                  ? GlobalVariables.green
                                                  : GlobalVariables.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: selectedUserList.contains(widget
                                                            .isAdmin
                                                        ? userManagementResponse
                                                            .tenantListForAdmin[
                                                                position]
                                                            .ID
                                                        : userManagementResponse
                                                            .tenantList[
                                                                position]
                                                            .ID)
                                                    ? GlobalVariables.green
                                                    : GlobalVariables
                                                        .mediumGreen,
                                                width: 2.0,
                                              )),
                                          child: AppIcon(
                                            Icons.check,
                                            iconColor: selectedUserList
                                                    .contains(widget.isAdmin
                                                        ? userManagementResponse
                                                            .tenantListForAdmin[
                                                                position]
                                                            .ID
                                                        : userManagementResponse
                                                            .tenantList[
                                                                position]
                                                            .ID)
                                                ? GlobalVariables.white
                                                : GlobalVariables.transparent,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                //  color:GlobalVariables.grey,
                                                child: text(
                                                    widget.isAdmin
                                                        ? userManagementResponse
                                                            .tenantListForAdmin[
                                                                position]
                                                            .NAME
                                                        : userManagementResponse
                                                            .tenantList[
                                                                position]
                                                            .NAME,
                                                    textColor:
                                                        GlobalVariables.green,
                                                    fontSize: GlobalVariables
                                                        .textSizeMedium,
                                                    fontWeight: FontWeight.bold,
                                                    textStyleHeight: 1.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }, //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              ),
              divider(),
              Container(
                child: Column(
                  children: [
                    /*Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      alignment: Alignment.topLeft,
                      child: text(
                          AppLocalizations.of(context).translate('rented_to'),
                          fontSize: GlobalVariables.textSizeSMedium,
                          textColor: GlobalVariables.black,
                          fontWeight: FontWeight.bold),
                    ),*/
                    Container(
                      // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: InkWell(
                              //  splashColor: GlobalVariables.mediumGreen,
                              onTap: () {
                                _selectedRentedTo = AppLocalizations.of(context)
                                    .translate('family');
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
                                          color: _selectedRentedTo ==
                                                  AppLocalizations.of(context)
                                                      .translate('family')
                                              ? GlobalVariables.green
                                              : GlobalVariables.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _selectedRentedTo ==
                                                    AppLocalizations.of(context)
                                                        .translate('family')
                                                ? GlobalVariables.green
                                                : GlobalVariables.mediumGreen,
                                            width: 2.0,
                                          )),
                                      child: AppIcon(Icons.check,
                                          iconColor: GlobalVariables.white),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: text(
                                        AppLocalizations.of(context)
                                            .translate('family'),
                                        textColor: GlobalVariables.green,
                                        fontSize:
                                            GlobalVariables.textSizeMedium,
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
                                _selectedRentedTo = AppLocalizations.of(context)
                                    .translate('group_bachelor');
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
                                          color: _selectedRentedTo ==
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          'group_bachelor')
                                              ? GlobalVariables.green
                                              : GlobalVariables.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _selectedRentedTo ==
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'group_bachelor')
                                                ? GlobalVariables.green
                                                : GlobalVariables.mediumGreen,
                                            width: 2.0,
                                          )),
                                      child: AppIcon(Icons.check,
                                          iconColor: GlobalVariables.white),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: text(
                                          AppLocalizations.of(context)
                                              .translate('group_bachelor'),
                                          textColor: GlobalVariables.green,
                                          fontSize:
                                              GlobalVariables.textSizeMedium),
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
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('start_date'),
                controllerCallback: _agreementStartDateController,
                readOnly: true,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.mediumGreen,
                  onPressed: () {
                    GlobalFunctions.getSelectedDate(context).then((value) {
                      _agreementStartDateController.text =
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
                    AppLocalizations.of(context).translate('end_date'),
                controllerCallback: _agreementEndDateController,
                readOnly: true,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.mediumGreen,
                  onPressed: () {
                    GlobalFunctions.getSelectedDate(context).then((value) {
                      _agreementEndDateController.text =
                          value.day.toString().padLeft(2, '0') +
                              "-" +
                              value.month.toString().padLeft(2, '0') +
                              "-" +
                              value.year.toString();
                    });
                  },
                ),
              ),
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
                          /* Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            decoration: attachmentFilePath == null
                                ? BoxDecoration(
                                    color: GlobalVariables.mediumGreen,
                                    borderRadius: BorderRadius.circular(25),
                                    //   border: Border.all(color: GlobalVariables.green,width: 2.0)
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image:
                                            FileImage(File(attachmentFilePath)),
                                        fit: BoxFit.cover),
                                    border: Border.all(
                                        color: GlobalVariables.green,
                                        width: 2.0)),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),*/
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
                                  ),
                                  label: Flexible(
                                    child: text(
                                      attachmentFileName != null
                                          ? attachmentFileName
                                          : AppLocalizations.of(context)
                                              .translate('attach_agreement'),
                                      textColor: GlobalVariables.green,
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
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyInfo();
                    //AWSClient().downloadData('uploads', 'file-sample_150kB.pdf');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void verifyInfo() {
    if (_selectedBlock != null) {
      if (_selectedFlat != null) {
        if (_selectedRentedTo != null) {
          if (_agreementStartDateController.text.length > 0) {
            if (_agreementEndDateController.text.length > 0) {
              addAgreement();
            } else {
              GlobalFunctions.showToast('Please Enter End Date');
            }
          } else {
            GlobalFunctions.showToast('Please Enter Start Date');
          }
        } else {
          GlobalFunctions.showToast('Please Select Rented To');
        }
      } else {
        GlobalFunctions.showToast("Please Select Flat");
      }
    } else {
      GlobalFunctions.showToast("Please Select Block");
    }
  }

  Future<void> addAgreement() async {
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

    /*  File file = File(attachmentFilePath);
      Uint8List bytes = file.readAsBytesSync();
      _progressDialog.show();
      AWSClient()
          .uploadData('uploads', attachmentFileName, bytes)
          .then((value) {
        _progressDialog.hide();
      });
*/


       final tag = "File upload ${_tasks.length + 1}";
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
            });

    }
    if (!widget.isAdmin) {
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
    } else {
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
    }
  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath = value;
      attachmentFileName = attachmentFilePath.substring(
          attachmentFilePath.lastIndexOf('/') + 1, attachmentFilePath.length);
      print('file Name : ' + attachmentFileName.toString());
      setState(() {});
    });
  }

  void setBlockData(List<Block> _blockList) {
    for (int i = 0; i < _blockList.length; i++) {
      _blockListItems.add(DropdownMenuItem(
        value: _blockList[i].BLOCK,
        child: text(
          _blockList[i].BLOCK,
          textColor: GlobalVariables.black,
        ),
      ));
    }

    setState(() {});
  }

  void setFlatData(List<Flat> _flatList) {
    for (int i = 0; i < _flatList.length; i++) {
      //print(_flatList[i].FLAT.toString());
      _flatListItems.add(DropdownMenuItem(
        value: _flatList[i].FLAT,
        child: text(
          _flatList[i].FLAT,
          textColor: GlobalVariables.black,
        ),
      ));
    }
    print('widget.flat :' + widget.flat.toString());

    if (_selectedFlat == null) {
      _selectedFlat = widget.flat;
    }
    setState(() {});
  }
}
