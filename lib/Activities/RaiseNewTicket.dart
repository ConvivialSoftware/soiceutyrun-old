import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ComplaintCategory.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'HelpDesk.dart';
import 'base_stateful.dart';

class BaseRaiseNewTicket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RaiseNewTicketState();
  }
}

class RaiseNewTicketState extends BaseStatefulState<BaseRaiseNewTicket> {
  // List<ComplaintArea> _areaList = new List<ComplaintArea>();
  // List<ComplaintCategory> _categoryList = new List<ComplaintCategory>();
  String complaintType = "Personal";
  String complaintPriority = "No";

  TextEditingController complaintSubject = TextEditingController();

  TextEditingController complaintDesc = TextEditingController();

  // List<DropdownMenuItem<String>> __areaListItems = new List<DropdownMenuItem<String>>();
  // String _areaSelectedItem;

  List<DropdownMenuItem<String>> __categoryListItems =
      new List<DropdownMenuItem<String>>();

  String _categorySelectedItem;

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
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        //getComplaintAreaData();
        Provider.of<HelpDeskResponse>(context,listen: false)
            .getComplaintCategoryData()
            .then((value) {
          print('before setState list : '+value.toString());
          for (int i = 0; i < value.length; i++) {
            __categoryListItems.add(DropdownMenuItem(
              value: value[i].COMPLAINT_CATEGORY,
              child: text(
                value[i].COMPLAINT_CATEGORY,
                  textColor: GlobalVariables.green,
              ),
            ));
          }
          print('before setState');
          setState(() {});
        });
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<HelpDeskResponse>.value(
      value: Provider.of(context),
      child: Consumer<HelpDeskResponse>(
        builder: (context, value, child) {
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
                  AppLocalizations.of(context).translate('help_desk'),
                    textColor: GlobalVariables.white,
                ),
              ),
              body: getBaseLayout(value),
            ),
          );
        },
      ),
    );
  }

  getBaseLayout(HelpDeskResponse value) {
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
               value.isLoading ? GlobalFunctions.loadingWidget(context) : getRaiseTicketLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRaiseTicketLayout(HelpDeskResponse value) {
    print('Out If');
    if(value.complaintCategoryList.length>0){
      print('In If');
      for (int i = 0; i < value.complaintCategoryList.length; i++) {
        __categoryListItems.add(DropdownMenuItem(
          value: value.complaintCategoryList[i].COMPLAINT_CATEGORY,
          child: text(
            value.complaintCategoryList[i].COMPLAINT_CATEGORY,
              textColor: GlobalVariables.green,
          ),
        ));
      }
    }
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: text(
                  AppLocalizations.of(context).translate('raise_new_ticket'),
                    textColor: GlobalVariables.green,
                      fontSize: GlobalVariables.textSizeLargeMedium,
                      fontWeight: FontWeight.bold,
                ),
              ),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('subject') + '*',
                controllerCallback: complaintSubject,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
/*
                          AppLocalizations.of(context)
                              .translate('personal')*/
                          complaintType = "Personal";
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
                                    color: complaintType == "Personal"
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: complaintType == "Personal"
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
                                      .translate('personal'),
                                    textColor: GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeMedium,
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
                          complaintType = "Community";
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
                                    color: complaintType != "Personal"
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: complaintType != "Personal"
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
                                      .translate('community'),
    textColor: GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: __categoryListItems,
                    value: _categorySelectedItem,
                    onChanged: changeCategoryDropDownItem,
                    isExpanded: true,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: text(
                      AppLocalizations.of(context)
                              .translate('select_category') +
                          '*',
                        textColor: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSMedium,
                    ),
                  ),
                ),
              ),
              Container(
                height: 150,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('complaint_desc') +
                          '*',
                  controllerCallback: complaintDesc,
                  maxLines: 99,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                ),
                /*padding: EdgeInsets.all(10),
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
                          .translate('complaint_desc')+'*',
                      hintStyle: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                      border: InputBorder.none),
                ),*/
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    /*Container(
                      width:50,
                      height: 50,
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: attachmentFilePath==null ? BoxDecoration(
                        color: GlobalVariables.mediumGreen,
                        borderRadius: BorderRadius.circular(25),

                      ) : BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: FileImage(File(attachmentFilePath)),
                              fit: BoxFit.cover
                          ),
                          border: Border.all(color: GlobalVariables.green,width: 2.0)
                      ),
                      //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                    )*/
                    attachmentFilePath == null
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
                          )
                        : AppFileImage(
                            attachmentFilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
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
                                        Permission.storage)
                                    .then((value) {
                                  if (value) {
                                    openFile(context);
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context)
                                            .translate('download_permission'));
                                  }
                                });
                              }
                            },
                            icon: AppIcon(
                              Icons.attach_file,
                              iconColor: GlobalVariables.mediumGreen,
                            ),
                            label: text(
                              AppLocalizations.of(context)
                                  .translate('attach_photo'),
                                textColor: GlobalVariables.green,
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
                                  textColor: GlobalVariables.green,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /*   Container(
                alignment: Alignment.topLeft,
                child: Text(
                  attachmentFileName==null ? "" : attachmentFileName,
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),*/
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        complaintPriority == "No"
                            ? complaintPriority = "Yes"
                            : complaintPriority = "No";
                        setState(() {});
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: complaintPriority == "No"
                                ? GlobalVariables.white
                                : GlobalVariables.green,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: complaintPriority == "No"
                                  ? GlobalVariables.mediumGreen
                                  : GlobalVariables.transparent,
                              width: 2.0,
                            )),
                        child: AppIcon(Icons.check, iconColor: GlobalVariables.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: text(
                        AppLocalizations.of(context)
                            .translate('mark_as_urgent'),
                          textColor: GlobalVariables.green, fontSize: GlobalVariables.textSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('submit'),
                  onPressed: () {
                    verifyData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*

  void changeAreaDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _areaSelectedItem = value;
      print('_selctedItem:' + _areaSelectedItem.toString());
    });
  }

