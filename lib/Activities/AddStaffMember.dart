import 'dart:io';

//import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:society_gatepass/society_gatepass.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';

class BaseAddStaffMember extends StatefulWidget {
  final List<StaffCount>? allStaff;

  const BaseAddStaffMember({Key? key, this.allStaff}) : super(key: key);
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
  String _selectedStaffType = "Helper";
  ProgressDialog? _progressDialog;
  //final ContactPicker _contactPicker = ContactPicker();
  PhoneContact? _contact;
  //String mobileNumber;
  //AddStaffMemberState(this.mobileNumber);

  List<DropdownMenuItem<String>> _blockListItems = <DropdownMenuItem<String>>[];
  String? _selectedBlock;

  List<DropdownMenuItem<String>> _flatListItems = <DropdownMenuItem<String>>[];
  String? _selectedFlat;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isValidate = true;

  List<String> assignFlat = [];

  addToAssignFlat(String value) {
    setState(() {
      assignFlat.add(value);
    });
  }

  removeFromAssignFlat(String value) {
    setState(() {
      assignFlat.remove(value);
    });
  }

  Widget _buildAddedAssignFlats() => _selectedStaffType == 'Helper'
      ? Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          children: List.generate(
              assignFlat.length,
              (index) => Chip(
                  onDeleted: () => removeFromAssignFlat(assignFlat[index]),
                  label: Text(assignFlat[index]))),
        )
      : const SizedBox.shrink();

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
      child: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
          padding: EdgeInsets.all(20),
          // height: MediaQuery.of(context).size.height / 0.5,
          decoration: BoxDecoration(
              color: GlobalVariables.white,
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: InkWell(
                          //  splashColor: GlobalVariables.mediumGreen,
                          onTap: () {
                            _selectedStaffType = 'Helper';
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
                                      color: _selectedStaffType == 'Helper'
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: _selectedStaffType == 'Helper'
                                            ? GlobalVariables.primaryColor
                                            : GlobalVariables.secondaryColor
                                                .withOpacity(0.5),
                                        width: 2.0,
                                      )),
                                  child: Icon(Icons.check,
                                      color: GlobalVariables.white),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(
                                    'Helper',
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
                      InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
                          _selectedStaffType = 'Maintenance';
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
                                    color: _selectedStaffType == 'Maintenance'
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedStaffType == 'Maintenance'
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor
                                              .withOpacity(0.5),
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  'Maintenance',
                                  style: TextStyle(
                                      color: GlobalVariables.primaryColor,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        //  splashColor: GlobalVariables.mediumGreen,
                        onTap: () {
                          _selectedStaffType = 'Vendor';
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
                                    color: _selectedStaffType == 'Vendor'
                                        ? GlobalVariables.primaryColor
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedStaffType == 'Vendor'
                                          ? GlobalVariables.primaryColor
                                          : GlobalVariables.secondaryColor
                                              .withOpacity(0.5),
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  'Vendor',
                                  style: TextStyle(
                                      color: GlobalVariables.primaryColor,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                _selectedStaffType == "Helper"
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
                                    _flatListItems.clear();
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
                          IconButton(
                              onPressed: () => addToAssignFlat(
                                  '$_selectedBlock $_selectedFlat'),
                              icon: Icon(
                                Icons.add_circle,
                                color: GlobalVariables.primaryColor,
                              ))
                        ],
                      )
                    : SizedBox(),
                _buildAddedAssignFlats(),
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('name') + '*',
                  controllerCallback: _nameController,
                  /* inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.namePattern)),
                  ],*/
                  validator: (value) {
                    print('validate value : ' + value.toString());
                    if (!GlobalFunctions.isNameValid(value)) {
                      return AppLocalizations.of(context)
                          .translate('invalid_name');
                    }
                    return null;
                  },
                ),
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('contact1') + '*',
                  controllerCallback: _mobileController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  contentPadding: EdgeInsets.only(top: 14),
                  /*inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.mobilePattern)),
                  ],*/
                  validator: (value) {
                    print('validate value : ' + value.toString());
                    if (!GlobalFunctions.isMobileNumberValid(value)) {
                      return AppLocalizations.of(context)
                          .translate('invalid_mobile');
                    }
                    return null;
                  },
                  suffixIcon: AppIconButton(
                    Icons.phone_android,
                    iconColor: GlobalVariables.secondaryColor,
                    onPressed: () async {
                      PhoneContact contact =
                          await FlutterContactPicker.pickPhoneContact();
                      print('contact Name : ' + contact.fullName!);
                      print(
                          'contact Number : ' + contact.phoneNumber.toString());
                      _contact = contact;
                      setState(() {
                        if (_contact != null) {
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
                                            : GlobalVariables.secondaryColor
                                                .withOpacity(0.5),
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
                                            : GlobalVariables.secondaryColor
                                                .withOpacity(0.5),
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
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('address') + '*',
                  controllerCallback: _addressController,
                  /*inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.addressPattern)),
                  ],*/
                  validator: (value) {
                    print('validate value : ' + value.toString());
                    if (!GlobalFunctions.isAddressValid(value)) {
                      return AppLocalizations.of(context)
                          .translate('invalid_address');
                    }
                    return null;
                  },
                  contentPadding: EdgeInsets.only(top: 14),
                ),
                AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('vehicle_no'),
                  controllerCallback: _vehicleNumberController,
                  maxLength: 10,
                  /*inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(AppRegExpPattern.vehicleNumberPattern)),
                  ],*/
                  validator: (value) {
                    print('validate value : ' + value.toString());
                    if (value.toString().length > 0 && !isValidate) {
                      if (!GlobalFunctions.isVehicleNumberValid(value)) {
                        return AppLocalizations.of(context)
                            .translate('invalid_vehicle_number');
                      }
                    }
                    return null;
                  },
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
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                                Container(
                                  child: TextButton.icon(
                                      onPressed: () {
                                        openCamera(context);
                                      },
                                      icon: AppIcon(
                                        Icons.camera_alt,
                                        iconColor:
                                            GlobalVariables.secondaryColor,
                                        iconSize: 20.0,
                                      ),
                                      label: text(
                                          AppLocalizations.of(context)
                                              .translate('take_picture'),
                                          textColor:
                                              GlobalVariables.primaryColor,
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
                              decoration: attachmentIdentityProofFilePath ==
                                      null
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
                                      fontSize:
                                          GlobalVariables.textSizeSMedium),
                                ),
                                Container(
                                  child: TextButton.icon(
                                      onPressed: () {
                                        openIdentityProofCamera(context);
                                      },
                                      icon: AppIcon(
                                        Icons.camera_alt,
                                        iconColor:
                                            GlobalVariables.secondaryColor,
                                        iconSize: 20.0,
                                      ),
                                      label: text(
                                          AppLocalizations.of(context).translate(
                                                  'take_identity_proof_picture') +
                                              '*',
                                          textColor:
                                              GlobalVariables.primaryColor,
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
                        if (GlobalFunctions.textFormFieldValidate(_formKey)) {
                          verifyInfo();
                        }
                      },
                      textColor: GlobalVariables.white,
                      //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side:
                              BorderSide(color: GlobalVariables.primaryColor)),
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
      ),
    );
  }

  void verifyInfo() {
    if (_vehicleNumberController.text.length > 0 &&
        !GlobalFunctions.isVehicleNumberValid(_vehicleNumberController.text)) {
      isValidate = false;
    } else {
      isValidate = true;
    }
    if (_qualificationController.text.length > 0 &&
        !GlobalFunctions.isNameValid(_qualificationController.text)) {
      isValidate = false;
    } else {
      isValidate = true;
    }
    if (_selectedStaffType == 'Helper' && assignFlat.isEmpty) {
      GlobalFunctions.showToast('Please add flat');
      return;
    }

    if (isValidate) {
      if (_selectedRoleType != null || _selectedRoleType!.length > 0) {
        if (attachmentIdentityProofFilePath != null ||
            attachmentFilePath != null) {
          addMember();
        } else {
          GlobalFunctions.showToast("Please add required documents");
        }
      } else {
        GlobalFunctions.showToast('Please Select Role');
      }
    } else {
      setState(() {});
      return;
    }
  }

  Future<void> addMember() async {
    String societyId = await GlobalFunctions.getSocietyId();

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

    final dio = Dio();
    final RestClient restClient =
        RestClient(dio, baseUrl: GlobalVariables.BaseURL);
    restClient
        .addStaffMember(
            userId,
            societyId,
            _nameController.text,
            _mobileController.text,
            _vehicleNumberController.text,
            assignFlat.join(','),
            _selectedGender,
            _dobController.text,
            _selectedRoleType!,
            _qualificationController.text,
            _addressController.text,
            attachment,
            attachmentIdentityProof,
            _selectedStaffType)
        .then((value) async {
      _progressDialog!.dismiss();
      if (value.status ?? false) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: displayPassCode(
                      value.passCode ?? '',
                    ),
                  );
                }));
      }
      GlobalFunctions.showToast(value.message!);
    });
  }

  void openFile(BuildContext context) {
    GlobalFunctions.getFilePath(context, AppFileExtensions.imageFileExtensions)
        .then((value) {
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
    GlobalFunctions.getFilePath(context, AppFileExtensions.imageFileExtensions)
        .then((value) {
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
    _roleTypeList.clear();
    __roleTypeListItems.clear();
    List<StaffCount> staff = widget.allStaff ?? [];
    if (staffType == 'Helper') {
      _roleTypeList = staff.where((e) => e.type == 'Helper').toList();
    } else if (staffType == 'Maintenance') {
      _roleTypeList = staff.where((e) => e.type == 'Maintenance').toList();
    } else if (staffType == 'Vendor') {
      _roleTypeList = staff.where((e) => e.type == 'Vendor').toList();
    }
    for (int i = 0; i < _roleTypeList.length; i++) {
      __roleTypeListItems.add(DropdownMenuItem(
        value: _roleTypeList[i].role,
        child: Text(
          _roleTypeList[i].role!,
          style: TextStyle(color: GlobalVariables.primaryColor),
        ),
      ));
    }
    setState(() {});
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

  displayPassCode(String passCode) {
    String line =
        "Please tell this number at security gate hassle free entry at society";
    return Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: AppIconButton(
                  Icons.close,
                  iconColor: GlobalVariables.primaryColor,
                  onPressed: () {
                    Provider.of<UserManagementResponse>(context, listen: false)
                        .getUserManagementDashboard();
                    removeCacheImages();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Text(
                'Passcode',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                passCode,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                line,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              AppButton(
                  textContent: 'Okay',
                  onPressed: () {
                    Provider.of<UserManagementResponse>(context, listen: false)
                        .getUserManagementDashboard();
                    removeCacheImages();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ));
  }
}
