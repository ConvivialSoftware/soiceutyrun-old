import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

import 'base_stateful.dart';

class BaseEditProfileInfo extends StatefulWidget {

  String userId,societyId;
  BaseEditProfileInfo(this.userId,this.societyId);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditProfileInfoState(this.userId,this.societyId);
  }
}

class EditProfileInfoState extends BaseStatefulState<BaseEditProfileInfo> {

  String userId,societyId;

  String attachmentFilePath;
  String attachmentFileName;
  String attachmentCompressFilePath;

  List<ProfileInfo> _profileList = List<ProfileInfo>();

  EditProfileInfoState(this.userId, this.societyId);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _alterMobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _hobbiesController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<String> _bloodGroupList = new List<String>();
  List<DropdownMenuItem<String>> __bloodGroupListItems = new List<DropdownMenuItem<String>>();
  String _selectedBloodGroup;

  List<String> _membershipTypeList = new List<String>();
  List<DropdownMenuItem<String>> __membershipTypeListItems = new List<DropdownMenuItem<String>>();
  String _selectedMembershipType;


  List<String> _livesHereList = new List<String>();
  List<DropdownMenuItem<String>> __livesHereListItems = new List<DropdownMenuItem<String>>();
  String _selectedLivesHere;

 // String _selectedOccupation="Software Engg.";
  String _selectedGender="Male";
  ProgressDialog _progressDialog;
  bool isStoragePermission=false;


