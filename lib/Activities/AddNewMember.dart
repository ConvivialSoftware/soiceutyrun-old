import 'dart:io';

//import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAddNewMember extends StatefulWidget {
  String memberType;

  BaseAddNewMember(this.memberType);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddNewMemberState();
  }
}

class AddNewMemberState extends State<BaseAddNewMember> {
  // String memberType;

  String? attachmentFilePath;
  String? attachmentFileName;
  String? attachmentCompressFilePath;

  /* String? attachmentPoliceVerificationFilePath;
  String? attachmentPoliceVerificationFileName;
  String? attachmentPoliceVerificationCompressFilePath;

  String? attachmentIdentityProofFilePath;
  String? attachmentIdentityProofFileName;
  String? attachmentIdentityProofCompressFilePath;
*/
  //AddNewMemberState(this.memberType);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _alterMobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();

  //TextEditingController _hobbiesController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<String> _bloodGroupList = <String>[];
  List<DropdownMenuItem<String>> __bloodGroupListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedBloodGroup;

  List<String> _membershipTypeList = <String>[];
  List<DropdownMenuItem<String>> __membershipTypeListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedMembershipType;

  List<String> _livesHereList = <String>[];
  List<DropdownMenuItem<String>> __livesHereListItems =
      <DropdownMenuItem<String>>[];
  String? _selectedLivesHere;

  // String _selectedOccupation="Software Engg.";
  String _selectedGender = "Male";
  ProgressDialog? _progressDialog;
  //final ContactPicker _contactPicker = ContactPicker();
  PhoneContact? _contact;
  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getBloodGroupData();
    getMembershipTypeData();
    gteLivesHereData();

