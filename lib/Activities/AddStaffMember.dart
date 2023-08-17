import 'dart:io';

//import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAddStaffMember extends StatefulWidget {
  //String mobileNumber;
  // BaseAddStaffMember(this.mobileNumber);

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

  String? attachmentFilePath;
  String? attachmentIdentityProofFilePath;
  String? attachmentCompressFilePath;

  String? attachmentFileName;
  String? attachmentIdentityProofFileName;
  String? attachmentIdentityProofCompressFilePath;

  // AddStaffMemberState(this.memberType);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _vehicleNumberController = TextEditingController();
  //TextEditingController _noteController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<StaffCount> _roleTypeList = <StaffCount>[];
  List<DropdownMenuItem<String>> __roleTypeListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedRoleType;

  //String _selectedMembershipType;

  // List<String> _livesHereList = new List<String>();
  //List<DropdownMenuItem<String>> __livesHereListItems = new List<DropdownMenuItem<String>>();
  //String _selectedLivesHere;

  // String _selectedOccupation="Software Engg.";
  String _selectedGender = "Male";
  String _selectedStaffType = "Staff";
  ProgressDialog? _progressDialog;
  //final ContactPicker _contactPicker = ContactPicker();
  PhoneContact? _contact;
  //String mobileNumber;
  //AddStaffMemberState(this.mobileNumber);

  List<DropdownMenuItem<String>> _blockListItems = <DropdownMenuItem<String>>[];
  String? _selectedBlock;

  List<DropdownMenuItem<String>> _flatListItems = <DropdownMenuItem<String>>[];
  String? _selectedFlat;

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getBlockFlatData();
  
    getRoleTypeData(_selectedStaffType);
    //_dobController.text = DateTime.now().toLocal().day.toString()+"/"+DateTime.now().toLocal().month.toString()+"/"+DateTime.now().toLocal().year.toString();
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    //_mobileController.text = mobileNumber;
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('add_staff_member'),
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
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
                          _selectedStaffType =
                              AppLocalizations.of(context).translate('staff');
                          getRoleTypeData(_selectedStaffType);
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: _selectedStaffType ==
                                            AppLocalizations.of(context)
                                                .translate('staff')
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedStaffType ==
                                              AppLocalizations.of(context)
                                                  .translate('staff')
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('staff'),
                                  style: TextStyle(
                                      color: GlobalVariables.primaryColor,
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
                          _selectedStaffType = AppLocalizations.of(context)
                              .translate('maintenance_staff');
                          getRoleTypeData(_selectedStaffType);
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: _selectedStaffType ==
                                            AppLocalizations.of(context)
                                                .translate('maintenance_staff')
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedStaffType ==
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'maintenance_staff')
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('maintenance_staff'),
                                  style: TextStyle(
                                      color: GlobalVariables.primaryColor,
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
              _selectedStaffType == "Staff"
                  ? Row(
                      children: [
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
                                  color: GlobalVariables.lightGray,
                                  width: 2.0,
                                )),
                            child: ButtonTheme(
                              child: DropdownButtonFormField(
                                items: _blockListItems,
                                value: _selectedBlock,
                                onChanged: (value) {
                                  _selectedBlock = value as String?;
                                  _selectedFlat = null;
                                  getBlockFlatData();
                                },
                                isExpanded: true,
                                icon: AppIcon(
                                  Icons.keyboard_arrow_down,
                                  iconColor: GlobalVariables.secondaryColor,
                                ),
                                decoration: InputDecoration(
                                    //filled: true,
                                    //fillColor: Hexcolor('#ecedec'),
                                    labelText: AppLocalizations.of(context)
                                        .translate('block'),
                                    labelStyle: TextStyle(
                                        color: GlobalVariables.lightGray,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent))
                                    // border: new CustomBorderTextFieldSkin().getSkin(),
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
                                  color: GlobalVariables.lightGray,
                                  width: 2.0,
                                )),
                            child: ButtonTheme(
                              child: DropdownButtonFormField(
                                items: _flatListItems,
                                value: _selectedFlat,
                                onChanged: (value) {
                                  _selectedFlat = value as String?;
                                  setState(() {});
                                },
                                isExpanded: true,
                                icon: AppIcon(
                                  Icons.keyboard_arrow_down,
                                  iconColor: GlobalVariables.secondaryColor,
                                ),
                                decoration: InputDecoration(
                                    //filled: true,
                                    //fillColor: Hexcolor('#ecedec'),
                                    labelText: AppLocalizations.of(context)
                                        .translate('flat'),
                                    labelStyle: TextStyle(
                                        color: GlobalVariables.lightGray,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent))
                                    // border: new CustomBorderTextFieldSkin().getSkin(),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('name'),
                  controllerCallback: _nameController),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('contact1') + '*',
                controllerCallback: _mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                contentPadding: EdgeInsets.only(top: 14),
                suffixIcon: AppIconButton(
                  Icons.phone_android,
                  iconColor: GlobalVariables.secondaryColor,
                  onPressed: () async {
                    PhoneContact contact =
                        await FlutterContactPicker.pickPhoneContact();
                    print('contact Name : ' + contact.fullName!);
                    print('contact Number : ' + contact.phoneNumber.toString());
                    _contact = contact;
                    setState(() {
                      if (_contact != null) {
                        //  _nameController.text = _contact.fullName;
                        /*String phoneNumber = _contact!.phoneNumber
                            .toString()
                            .substring(
                            0,
                            _contact!.phoneNumber
                                .toString()
                                .indexOf('(') -
                                1);*/
                        String phoneNumber = contact.phoneNumber!.number!
                            .trim()
                            .toString()
                            .replaceAll(" ", "");
                        _mobileController.text =
                            GlobalFunctions.getMobileFormatNumber(
                                phoneNumber.toString());
                        // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                      }
                    });
                  },
                ),
              ),
              _selectedStaffType ==
                      AppLocalizations.of(context)
                          .translate('maintenance_staff')
                  ? AppTextField(
                      textHintContent:
                          AppLocalizations.of(context).translate('email') + '*',
                      controllerCallback: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      contentPadding: EdgeInsets.only(top: 14),
                      suffixIcon: AppIconButton(
                        Icons.email,
                        iconColor: GlobalVariables.secondaryColor,
                      ),
                    )
                  : SizedBox(),
              Container(
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
                  child: DropdownButton(
                    items: __roleTypeListItems,
                    value: _selectedRoleType,
                    onChanged: changeBRoleTypeDropDownItem,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.secondaryColor,
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
                                    color: _selectedGender == "Male"
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender == "Male"
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
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
                                      color: GlobalVariables.primaryColor,
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
                          _selectedGender = "Female";
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
                                    color: _selectedGender == "Female"
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedGender == "Female"
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor,
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
                                      color: GlobalVariables.primaryColor,
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
                height: 100,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('address') + '*',
                  controllerCallback: _addressController,
                  maxLines: 99,
                  contentPadding: EdgeInsets.only(top: 14),
                ),
              ),
              AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('qualification'),
                  controllerCallback: _qualificationController),
              AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('vehicle_no'),
                  controllerCallback: _vehicleNumberController),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('date_of_birth'),
                controllerCallback: _dobController,
                readOnly: true,
                contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                suffixIcon: AppIconButton(
                  Icons.date_range,
                  iconColor: GlobalVariables.secondaryColor,
                  onPressed: () {
                    GlobalFunctions.getSelectedDateForDOB(context)
                        .then((value) {
                      _dobController.text =
                          value.day.toString().padLeft(2, '0') +
                              "-" +
                              value.month.toString().padLeft(2, '0') +
                              "-" +
                              value.year.toString();
                    });
                  },
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
                                    color: GlobalVariables.secondaryColor,
                                    borderRadius: BorderRadius.circular(25),
                                    //   border: Border.all(color: GlobalVariables.green,width: 2.0)
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: FileImage(
                                            File(attachmentFilePath!)),
                                        fit: BoxFit.cover),
                                    border: Border.all(
                                        color: GlobalVariables.primaryColor,
                                        width: 2.0)),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: TextButton.icon(
                                  onPressed: () {
                                     openFile(context);
                                  },
                                  icon: AppIcon(
                                    Icons.attach_file,
                                    iconColor: GlobalVariables.secondaryColor,
                                    iconSize: 20.0,
                                  ),
                                  label: text(
                                      AppLocalizations.of(context)
                                          .translate('attach_photo'),
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: text('OR',
                                    textColor: GlobalVariables.lightGray,
                                    fontSize: GlobalVariables.textSizeSMedium),
                              ),
                              Container(
                                child: TextButton.icon(
                                    onPressed: () {
                                       openCamera(context);
                                    },
                                    icon: AppIcon(
                                      Icons.camera_alt,
                                      iconColor: GlobalVariables.secondaryColor,
                                      iconSize: 20.0,
                                    ),
                                    label: text(
                                        AppLocalizations.of(context)
                                            .translate('take_picture'),
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium)),
                              ),
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
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            decoration: attachmentIdentityProofFilePath == null
                                ? BoxDecoration(
                                    color: GlobalVariables.secondaryColor,
                                    borderRadius: BorderRadius.circular(25),
                                    //   border: Border.all(color: GlobalVariables.green,width: 2.0)
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: FileImage(File(
                                            attachmentIdentityProofFilePath!)),
                                        fit: BoxFit.cover),
                                    border: Border.all(
                                        color: GlobalVariables.primaryColor,
                                        width: 2.0)),
                            //child: attachmentFilePath==null?Container() : ClipRRect(child: Image.file(File(attachmentFilePath))),
                          ),
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: TextButton.icon(
                                  onPressed: () {
                                   openIdentityProofFile(context);
                                  },
                                  icon: AppIcon(
                                    Icons.attach_file,
                                    iconColor: GlobalVariables.secondaryColor,
                                    iconSize: 20.0,
                                  ),
                                  label: text(
                                      AppLocalizations.of(context).translate(
                                              'attach_identity_proof') +
                                          '*',
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                              ),
                              Container(
                                //alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: text('OR',
                                    textColor: GlobalVariables.lightGray,
                                    fontSize: GlobalVariables.textSizeSMedium),
                              ),
                              Container(
                                child: TextButton.icon(
                                    onPressed: () {
                                        openIdentityProofCamera(context);
                                    },
                                    icon: AppIcon(
                                      Icons.camera_alt,
                                      iconColor: GlobalVariables.secondaryColor,
                                      iconSize: 20.0,
                                    ),
                                    label: text(
                                        AppLocalizations.of(context).translate(
                                                'take_identity_proof_picture') +
                                            '*',
                                        textColor: GlobalVariables.primaryColor,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium)),
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
                  child: MaterialButton(
                    color: GlobalVariables.primaryColor,
                    onPressed: () {
                      verifyInfo();
                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: GlobalVariables.primaryColor)),
                    child: Text(
                      AppLocalizations.of(context).translate('submit'),
                      style:
                          TextStyle(fontSize: GlobalVariables.textSizeMedium),
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
    if (_nameController.text.length > 0) {
      if (_mobileController.text.length > 0 &&
          _mobileController.text.length == 10) {
        if (_selectedRoleType != null || _selectedRoleType!.length > 0) {
          if (_addressController.text.length > 0) {
            if (attachmentIdentityProofFileName != null &&
                attachmentIdentityProofFilePath != null) {
              addMember();
            } else {
              GlobalFunctions.showToast("Please Select Identity Proof");
            }
          } else {
            GlobalFunctions.showToast("Please Enter Address");
          }
        } else {
          GlobalFunctions.showToast('Please Select Role');
        }
      } else {
        GlobalFunctions.showToast('Please Enter Valid Mobile Number');
      }
    } else {
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

    String? attachmentName;
    String? attachmentIdentityProofName;
    String? attachment;
    String? attachmentIdentityProof;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath!);
    }

    if (attachmentIdentityProofFileName != null &&
        attachmentIdentityProofFilePath != null) {
      attachmentIdentityProofName = attachmentIdentityProofFileName;
      attachmentIdentityProof = GlobalFunctions.convertFileToString(
          attachmentIdentityProofCompressFilePath!);
    }

    //print('attachment lengtth : '+attachment.length.toString());

    _progressDialog!.show();
    if (_selectedStaffType == 'Staff') {
      restClient
          .addStaffMember(
              userId,
              societyId,
              _nameController.text,
              _mobileController.text,
              _vehicleNumberController.text,
              block + ' ' + flat,
              _selectedGender,
              _dobController.text,
              _selectedRoleType!,
              _qualificationController.text,
              _addressController.text,
              attachment,
              attachmentIdentityProof)
          .then((value) async {
        _progressDialog!.dismiss();
        if (value.status!) {
          Provider.of<UserManagementResponse>(context, listen: false)
              .getUserManagementDashboard();
          removeCacheImages();
          Navigator.of(context).pop();
        }
        GlobalFunctions.showToast(value.message!);
      });
    } else {
      restClient
          .addMaintenanceStaffMember(
              userId,
              societyId,
              _nameController.text,
              _mobileController.text,
              _emailController.text,
              _vehicleNumberController.text,
              _selectedGender,
              _dobController.text,
              _selectedRoleType!,
              _qualificationController.text,
              _addressController.text,
              attachment,
              attachmentIdentityProof)
          .then((value) {
        _progressDialog!.dismiss();
        if (value.status!) {
          Provider.of<UserManagementResponse>(context, listen: false)
              .getUserManagementDashboard();
          removeCacheImages();
          Navigator.of(context).pop();
        }
        GlobalFunctions.showToast(value.message!);
      });
    }
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
    attachmentFileName = attachmentFilePath!.substring(
        attachmentFilePath!.lastIndexOf('/') + 1, attachmentFilePath!.length);
    print('file Name : ' + attachmentFileName!.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
              attachmentFilePath!, value.toString() + '/' + attachmentFileName!)
          .then((value) {
        attachmentCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentCompressFilePath!);
        setState(() {});
      });
    });
  }

  void openIdentityProofFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentIdentityProofFilePath = value;
      getCompressIdentityProofFilePath();
    });
  }

  void openIdentityProofCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      attachmentIdentityProofFilePath = value.path;
      getCompressIdentityProofFilePath();
    });
  }

  void getCompressIdentityProofFilePath() {
    attachmentIdentityProofFileName = attachmentIdentityProofFilePath!
        .substring(attachmentIdentityProofFilePath!.lastIndexOf('/') + 1,
            attachmentIdentityProofFilePath!.length);
    print('file Name : ' + attachmentIdentityProofFileName.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
              attachmentIdentityProofFilePath!,
              value.toString() + '/' + attachmentIdentityProofFileName!)
          .then((value) {
        attachmentIdentityProofCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentIdentityProofCompressFilePath!);
        setState(() {});
      });
    });
  }

  Future<void> getRoleTypeData(String staffType) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog!.show();
    restClient.staffCount(societyId, staffType).then((value) {
      _progressDialog!.dismiss();
      List<dynamic> _list = value.Role!;
      _roleTypeList = <StaffCount>[];
      __roleTypeListItems = <DropdownMenuItem<String>>[];
      _roleTypeList =
          List<StaffCount>.from(_list.map((i) => StaffCount.fromJson(i)));
      for (int i = 0; i < _roleTypeList.length; i++) {
        __roleTypeListItems.add(DropdownMenuItem(
          value: _roleTypeList[i].ROLE,
          child: Text(
            _roleTypeList[i].ROLE!,
            style: TextStyle(color: GlobalVariables.primaryColor),
          ),
        ));
      }
      setState(() {});
    });
  }

  void getBlockFlatData() {
    print('_selectedBlock : ' + _selectedBlock.toString());
    Provider.of<UserManagementResponse>(context, listen: false)
        .getBlock()
        .then((value) {
      setBlockData(value);
      Provider.of<UserManagementResponse>(context, listen: false)
          .getFlat(_selectedBlock!)
          .then((value) {
        setFlatData(value);
      });
    });
  }

  void setBlockData(List<Block> _blockList) {
    _blockListItems = <DropdownMenuItem<String>>[];
    for (int i = 0; i < _blockList.length; i++) {
      _blockListItems.add(DropdownMenuItem(
        value: _blockList[i].BLOCK,
        child: text(
          _blockList[i].BLOCK,
          textColor: GlobalVariables.black,
        ),
      ));
    }

    if (_selectedBlock == null) {
      _selectedBlock = _blockListItems[0].value;
    }
    //setState(() {});
  }

  void setFlatData(List<Flat> _flatList) {
    _flatListItems = <DropdownMenuItem<String>>[];
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
    _selectedFlat = _flatListItems[0].value;
    setState(() {});
  }

  void changeBRoleTypeDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedRoleType = value;
      print('_selctedItem:' + _selectedRoleType.toString());
    });
  }

  Future<void> removeCacheImages() async {
    if (attachmentFileName != null && attachmentFilePath != null) {
      await GlobalFunctions.removeFileFromDirectory(attachmentFilePath!);
      await GlobalFunctions.removeFileFromDirectory(
          attachmentCompressFilePath!);
    }
    if (attachmentIdentityProofFileName != null &&
        attachmentIdentityProofFilePath != null) {
      await GlobalFunctions.removeFileFromDirectory(
          attachmentIdentityProofFilePath!);
      await GlobalFunctions.removeFileFromDirectory(
          attachmentIdentityProofCompressFilePath!);
    }
  }
}