  @override
  void initState() {
    super.initState();
    getBloodGroupData();
    getMembershipTypeData();
    gteLivesHereData();
    _dobController.text = DateTime.now().toLocal().day.toString().padLeft(2, '0')+"/"+DateTime.now().toLocal().month.toString().padLeft(2, '0')+"/"+DateTime.now().toLocal().year.toString();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission=value;
    });
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getProfileData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
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
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('edit_profile'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
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
                getEditProfileInfoLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getEditProfileInfoLayout() {
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
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('name')+'*',
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none
                  ),
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
                          _selectedGender = "Male";
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
                                    color:   _selectedGender== "Male" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender== "Male" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('male'),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
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
                          _selectedGender="Female";
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
                                    color: _selectedGender== "Female" ? GlobalVariables.green : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender== "Female" ? GlobalVariables.green : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('female'),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 16),
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
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 10, 5, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )
                      ),
                      child: TextField(
                        controller: _dobController,
                        readOnly: true,
                        style: TextStyle(
                            color: GlobalVariables.green
                        ),
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate('date_of_birth'),
                            hintStyle: TextStyle(color: GlobalVariables.veryLightGray ,fontSize: 16),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                onPressed: (){

                                  GlobalFunctions.getSelectedDateForDOB(context).then((value){
                                    _dobController.text = value.day.toString().padLeft(2, '0')+"/"+value.month.toString().padLeft(2, '0')+"/"+value.year.toString();
                                  });

                                },
                                icon: Icon(Icons.date_range,color: GlobalVariables.mediumGreen,))
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )
                      ),
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: TextStyle(color: GlobalVariables.black),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: AppLocalizations.of(context)
                              .translate('contact1')+'*',
                          hintStyle: TextStyle(
                            color: GlobalVariables.lightGray,
                          ),
                          suffixIcon: Icon(
                            Icons.phone_android,
                            color: GlobalVariables.lightGreen,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          //contentPadding: EdgeInsets.only(left: 0, bottom: 0, top:0 , right: 0),
                         /* enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: GlobalVariables.mediumGreen,
                                width: 3.0,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: GlobalVariables.mediumGreen, width: 3.0),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),*/
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _alterMobileController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  style: TextStyle(color: GlobalVariables.black),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: AppLocalizations.of(context)
                        .translate('contact2'),
                    hintStyle: TextStyle(
                      color: GlobalVariables.lightGray,
                    ),
                    suffixIcon: Icon(
                      Icons.phone_android,
                      color: GlobalVariables.lightGreen,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    //contentPadding: EdgeInsets.only(left: 0, bottom: 0, top:0 , right: 0),
                    /* enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: GlobalVariables.mediumGreen,
                                width: 3.0,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: GlobalVariables.mediumGreen, width: 3.0),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),*/
                  ),
                ),
              ),
              Container(
               padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('email_id'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.email,
                      color: GlobalVariables.lightGreen,
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: __membershipTypeListItems,
                          value: _selectedMembershipType,
                          onChanged: changeMembershipTypeDropDownItem,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('membership_type')+'*',
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 16),
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
                      margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: __livesHereListItems,
                          value: _selectedLivesHere,
                          onChanged: changeLivesHereDropDownItem,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('lives_here')+'*',
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )
                      ),
                      child: TextField(
                        controller: _occupationController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate('occupation'),
                            hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                            border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 3.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: __bloodGroupListItems,
                          value: _selectedBloodGroup,
                          onChanged: changeBloodGroupDropDownItem,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('blood_group'),
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )
                  ),
                  child: TextField(
                    controller: _hobbiesController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).translate('hobbies'),
                        hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                        border: InputBorder.none
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  height: 100,
                 padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )
                  ),
                  child: TextField(
                    controller: _infoController,
                    keyboardType: TextInputType.text,
                    maxLines: 99,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('additional_info'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: true,
                child: Container(
                  height: 100,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )
                  ),
                  child: TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.text,
                    maxLines: 99,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).translate('address'),
                        hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                        border: InputBorder.none
                    ),
                  ),
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
                            width:50,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            decoration: attachmentFilePath==null ? BoxDecoration(
                              color: GlobalVariables.mediumGreen,
                              borderRadius: BorderRadius.circular(25),

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: attachmentFilePath.contains("http") ? NetworkImage(attachmentFilePath) : FileImage(File(attachmentFilePath)) ,
                                    fit: BoxFit.cover
                                ),
                                border: Border.all(color: GlobalVariables.green,width: 2.0)
                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: FlatButton.icon(
                                  onPressed: () {

                                    if(isStoragePermission) {
                                      openFile(context);
                                    }else{
                                      GlobalFunctions.askPermission(Permission.storage).then((value) {
                                        if(value){
                                          openFile(context);
                                        }else{
                                          GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                        }
                                      });
                                    }

                                  },
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context).translate('attach_photo'),
                                    style: TextStyle(color: GlobalVariables.green),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: GlobalVariables.lightGray),
                                ),
                              ),
                              Container(
                                child: FlatButton.icon(
                                    onPressed: () {

                                      if(isStoragePermission) {
                                        openCamera(context);
                                      }else{
                                        GlobalFunctions.askPermission(Permission.storage).then((value) {
                                          if(value){
                                            openCamera(context);
                                          }else{
                                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('download_permission'));
                                          }
                                        });
                                      }

                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: GlobalVariables.mediumGreen,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)
                                          .translate('take_picture'),
                                      style: TextStyle(color: GlobalVariables.green),
                                    )),
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
                child: ButtonTheme(
                 // minWidth: MediaQuery.of(context).size.width/2,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {
                      print('call Verify');
                      verifyInfo();

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('submit'),
                      style: TextStyle(
                          fontSize: GlobalVariables.largeText),
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

  void verifyInfo() {

    if(_nameController.text.length>0){

      //if(_dobController.text.length>0){

        if(_mobileController.text.length>0){

        //  if(_emailController.text.length>0){

           // if(_selectedBloodGroup!=null || _selectedBloodGroup.length>0){

             // if(_occupationController.text.length>0){


                  if(_selectedMembershipType!=null) {

                    if(_selectedLivesHere!=null) {

                      editProfileData();

                    }else{
                      GlobalFunctions.showToast('Please Select Lives Here');
                    }
                  }else{
                    GlobalFunctions.showToast('Please Select MemberShip Type');
                  }

              /*}else{
                GlobalFunctions.showToast('Please Enter Occupation');
              }*/
           /* }else{
              GlobalFunctions.showToast('Please Select BloodGroup');
            }*/
          /*}else{
            GlobalFunctions.showToast('Please Enter EmailId');
          }*/
        }else{
          GlobalFunctions.showToast('Please Enter Mobile Number');
        }
      /*}else{
        GlobalFunctions.showToast('Please Select Date of Birth');
      }*/
    }else{
      GlobalFunctions.showToast('Please Enter Name');
    }

  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath=value;
      getCompressFilePath();
    });

  }

  void openCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentFilePath=value.path;
      getCompressFilePath();
    });
  }

  void getCompressFilePath(){
    attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
    print('file Name : '+attachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : '+value.toString());
      GlobalFunctions.getFilePathOfCompressImage(attachmentFilePath, value.toString()+'/'+attachmentFileName).then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : '+attachmentCompressFilePath);
        setState(() {
        });
      });
    });
  }


  void getBloodGroupData() {

    _bloodGroupList = ["A+","O+","B+","AB+","A-","O-","B-","AB-"];
    for(int i=0;i<_bloodGroupList.length;i++){
      __bloodGroupListItems.add(DropdownMenuItem(
        value: _bloodGroupList[i],
        child: Text(
          _bloodGroupList[i],
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));
    }
  //  _selectedBloodGroup = __bloodGroupListItems[0].value;
  }

  void getMembershipTypeData() {

    _membershipTypeList = ["Owner","Owner Family","Tenant"];
    for(int i=0;i<_membershipTypeList.length;i++){
      __membershipTypeListItems.add(DropdownMenuItem(
        value: _membershipTypeList[i],
        child: Text(
          _membershipTypeList[i],
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));
    }
   // _selectedMembershipType = __membershipTypeListItems[0].value;
  }

  void gteLivesHereData() {

    _livesHereList = ["Yes","No"];
    for(int i=0;i<_livesHereList.length;i++){
      __livesHereListItems.add(DropdownMenuItem(
        value: _livesHereList[i],
        child: Text(
          _livesHereList[i],
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));
    }
 //   _selectedLivesHere = __livesHereListItems[0].value;
    setState(() {
    });
  }

  void changeBloodGroupDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedBloodGroup = value;
      print('_selctedItem:' + _selectedBloodGroup.toString());
    });
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

  void getProfileData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
   // String societyId = await GlobalFunctions.getSocietyId();
   // String  userId = await GlobalFunctions.getUserId();
    _progressDialog.show();
    restClient.getProfileData(societyId,userId).then((value) {
        _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _profileList = List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
        setState(() {

          _nameController.text=_profileList[0].NAME;
          _mobileController.text=_profileList[0].Phone;
          _alterMobileController.text=_profileList[0].ALTERNATE_CONTACT1;
          _selectedLivesHere=_profileList[0].LIVES_HERE.isEmpty ? null : _profileList[0].LIVES_HERE;
          _selectedBloodGroup=_profileList[0].BLOOD_GROUP.isEmpty ? null : _profileList[0].BLOOD_GROUP;
          _occupationController.text =_profileList[0].OCCUPATION;
          if(_profileList[0].DOB!='0000-00-00')
            _dobController.text= GlobalFunctions.convertDateFormat(_profileList[0].DOB, "dd-MM-yyyy");
          _selectedGender=_profileList[0].GENDER;
          _emailController.text=_profileList[0].Email;
          _addressController.text=_profileList[0].ADDRESS;
       //   _hobbiesController.text=_profileList[0].HOBBIES;
          _selectedMembershipType= _profileList[0].TYPE.isEmpty ? _membershipTypeList[0] : _profileList[0].TYPE;

          attachmentFilePath = _profileList[0].PROFILE_PHOTO;
          if(attachmentFilePath!=null && attachmentFilePath.length==0){
            attachmentFilePath=null;
          }
          print('profile pic : '+_profileList[0].PROFILE_PHOTO.toString());
          print('profile pic : '+attachmentFilePath.toString());

        });

      }
    });

  }


  void editProfileData() async{

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    // String societyId = await GlobalFunctions.getSocietyId();
     String  loggedUserId = await GlobalFunctions.getUserId();

    String attachmentName;
    String attachment;
    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }
    _progressDialog.show();
    restClient.editProfileInfo(societyId,userId,_nameController.text,_mobileController.text,_alterMobileController.text,attachment,_addressController.text,_selectedGender,_dobController.text,_selectedBloodGroup,_occupationController.text,_emailController.text,_selectedMembershipType,_selectedLivesHere).then((value) {
      _progressDialog.hide();
      if (value.status) {
        if(loggedUserId==userId) {
          GlobalVariables.userNameValueNotifer.value = _nameController.text;
          GlobalVariables.userNameValueNotifer.notifyListeners();
        }
        if(attachmentFileName!=null && attachmentFilePath!=null){
          GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
        }
        Navigator.of(context).pop('profile');
      }
      GlobalFunctions.showToast(value.message);
    });

  }

}