    _selectedMembershipType = 'Owner Family';
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('add_new_member'),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
        getAddNewMemberLayout(),
      ],
    );
  }

  getAddNewMemberLayout() {
    return SingleChildScrollView(
      child: AppContainer(
        child: Column(
          children: <Widget>[
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('name') + '*',
              controllerCallback: _nameController,
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
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                AppLocalizations.of(context).translate('male'),
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
                              child: AppIcon(Icons.check,
                                  iconColor: GlobalVariables.white),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: text(
                                  AppLocalizations.of(context)
                                      .translate('female'),
                                  textColor: GlobalVariables.primaryColor,
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
                  GlobalFunctions.getSelectedDateForDOB(context).then((value) {
                    _dobController.text = value.day.toString().padLeft(2, '0') +
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
                  print('contact Number : ' +
                      contact.phoneNumber!.number.toString());
                  _contact = contact;
                  setState(() {
                    if (_contact != null) {
                      //  _nameController.text = _contact.fullName;
                      /* String phoneNumber = contact.phoneNumber!.number
                          .toString()
                          .substring(
                          0,
                          contact.phoneNumber!.number
                              .toString()
                              .indexOf('(') -
                              1);*/
                      String phoneNumber = contact.phoneNumber!.number!
                          .trim()
                          .toString()
                          .replaceAll(" ", "");
                      _mobileController.text =
                          GlobalFunctions.getMobileFormatNumber(phoneNumber);
                      // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                    }
                  });
                },
              ),
            ),
            AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('contact2'),
              controllerCallback: _alterMobileController,
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
                      String phoneNumber = _contact!.phoneNumber
                          .toString()
                          .substring(
                              0,
                              _contact!.phoneNumber.toString().indexOf('(') -
                                  1);
                      _alterMobileController.text =
                          GlobalFunctions.getMobileFormatNumber(
                              phoneNumber.toString());
                      // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                    }
                  });
                },
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
                iconColor: GlobalVariables.secondaryColor,
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
                          iconColor: GlobalVariables.secondaryColor,
                        ),
                        //underline: SizedBox(),
                        /* hint: text(AppLocalizations.of(context).translate('membership_type') + '*',
                          textColor: GlobalVariables.lightGray,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),*/
                        decoration: InputDecoration(
                            //filled: true,
                            //fillColor: Hexcolor('#ecedec'),
                            labelText: AppLocalizations.of(context)
                                    .translate('membership_type') +
                                '*',
                            labelStyle: TextStyle(
                                color: GlobalVariables.lightGray,
                                fontSize: GlobalVariables.textSizeSMedium),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))
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
                          iconColor: GlobalVariables.secondaryColor,
                        ),
                        // underline: SizedBox(),
                        /*hint: text(
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
                            labelStyle: TextStyle(
                                color: GlobalVariables.lightGray,
                                fontSize: GlobalVariables.textSizeSMedium),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))
                            // border: new CustomBorderTextFieldSkin().getSkin(),
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
                  child: AppTextField(
                    textHintContent:
                        AppLocalizations.of(context).translate('occupation'),
                    controllerCallback: _occupationController,
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
                        items: __bloodGroupListItems,
                        value: _selectedBloodGroup,
                        onChanged: changeBloodGroupDropDownItem,
                        isExpanded: true,
                        icon: AppIcon(
                          Icons.keyboard_arrow_down,
                          iconColor: GlobalVariables.secondaryColor,
                        ),
                        decoration: InputDecoration(
                            //filled: true,
                            //fillColor: Hexcolor('#ecedec'),
                            labelText: AppLocalizations.of(context)
                                .translate('blood_group'),
                            labelStyle: TextStyle(
                                color: GlobalVariables.lightGray,
                                fontSize: GlobalVariables.textSizeSMedium),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))
                            // border: new CustomBorderTextFieldSkin().getSkin(),
                            ),
                        /*underline: SizedBox(),
                        hint: text(
                          AppLocalizations.of(context)
                              .translate('blood_group'),
                          textColor: GlobalVariables.lightGray,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),*/
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                                      image:
                                          FileImage(File(attachmentFilePath!)),
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
                                    fontSize: GlobalVariables.textSizeSMedium),
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
            /* _selectedMembershipType =="Tenant" ? Row(
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
                                  image:
                                  FileImage(File(attachmentIdentityProofFilePath!)),
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
                                  } else {
                                    GlobalFunctions.askPermission(
                                        Permission.storage)
                                        .then((value) {
                                      if (value) {
                                        openIdentityProofFile(context);
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
                                  iconColor: GlobalVariables.secondaryColor,
                                  iconSize: 20.0,
                                ),
                                label: text(
                                  AppLocalizations.of(context)
                                      .translate('attach_identity_proof')+'*',
                                  textColor: GlobalVariables.primaryColor,
                                  fontSize: GlobalVariables.textSizeSMedium
                                ),
                              ),
                            ),
                            Container(
                              //alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: text(
                                'OR',
                                textColor: GlobalVariables.lightGray,
                                  fontSize: GlobalVariables.textSizeSMedium
                              ),
                            ),
                            Container(
                              child: TextButton.icon(
                                  onPressed: () {
                                      openIdentityProofCamera(context);
                                    } else {
                                      GlobalFunctions.askPermission(
                                          Permission.storage)
                                          .then((value) {
                                        if (value) {
                                          openIdentityProofCamera(context);
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
                                    iconSize: 20.0,
                                  ),
                                  label: text(
                                      AppLocalizations.of(context)
                                          .translate('take_identity_proof_picture')+'*',
                                      textColor: GlobalVariables.primaryColor,
                                      fontSize: GlobalVariables.textSizeSMedium
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ) : SizedBox(),
            _selectedMembershipType =="Tenant" ? Row(
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
                              child: TextButton.icon(
                                onPressed: () {
                                    openPoliceVerificationFile(context);
                                  } else {
                                    GlobalFunctions.askPermission(
                                        Permission.storage)
                                        .then((value) {
                                      if (value) {
                                        openPoliceVerificationFile(context);
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
                                  iconColor: GlobalVariables.secondaryColor,
                                  iconSize: 20.0,
                                ),
                                label: text(
                                  attachmentPoliceVerificationFileName!=null ? attachmentPoliceVerificationFileName : AppLocalizations.of(context)
                                      .translate('attach_police_verification'),
                                  textColor: GlobalVariables.primaryColor,
                                    fontSize: GlobalVariables.textSizeSMedium
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ) : SizedBox(),*/
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
    );
  }

  void verifyInfo() {
    if (_nameController.text.length > 0) {
      // if(_dobController.text.length>0){

      if (_mobileController.text.length > 0 &&
          _mobileController.text.length == 10) {
        //  if(_emailController.text.length>0){

        //  if(_selectedBloodGroup!=null || _selectedBloodGroup.length>0){

        // if(_occupationController.text.length>0){

        if (_selectedMembershipType != null) {
          if (_selectedLivesHere != null) {
            if (_alterMobileController.text.length > 0) {
              if (_alterMobileController.text.length > 0 &&
                  _alterMobileController.text.length == 10) {
                addMember();
              } else {
                GlobalFunctions.showToast(
                    'Please Enter Valid Alternate Mobile Number');
              }
            } else {
              addMember();
            }
          } else {
            GlobalFunctions.showToast('Please Select Lives Here');
          }
        } else {
          GlobalFunctions.showToast('Please Select MemberShip Type');
        }

        /* }else{
                GlobalFunctions.showToast('Please Enter Occupation');
              }*/
        /*}else{
              GlobalFunctions.showToast('Please Select BloodGroup');
            }*/
        /*}else{
            GlobalFunctions.showToast('Please Enter EmailId');
          }*/
      } else {
        GlobalFunctions.showToast('Please Enter Valid Mobile Number');
      }
      /*}else{
        GlobalFunctions.showToast('Please Select Date of Birth');
      }*/
    } else {
      GlobalFunctions.showToast('Please Enter Name');
    }
  }

  Future<void> addMember() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    String? attachmentName;
    String? attachment;

    if (attachmentFileName != null && attachmentFilePath != null) {
      attachmentName = attachmentFileName;
      attachment =
          GlobalFunctions.convertFileToString(attachmentCompressFilePath!);
    }

    //print('attachment lengtth : '+attachment.length.toString());

    _progressDialog!.show();
    restClient
            .addMember(
                userId,
                societyId,
                block,
                flat,
                _nameController.text,
                _selectedGender,
                _dobController.text,
                _emailController.text,
                _mobileController.text,
                _alterMobileController.text,
                _selectedBloodGroup,
                _occupationController.text,
                _selectedLivesHere!,
                _selectedMembershipType!,
                _addressController.text,
                attachment)
            .then((value) async {
      print('add member Status value : ' + value.toString());
      _progressDialog!.dismiss();
      if (value.status!) {
        if (attachmentFileName != null && attachmentFilePath != null) {
          await GlobalFunctions.removeFileFromDirectory(attachmentFilePath!);
          await GlobalFunctions.removeFileFromDirectory(
              attachmentCompressFilePath!);
        }
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseMyUnit(
                    AppLocalizations.of(context).translate('my_household'))));
      }
      GlobalFunctions.showToast(value.message!);
    }) /*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.dismiss();
          }
          break;
        default:
      }
    })*/
        ;
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
    print('file Name : ' + attachmentFileName.toString());
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

  /*void openIdentityProofFile(BuildContext context) {
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
    attachmentIdentityProofFileName = attachmentIdentityProofFilePath!.substring(
        attachmentIdentityProofFilePath!.lastIndexOf('/') + 1, attachmentIdentityProofFilePath!.length);
    print('file Name : ' + attachmentIdentityProofFileName.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
              attachmentIdentityProofFilePath!, value.toString() + '/' + attachmentIdentityProofFileName!)
          .then((value) {
        attachmentIdentityProofCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentIdentityProofCompressFilePath!);
        setState(() {});
      });
    });
  }


  void openPoliceVerificationFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      attachmentPoliceVerificationFilePath = value;
      getCompressPoliceVerificationFilePath();
    });
  }

  void getCompressPoliceVerificationFilePath() {
    attachmentPoliceVerificationFileName = attachmentPoliceVerificationFilePath!.substring(
        attachmentPoliceVerificationFilePath!.lastIndexOf('/') + 1, attachmentPoliceVerificationFilePath!.length);
    print('file Name : ' + attachmentPoliceVerificationFileName.toString());
    GlobalFunctions.getAppDocumentDirectory().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(
          attachmentPoliceVerificationFilePath!, value.toString() + '/' + attachmentPoliceVerificationFileName!)
          .then((value) {
        attachmentPoliceVerificationCompressFilePath = value.toString();
        print('Cache file path : ' + attachmentPoliceVerificationCompressFilePath!);
        setState(() {});
      });
    });
  }*/

  void getBloodGroupData() {
    _bloodGroupList = ["A+", "O+", "B+", "AB+", "A-", "O-", "B-", "AB-"];
    for (int i = 0; i < _bloodGroupList.length; i++) {
      __bloodGroupListItems.add(DropdownMenuItem(
        value: _bloodGroupList[i],
        child: text(
          _bloodGroupList[i],
          textColor: GlobalVariables.black,
        ),
      ));
    }
    //  _selectedBloodGroup = __bloodGroupListItems[0].value;
  }

  getMembershipTypeData() {
    //_membershipTypeList = ["Owner", "Owner Family", "Tenant"];
    _membershipTypeList = ["Owner Family"];
    for (int i = 0; i < _membershipTypeList.length; i++) {
      __membershipTypeListItems.add(DropdownMenuItem(
        value: _membershipTypeList[i],
        child: text(_membershipTypeList[i],
            textColor: GlobalVariables.black,
            fontSize: GlobalVariables.textSizeSMedium),
      ));
    }
    setState(() {});
    /* GlobalFunctions.getUserType().then((value) {
      if (value.toLowerCase() != 'tenant') {
        if(memberType.toLowerCase()=='tenant'){
          _membershipTypeList = ["Tenant"];
        }else */ /*if(value.toLowerCase()=='owner')*/ /*{
          _membershipTypeList = ["Owner Family"];
        }
      } else {
        _membershipTypeList = ["Tenant"];
      }
      for (int i = 0; i < _membershipTypeList.length; i++) {
        __membershipTypeListItems.add(DropdownMenuItem(
          value: _membershipTypeList[i],
          child: text(
            _membershipTypeList[i],
            textColor: GlobalVariables.black,
          ),
        ));
      }
      setState(() {});*/
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

  void changeBloodGroupDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedBloodGroup = value;
      print('_selctedItem:' + _selectedBloodGroup.toString());
    });
  }

  void changeMembershipTypeDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedMembershipType = value;
      print('_selctedItem:' + _selectedMembershipType.toString());
    });
  }

  void changeLivesHereDropDownItem(String? value) {
    print('clickable value : ' + value.toString());
    setState(() {
      _selectedLivesHere = value;
      print('_selctedItem:' + _selectedLivesHere.toString());
    });
  }
}
