import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

import 'base_stateful.dart';

class BaseEditStaffMember extends StatefulWidget {
  Staff staff;
  BaseEditStaffMember(this.staff);


  //String memberType;
  //BaseAddStaffMember(this.memberType);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditStaffMemberState(staff);
  }
}

class EditStaffMemberState extends BaseStatefulState<BaseEditStaffMember> {

  //String memberType;


  String attachmentFilePath;
  String attachmentIdentityProofFilePath;
  String attachmentCompressFilePath;


  String attachmentFileName;
  String attachmentIdentityProofFileName;
  String attachmentIdentityProofCompressFilePath;


 // AddStaffMemberState(this.memberType);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _vehicleNumberController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<String> _roleTypeList = new List<String>();
  List<DropdownMenuItem<String>> __roleTypeListItems = new List<DropdownMenuItem<String>>();
  String _selectedRoleType;

  String _selectedMembershipType;


 // List<String> _livesHereList = new List<String>();
  //List<DropdownMenuItem<String>> __livesHereListItems = new List<DropdownMenuItem<String>>();
  //String _selectedLivesHere;

 // String _selectedOccupation="Software Engg.";
  String _selectedGender="Male";
  ProgressDialog _progressDialog;
  bool isStoragePermission=false;

  Staff staff;
  EditStaffMemberState(this.staff);


  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission=value;
    });
    getRoleTypeData();

    /*societyId, block, flat, _staffList[0].STAFF_NAME,  _staffList[0].GENDER,  _staffList[0].DOB, _mobileController.text
        ,  _staffList[0].QUALIFICATION ,  _staffList[0].ADDRESS,  _staffList[0].NOTES, userId,
         _staffList[0].ROLE,  _staffList[0].IMAGE,  _staffList[0].Attachment,  _staffList[0].VEHICLE_NO*/
    _nameController.text=staff.STAFF_NAME;
    _selectedGender= staff.GENDER ==null ? 'Male' : staff.GENDER;
    print('gender : '+staff.GENDER.toString());
    _dobController.text = staff.DOB!=null ? GlobalFunctions.convertDateFormat(staff.DOB, "dd/MM/yyyy"):'';
    _mobileController.text=staff.CONTACT!=null ? staff.CONTACT : '';
    _qualificationController.text=staff.QUALIFICATION!=null ?staff.QUALIFICATION : '';
    _addressController.text=staff.ADDRESS!=null ? staff.ADDRESS : '';
    _noteController.text=staff.NOTES!=null ? staff.NOTES : '';
    if(_selectedRoleType!=null)
      _selectedRoleType = staff.ROLE;
    else
      _selectedRoleType =_roleTypeList[0];
    attachmentFilePath = staff.IMAGE;
    attachmentIdentityProofFilePath = staff.Attachment;
    _vehicleNumberController.text=staff.VEHICLE_NO!=null ? staff.VEHICLE_NO : '';
    //_dobController.text = DateTime.now().toLocal().day.toString()+"/"+DateTime.now().toLocal().month.toString()+"/"+DateTime.now().toLocal().year.toString();
  }

  @override
  Widget build(BuildContext context) {

    //GlobalFunctions.showToast(memberType.toString());
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
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
            AppLocalizations.of(context).translate('edit_staff_member'),
            textColor: GlobalVariables.white,
          ),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: double.infinity,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                    context, 200.0),
                getEditStaffMemberLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getEditStaffMemberLayout() {
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
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('name'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none
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
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('mobile_no'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none,
                    counterText: ''
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: __roleTypeListItems,
                    value: _selectedRoleType,
                    onChanged: changeBRoleTypeDropDownItem,
                    isExpanded: true,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.secondaryColor,
                    ),
                    underline: SizedBox(),
                    hint: text(
                      AppLocalizations.of(context).translate('select_role'),
                      textColor: GlobalVariables.lightGray, fontSize: GlobalVariables.textSizeSmall,
                    ),
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
                                    color:   _selectedGender== "Male" ? GlobalVariables.primaryColor : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender== "Male" ? GlobalVariables.primaryColor : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: text(
                                  AppLocalizations.of(context)
                                      .translate('male'),
                                 textColor: GlobalVariables.primaryColor,
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
                                    color: _selectedGender== "Female" ? GlobalVariables.primaryColor : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender== "Female" ? GlobalVariables.primaryColor : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: AppIcon(Icons.check,
                                    iconColor: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: text(
                                  AppLocalizations.of(context)
                                      .translate('female'),
                                  textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeSmall,
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
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _qualificationController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('qualification'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none
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
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _vehicleNumberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('vehicle_no'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none
                  ),
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
                            color: GlobalVariables.secondaryColor,
                            width: 3.0,
                          )
                      ),
                      child: TextField(
                        controller: _dobController,
                        readOnly: true,
                        style: TextStyle(
                            color: GlobalVariables.primaryColor
                        ),
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate('date_of_birth'),
                            hintStyle: TextStyle(color: GlobalVariables.veryLightGray ,fontSize: GlobalVariables.textSizeMedium),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                onPressed: (){

                                  GlobalFunctions.getSelectedDateForDOB(context).then((value){
                                    _dobController.text = value.day.toString()+"/"+value.month.toString()+"/"+value.year.toString();
                                  });

                                },
                                icon: Icon(Icons.date_range,color: GlobalVariables.secondaryColor,))
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
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('address'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                      border: InputBorder.none
                  ),
                ),
              ),
              Container(
                height: 100,
               padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.secondaryColor,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _noteController,
                  keyboardType: TextInputType.text,
                  maxLines: 99,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('note_for_moderate'),
                    hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: GlobalVariables.textSizeMedium),
                    border: InputBorder.none
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
                              color: GlobalVariables.secondaryColor,
                              borderRadius: BorderRadius.circular(25),

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: attachmentFilePath.contains("http") ? NetworkImage(attachmentFilePath) : FileImage(File(attachmentFilePath)),
                                    fit: BoxFit.cover,
                                ),
                                border: Border.all(color: GlobalVariables.primaryColor,width: 2.0)
                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    color: GlobalVariables.secondaryColor,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: FlatButton.icon(onPressed: (){

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

                                }, icon: Icon(Icons.camera_alt,color: GlobalVariables.white,),
                                    label:Text(AppLocalizations.of(context).translate('attach_photo'),style: TextStyle(
                                    color: GlobalVariables.white
                                ),)),
                              ),
                              /*Container(
                                margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
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
                              ),*/
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
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
                            decoration: attachmentIdentityProofFilePath==null ? BoxDecoration(
                              color: GlobalVariables.secondaryColor,
                              borderRadius: BorderRadius.circular(25),

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image:attachmentIdentityProofFilePath.contains("http") ? NetworkImage(attachmentIdentityProofFilePath) :  FileImage(File(attachmentIdentityProofFilePath)),
                                    fit: BoxFit.cover
                                ),
                                border: Border.all(color: GlobalVariables.primaryColor,width: 2.0)
                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: GlobalVariables.secondaryColor,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: FlatButton.icon(onPressed: (){

                              openIdentityProofFile(context);

                            }, icon: AppIcon(Icons.camera_alt,iconColor: GlobalVariables.white,), label:text(
                              AppLocalizations.of(context).translate('identity_proof'),textColor: GlobalVariables.white
                            ,)),
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
                    color: GlobalVariables.primaryColor,
                    onPressed: () {

                      verifyInfo();

                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.primaryColor)
                    ),
                    child: text(
                      AppLocalizations.of(context)
                          .translate('submit'),
                          fontSize: GlobalVariables.textSizeMedium,
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

      if(_dobController.text.length>0){

        if(_mobileController.text.length>0){

            if(_selectedRoleType!=null || _selectedRoleType.length>0){

              if(_addressController.text!=null && _addressController.text.length>0) {
                addMember();
              }else{
                GlobalFunctions.showToast("Please Enter Address");
              }

            }else{
              GlobalFunctions.showToast('Please Select Role');
            }

        }else{
          GlobalFunctions.showToast('Please Enter Mobile Number');
        }
      }else{
        GlobalFunctions.showToast('Please Select Date of Birth');
      }
    }else{
      GlobalFunctions.showToast('Please Enter Name');
    }

  }

  Future<void> addMember() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();

    String attachmentName;
    String attachmentIdentityProofName;
    String attachment;
    String attachmentIdentityProof;

    if(attachmentFileName!=null && attachmentFilePath!=null){
      attachmentName = attachmentFileName;
      attachment = GlobalFunctions.convertFileToString(attachmentCompressFilePath);
    }


    if(attachmentIdentityProofFileName!=null && attachmentIdentityProofFilePath!=null){
      attachmentIdentityProofName =  attachmentIdentityProofFileName;
      attachmentIdentityProof = GlobalFunctions.convertFileToString(attachmentIdentityProofCompressFilePath);
    }

   //print('attachment lengtth : '+attachment.length.toString());

    _progressDialog.show();
   restClient.addStaffMember(userId,societyId,_nameController.text,
       _mobileController.text,_vehicleNumberController.text,block+' '+flat,
       _selectedGender,_dobController.text,_selectedRoleType,
       _qualificationController.text,_addressController.text,attachment,attachmentIdentityProof).then((value) {

         _progressDialog.hide();
         if(value.status){
           if(attachmentFileName!=null && attachmentFilePath!=null){
             //GlobalFunctions.removeFileFromDirectory(attachmentCompressFilePath);
             GlobalFunctions.getTemporaryDirectoryPath()
                 .then((value) {
               GlobalFunctions.removeAllFilesFromDirectory(
                   value);
             });
           }
           if(attachmentIdentityProofFileName!=null && attachmentIdentityProofFilePath!=null){
             //GlobalFunctions.removeFileFromDirectory(attachmentIdentityProofCompressFilePath);
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

  void openIdentityProofFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentIdentityProofFilePath=value;
      getCompressIdentityProofFilePath();
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

  void getCompressIdentityProofFilePath(){
    attachmentIdentityProofFileName = attachmentIdentityProofFilePath.substring(attachmentIdentityProofFilePath.lastIndexOf('/')+1,attachmentIdentityProofFilePath.length);
    print('file Name : '+attachmentIdentityProofFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : '+value.toString());
      GlobalFunctions.getFilePathOfCompressImage(attachmentIdentityProofFilePath, value.toString()+'/'+attachmentIdentityProofFileName).then((value) {
        attachmentIdentityProofCompressFilePath = value.toString();
        print('Cache file path : '+attachmentIdentityProofCompressFilePath);
        setState(() {
        });
      });
    });
  }

  void getRoleTypeData() {

    _roleTypeList = ["Driver","Maid","Cook","Tutor"];
    for(int i=0;i<_roleTypeList.length;i++){
      __roleTypeListItems.add(DropdownMenuItem(
        value: _roleTypeList[i],
        child: text(
          _roleTypeList[i],
          textColor: GlobalVariables.primaryColor,
        ),
      ));
    }
   // _selectedMembershipType = __membershipTypeListItems[0].value;
  }

 

  void changeBRoleTypeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedRoleType = value;
      print('_selctedItem:' + _selectedRoleType.toString());
    });
  }

  void changeMembershipTypeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedMembershipType = value;
      print('_selctedItem:' + _selectedMembershipType.toString());
    });
  }
/*

  void changeLivesHereDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedLivesHere = value;
      print('_selctedItem:' + _selectedLivesHere.toString());
    });
  }
*/



}