*/

  void changeCategoryDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _categorySelectedItem = value;
      print('_selctedItem:' + _categorySelectedItem.toString());
    });
  }

/*

  void getComplaintAreaData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getComplaintsAreaData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

      //  print("area list : "+_list.toString());
        _areaList = List<ComplaintArea>.from(_list.map((i)=>ComplaintArea.fromJson(i)));

        for(int i=0;i<_areaList.length;i++){
          __areaListItems.add(DropdownMenuItem(
            value: _areaList[i].COMPLAINT_AREA,
            child: Text(
              _areaList[i].COMPLAINT_AREA,
              style: TextStyle(color: GlobalVariables.green),
            ),
          ));
        }
     //   _areaSelectedItem = __areaListItems[0].value;

      }
    });

  }
*/

 /* void getComplaintCategoryData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getComplaintsCategoryData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        //  print("category list : "+_list.toString());
        _categoryList = List<ComplaintCategory>.from(
            _list.map((i) => ComplaintCategory.fromJson(i)));

        for (int i = 0; i < _categoryList.length; i++) {
          __categoryListItems.add(DropdownMenuItem(
            value: _categoryList[i].COMPLAINT_CATEGORY,
            child: Text(
              _categoryList[i].COMPLAINT_CATEGORY,
              style: TextStyle(color: GlobalVariables.green),
            ),
          ));
        }
        //_categorySelectedItem = __categoryListItems[0].value;

        setState(() {});
      }
      _progressDialog.hide();
    });
//800423_2020\-07\-30_20\:06\:12\.jpg
  }
*/
  Future<void> addComplaint() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    String name = await GlobalFunctions.getDisplayName();

    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();
    String userEmail = await GlobalFunctions.getUserName();

    String attachmentName;
    String attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }
    _progressDialog.show();
    restClient
        .addComplaint(
            societyId,
            block,
            flat,
            userId,
            complaintSubject.text,
            complaintType,
            /*_areaSelectedItem,*/
            _categorySelectedItem,
            complaintDesc.text,
            complaintPriority,
            name,
            attachment,
            attachmentName,
            societyName,
            userEmail,
            societyEmail)
        .then((value) {
      print("add complaint response : " + value.toString());
      _progressDialog.hide();
      if (value.status) {
        if (attachmentFileName != null && attachmentFilePath != null) {
          GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
        }
        Navigator.of(context).pop('back');
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => BaseHelpDesk(false)));*/
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
      //  if(_areaSelectedItem!=null){

      if (_categorySelectedItem != null) {
        if (complaintDesc.text.length > 0) {
          addComplaint();
        } else {
          GlobalFunctions.showToast("Please Enter Complaint Description");
        }
      } else {
        GlobalFunctions.showToast("Please Select Complaint Category");
      }

      /* }else{
        GlobalFunctions.showToast("Please Select Complaint Area");
      }
*/
    } else {
      GlobalFunctions.showToast("Please Enter Complaint Subject");
    }
  }
}
