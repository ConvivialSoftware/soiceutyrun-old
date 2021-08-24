import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseAddNewMemberByAdmin extends StatefulWidget {
  String block,flat;


  BaseAddNewMemberByAdmin(this.block, this.flat);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddNewMemberByAdminState();
  }
}

class AddNewMemberByAdminState
    extends BaseStatefulState<BaseAddNewMemberByAdmin> {


  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _notModeratorController = TextEditingController();


  /*List<DropdownMenuItem<String>> _blockListItems =
  new List<DropdownMenuItem<String>>();
  String _selectedBlock;

  List<DropdownMenuItem<String>> _flatListItems =
  new List<DropdownMenuItem<String>>();
  String _selectedFlat;*/

  List<String> _membershipTypeList = new List<String>();
  List<DropdownMenuItem<String>> __membershipTypeListItems =
  new List<DropdownMenuItem<String>>();
  String _selectedMembershipType;

  List<String> _livesHereList = new List<String>();
  List<DropdownMenuItem<String>> __livesHereListItems =
  new List<DropdownMenuItem<String>>();
  String _selectedLivesHere;

  ProgressDialog _progressDialog;
  bool isStoragePermission = false;

  @override
  void initState() {
    super.initState();
    /*Provider.of<UserManagementResponse>(context,listen: false).getBlock().then((value) {
      //setBlockData(value);
      //_selectedBlock=widget.block;
      print('widget.block : '+widget.block.toString());
      print('widget.flat : '+widget.flat.toString());
      Provider.of<UserManagementResponse>(context,listen: false).getFlat(widget.block).then((value) {
        setFlatData(value);
      });
    });
*/
    getMembershipTypeData();
    gteLivesHereData();
    //_dobController.text = DateTime.now().toLocal().day.toString().padLeft(2, '0')+"-"+DateTime.now().toLocal().month.toString().padLeft(2, '0')+"-"+DateTime.now().toLocal().year.toString();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value:Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder:(context,value,child){
        return Builder(
          builder: (context) =>
              Scaffold(
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
                      AppLocalizations.of(context).translate('add_new_member'),
                      textColor: GlobalVariables.white,
                      fontSize: GlobalVariables.textSizeMedium
                  ),
                ),
                body: getBaseLayout(value),
              ),
        );
      }),

    );
  }

  getBaseLayout(UserManagementResponse userManagementResponse) {
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
                getAddNewMemberByAdminLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAddNewMemberByAdminLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(18, 40, 18, 40),
        padding: EdgeInsets.all(20),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            children: <Widget>[
             /* Row(
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
                            _selectedBlock=value;
                            _flatListItems = new List<DropdownMenuItem<String>>();
                            _selectedFlat=null;
                            Provider.of<UserManagementResponse>(context,listen: false).getFlat(_selectedBlock).then((value) {
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
                            AppLocalizations.of(context)
                                .translate('block'),
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
                            _selectedFlat=value;
                            setState(() {

                            });
                          },
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: text(
                            AppLocalizations.of(context)
                                .translate('flat'),
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),*/
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('name') + '*',
                controllerCallback: _nameController,
              ),
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('contact1') + '*',
                controllerCallback: _mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                contentPadding: EdgeInsets.only(top: 14),
                suffixIcon: AppIconButton(
                  Icons.phone_android,
                  iconColor: GlobalVariables.mediumGreen,
                ),
              ),
              AppTextField(
                textHintContent:
                AppLocalizations.of(context).translate('email_id'),
                controllerCallback: _emailController,
                keyboardType: TextInputType.emailAddress,
                contentPadding: EdgeInsets.only(top: 14),
                suffixIcon: AppIconButton(
                  Icons.email,
                  iconColor: GlobalVariables.mediumGreen,
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.lightGray,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButtonFormField(
                          items: __membershipTypeListItems,
                          value: _selectedMembershipType,
                          onChanged: changeMembershipTypeDropDownItem,
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                          /*underline: SizedBox(),
                          hint: text(
                            AppLocalizations.of(context)
                                .translate('membership_type') +
                                '*',
                            textColor: GlobalVariables.lightGray,
                            fontSize: GlobalVariables.textSizeSMedium,
                          ),*/
                          decoration: InputDecoration(
                            //filled: true,
                            //fillColor: Hexcolor('#ecedec'),
                              labelText: AppLocalizations.of(context)
                                  .translate('membership_type') +
                                  '*',
                              labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent))
                            // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
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
                          items: __livesHereListItems,
                          value: _selectedLivesHere,
                          onChanged: changeLivesHereDropDownItem,
                          isExpanded: true,
                          icon: AppIcon(
                            Icons.keyboard_arrow_down,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                         /* underline: SizedBox(),
                          hint: text(
                              AppLocalizations.of(context)
                                  .translate('lives_here') +
                                  '*',
                              textColor: GlobalVariables.lightGray,
                              fontSize: GlobalVariables.textSizeSMedium),*/
                          decoration: InputDecoration(
                            //filled: true,
                            //fillColor: Hexcolor('#ecedec'),
                              labelText: AppLocalizations.of(context)
                                  .translate('lives_here') +
                                  '*',
                              labelStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeSMedium),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent))
                            // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
             /* Visibility(
                visible: _selectedMembershipType=='Tenant' ,
                child: Container(
                  child: Column(
                    children: [

                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: Alignment.topLeft,
                        child: text(AppLocalizations.of(context).translate('issue_NOC'),
                          fontSize: GlobalVariables.textSizeSMedium,
                          textColor: GlobalVariables.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: InkWell(
                                //  splashColor: GlobalVariables.mediumGreen,
                                onTap: () {
                                  _selectedIssueNOC = AppLocalizations.of(context)
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
                                            color: _selectedIssueNOC == AppLocalizations.of(context)
                                                .translate('yes')
                                                ? GlobalVariables.green
                                                : GlobalVariables.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: _selectedIssueNOC == AppLocalizations.of(context)
                                                  .translate('yes')
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
                                              .translate('yes'),
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
                                  _selectedIssueNOC = AppLocalizations.of(context)
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
                                            color: _selectedIssueNOC == AppLocalizations.of(context)
                                                .translate('no')
                                                ? GlobalVariables.green
                                                : GlobalVariables.white,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: _selectedIssueNOC == AppLocalizations.of(context)
                                                  .translate('no')
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
                                                .translate('no'),
                                            textColor: GlobalVariables.green,
                                            fontSize: GlobalVariables.textSizeMedium),
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
              ),*/
              Container(
                height: 100,
                child: AppTextField(
                  textHintContent:
                  AppLocalizations.of(context).translate('address'),
                  controllerCallback: _addressController,
                  maxLines: 99,
                  contentPadding: EdgeInsets.only(top: 14),
                ),
              ),
              Container(
                height: 100,
                child: AppTextField(
                  textHintContent:
                  AppLocalizations.of(context).translate('note_for_moderator'),
                  controllerCallback: _notModeratorController,
                  maxLines: 99,
                  contentPadding: EdgeInsets.only(top: 14),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
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
                                  label: text(
                                    AppLocalizations.of(context)
                                        .translate('attach_photo'),
                                    textColor: GlobalVariables.green,
                                  ),
                                ),
                              ),
                              Container(
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
                              ),
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
    /*if (_selectedBlock != null) {
      if (_selectedFlat != null) {

      } else {
        GlobalFunctions.showToast("Please Select Flat");
      }
    } else {
      GlobalFunctions.showToast("Please Select Block");
    }*/
    if (_nameController.text.length > 0) {
      //if (_mobileController.text.length > 0) {
      if (_selectedMembershipType != null) {
        if (_selectedLivesHere != null) {
          addMember();
        } else {
          GlobalFunctions.showToast('Please Select Lives Here');
        }
      } else {
        GlobalFunctions.showToast('Please Select MemberShip Type');
      }
    } else {
      GlobalFunctions.showToast('Please Enter Name');
    }
  }

  Future<void> addMember() async {
    String attachmentName;
    String attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }

    _progressDialog.show();

    Provider.of<UserManagementResponse>(context,listen: false).addMemberByAdmin(
        widget.block,
        widget.flat,
        _nameController.text,
        _mobileController.text,
        _emailController.text,
        _selectedMembershipType,
        _selectedLivesHere, _addressController.text,
        _notModeratorController.text, attachment).then((value) {

      _progressDialog.hide();

      GlobalFunctions.showToast(value.message);
      if (value.status) {
        Navigator.of(context).pop();
      }
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

  getMembershipTypeData() {
//Tenantype
    _membershipTypeList = ["Owner", "Co-Owner", "Associate Member", "Owner Family"];
    for (int i = 0; i < _membershipTypeList.length; i++) {
      __membershipTypeListItems.add(DropdownMenuItem(
        value: _membershipTypeList[i],
        child: text(
          _membershipTypeList[i],
          textColor: GlobalVariables.black,
        ),
      ));
    }
    setState(() {});
    // _selectedMembershipType = __membershipTypeListItems[0].value;
  }

  void gteLivesHereData() {
    _livesHereList = ["Yes", "No"];
    for (int i = 0; i < _livesHereList.length; i++) {
      __livesHereListItems.add(DropdownMenuItem(
        value: _livesHereList[i],
        child: text(
          _livesHereList[i],
          textColor: GlobalVariables.black,
        ),
      ));
    }
    //   x
    setState(() {});
  }

  void changeMembershipTypeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedMembershipType = value;
      print('_selctedItem:' + _selectedMembershipType.toString());
    });
  }

  void changeLivesHereDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedLivesHere = value;
      print('_selctedItem:' + _selectedLivesHere.toString());
    });
  }

/*
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

    if(_selectedFlat==null){
      _selectedFlat=widget.flat;
    }
    setState(() {});

  }
*/


}
