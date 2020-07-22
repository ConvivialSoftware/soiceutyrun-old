import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseAddStaffMember extends StatefulWidget {

  //String memberType;
  //BaseAddStaffMember(this.memberType);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddStaffMemberState();
  }
}

class AddStaffMemberState extends State<BaseAddStaffMember> {

  //String memberType;


  String attachmentFilePath;
  String attachmentIdentityProofFilePath;


  String attachmentFileName;
  String attachmentIdentityProofFileName;


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

  List<String> _membershipTypeList = new List<String>();
  List<DropdownMenuItem<String>> __membershipTypeListItems = new List<DropdownMenuItem<String>>();
  String _selectedMembershipType;


 // List<String> _livesHereList = new List<String>();
  //List<DropdownMenuItem<String>> __livesHereListItems = new List<DropdownMenuItem<String>>();
  //String _selectedLivesHere;

 // String _selectedOccupation="Software Engg.";
  String _selectedGender="Male";
  ProgressDialog _progressDialog;


  @override
  void initState() {
    super.initState();
    getRoleTypeData();
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
            AppLocalizations.of(context).translate('add_staff_member'),
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
                getAddStaffMemberLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAddStaffMemberLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
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
                      hintText: AppLocalizations.of(context).translate('name'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
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
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('mobile_no'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
                      border: InputBorder.none
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
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: __roleTypeListItems,
                    value: _selectedRoleType,
                    onChanged: changeBRoleTypeDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('select_role'),
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 12),
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
                  controller: _qualificationController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('qualification'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
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
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _vehicleNumberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('vehicle_no'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
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

                                  GlobalFunctions.getSelectedDate(context).then((value){
                                    _dobController.text = value.day.toString()+"/"+value.month.toString()+"/"+value.year.toString();
                                  });

                                },
                                icon: Icon(Icons.date_range,color: GlobalVariables.mediumGreen,))
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
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('address'),
                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
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
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )
                ),
                child: TextField(
                  controller: _noteController,
                  keyboardType: TextInputType.text,
                  maxLines: 99,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('note_for_moderate'),
                    hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 16),
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
                              color: GlobalVariables.mediumGreen,
                              borderRadius: BorderRadius.circular(25),

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: FileImage(File(attachmentFilePath)),
                                    fit: BoxFit.cover
                                )
                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: GlobalVariables.mediumGreen,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: FlatButton.icon(onPressed: (){

                              openFile(context);

                            }, icon: Icon(Icons.camera_alt,color: GlobalVariables.white,), label:Text(AppLocalizations.of(context).translate('attach_photo'),style: TextStyle(
                                color: GlobalVariables.white
                            ),)),
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
                              color: GlobalVariables.mediumGreen,
                              borderRadius: BorderRadius.circular(25),

                            ) : BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: FileImage(File(attachmentIdentityProofFilePath)),
                                    fit: BoxFit.cover
                                )
                            ),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: GlobalVariables.mediumGreen,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: FlatButton.icon(onPressed: (){

                              openIdentityProofFile(context);

                            }, icon: Icon(Icons.camera_alt,color: GlobalVariables.white,), label:Text(AppLocalizations.of(context).translate('identity_proof'),style: TextStyle(
                                color: GlobalVariables.white
                            ),)),
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

      if(_dobController.text.length>0){

        if(_mobileController.text.length>0){

            if(_selectedRoleType!=null || _selectedRoleType.length>0){

              if(_addressController.text!=null && _addressController.text.length>0) {
                addMember(
                );
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
      attachment = GlobalFunctions.convertFileToString(attachmentFilePath);
    }


    if(attachmentIdentityProofFileName!=null && attachmentIdentityProofFilePath!=null){
      attachmentIdentityProofName =  attachmentIdentityProofFileName;
      attachmentIdentityProof = GlobalFunctions.convertFileToString(attachmentIdentityProofFilePath);
    }

   //print('attachment lengtth : '+attachment.length.toString());

    _progressDialog.show();
   restClient.addStaffMember(societyId, block, flat, _nameController.text, _selectedGender, _dobController.text, _mobileController.text
       , _qualificationController.text , _addressController.text, _noteController.text, userId, _selectedRoleType, attachment, attachmentIdentityProof, _vehicleNumberController.text).then((value) {

         _progressDialog.hide();
         if(value.status){
           Navigator.of(context).pop();
         }
         GlobalFunctions.showToast(value.message);
   });

  }

  void openFile(BuildContext context) {

    GlobalFunctions.getFilePath(context).then((value) {
      attachmentFilePath=value;

      print('file Path : '+attachmentFilePath.toString());
/*  /storage/emulated/0/Pictures/Screenshots/Screenshot_20200515-105610.jpg   */

      attachmentFileName = attachmentFilePath.substring(attachmentFilePath.lastIndexOf('/')+1,attachmentFilePath.length);
      print('file Name : '+attachmentFileName.toString());

      setState(() {
      });

// https://societyrun.com//Uploads/278808_2019-08-16_12:45:09.jpg

    });

  }


   void openIdentityProofFile(BuildContext context) {

    GlobalFunctions.getFilePath(context).then((value) {
      attachmentIdentityProofFilePath=value;

      print('file Path : '+attachmentIdentityProofFilePath.toString());
/*  /storage/emulated/0/Pictures/Screenshots/Screenshot_20200515-105610.jpg   */

      attachmentIdentityProofFileName = attachmentIdentityProofFilePath.substring(attachmentIdentityProofFilePath.lastIndexOf('/')+1,attachmentIdentityProofFilePath.length);
      print('file Name : '+attachmentIdentityProofFileName.toString());

      setState(() {
      });

// https://societyrun.com//Uploads/278808_2019-08-16_12:45:09.jpg

    });

  }


  void getRoleTypeData() {

    _roleTypeList = ["Driver","Maid","Cook","Tutor"];
    for(int i=0;i<_roleTypeList.length;i++){
      __roleTypeListItems.add(DropdownMenuItem(
        value: _roleTypeList[i],
        child: Text(
          _roleTypeList[i],
          style: TextStyle(color: GlobalVariables.green),
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
