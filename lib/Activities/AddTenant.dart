import 'dart:async';

//import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddAgreement.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseAddTenant extends StatefulWidget {
  AddAgreementInfo agreementInfo;
  bool isAdmin;

  BaseAddTenant(this.agreementInfo, this.isAdmin);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddTenantState();
  }
}

class AddTenantState extends State<BaseAddTenant> {
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

  ///private/var/mobile/Containers/Data/Application/9C028A34-9A90-4CFF-89DA-6F17D34AE672/tmp/com.convivial.SocietyRunApp-Inbox/Sample.pdf
  /* List<String> _membershipTypeList = new List<String>();
  List<DropdownMenuItem<String>> __membershipTypeListItems =
  new List<DropdownMenuItem<String>>();*/
  String _selectedMembershipType = 'Tenant';

/*  List<String> _livesHereList = new List<String>();
  List<DropdownMenuItem<String>> __livesHereListItems =
  new List<DropdownMenuItem<String>>();*/
  String _selectedLivesHere = 'Yes';

  // String _selectedOccupation="Software Engg.";
  String _selectedGender = "Male";
  ProgressDialog? _progressDialog;

  final PageController pageController = PageController();
  int currentPageIndex = 0;
  int pageCount = 0;
  List<AddTenantInfo> _addTenantInfoList = <AddTenantInfo>[];
  //final ContactPicker _contactPicker = ContactPicker();
  PhoneContact? _contact;

/*
  FlutterUploader uploader = FlutterUploader();
  StreamSubscription _progressSubscription;
  StreamSubscription _resultSubscription;
  Map<String, UploadItem> _tasks = {};*/

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    getBloodGroupData();
    //  getMembershipTypeData();
    // gteLivesHereData();
    //_dobController.text = DateTime.now().toLocal().day.toString().padLeft(2, '0')+"-"+DateTime.now().toLocal().month.toString().padLeft(2, '0')+"-"+DateTime.now().toLocal().year.toString();
  
    _selectedMembershipType = 'Tenant';
    //_addTenantInfoList = List<AddTenantInfo>.filled(int.parse(widget.agreementInfo.noOfBachelor), null, growable: false);
    //_addTenantInfoList.length = (int.parse(widget.agreementInfo.noOfBachelor));
    //_addTenantInfoList.length = int.parse(widget.agreementInfo.noOfBachelor);

    AddTenantInfo a = AddTenantInfo();
    _addTenantInfoList =
        List.filled(int.parse(widget.agreementInfo.noOfBachelor), a);

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
    //_progressSubscription?.cancel();
    //_resultSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //GlobalFunctions.showToast(memberType.toString());
    // TODO: implement build
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('add_tenant'),
        ),
        body: getBaseLayout(),
      ),
    );
  }

  List<Widget> buildDotIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < int.parse(widget.agreementInfo.noOfBachelor); i++) {
      list.add(i == pageCount
          ? indicator(isActive: true)
          : indicator(isActive: false));
    }
    return list;
  }

  getBaseLayout() {
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
        Container(
          margin: EdgeInsets.only(bottom: 60),
          child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              onPageChanged: (index) {
                pageCount = index;
                setState(() {});
              },
              itemBuilder: (context, position) {
                if (position == int.parse(widget.agreementInfo.noOfBachelor))
                  return SizedBox();
                else
                  return getAddTenantLayout(position);
              }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 20),
            padding: EdgeInsets.only(left: 16),
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
                color: GlobalVariables.primaryColor,
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: text('${pageCount + 1}',
                      fontSize: GlobalVariables.textSizeMedium,
                      textColor: GlobalVariables.primaryColor),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: buildDotIndicator(),
                ),
                pageCount != int.parse(widget.agreementInfo.noOfBachelor) - 1
                    ? TextButton(
                        onPressed: () {
                          if (verifyInfo()) {
                            if (_alterMobileController.text.length > 0) {
                              if (_alterMobileController.text.length > 0 &&
                                  _alterMobileController.text.length == 10) {
                                addTenantInfo();
                                removeViewData();
                                pageController.nextPage(
                                    duration: Duration(seconds: 1),
                                    curve: Curves.easeInOut);
                              } else {
                                GlobalFunctions.showToast(
                                    'Please Enter Valid Alternate Mobile Number');
                              }
                            } else {
                              addTenantInfo();
                              removeViewData();
                              pageController.nextPage(
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeInOut);
                            }
                          }
                        },
                        child: text('Next',
                            fontSize: GlobalVariables.textSizeMedium,
                            textColor: GlobalVariables.white),
                      )
                    : TextButton(
                        onPressed: () {
                          //Navigator.pop(context);
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => OPBottomNavigationScreen()));
                          if (verifyInfo()) {
                            addTenantInfo();
                            //print('Path : '+widget.agreementInfo.agreementAttachmentPath);
                            addAgreementWithTenantDetails();
                          }
                        },
                        child: text('Submit',
                            fontSize: GlobalVariables.textSizeMedium,
                            textColor: GlobalVariables.white),
                      )
              ],
            ),
          ),
        )

        // getAddTenantLayout(),
      ],
    );
  }

  getAddTenantLayout(int pageCount) {
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
                  print('contact Number : ' + contact.phoneNumber.toString());
                  _contact = contact;
                  setState(() {
                    if (_contact != null) {
                      //  _nameController.text = _contact.fullName;
                      /* String phoneNumber = _contact!.phoneNumber
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
                    AppLocalizations.of(context).translate('permanent_address'),
                controllerCallback: _addressController,
                maxLines: 99,
                contentPadding: EdgeInsets.only(top: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool verifyInfo() {
    if (_nameController.text.length > 0) {
      // if(_dobController.text.length>0){

      if (_mobileController.text.length > 0 &&
          _mobileController.text.length == 10) {
        //  if(_emailController.text.length>0){

        //  if(_selectedBloodGroup!=null || _selectedBloodGroup.length>0){

        // if(_occupationController.text.length>0){

        if (_selectedMembershipType != null) {
          if (_selectedLivesHere != null) {
            return true;
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

    return false;
  }

  Future<void> addAgreementWithTenantDetails() async {
    print('file type : ' +
        widget.agreementInfo.agreementAttachmentName.substring(
            widget.agreementInfo.agreementAttachmentName.indexOf(".") + 1,
            widget.agreementInfo.agreementAttachmentName.length));
    // print('file path : '+ );

    if (widget.agreementInfo.rentedTo ==
        AppLocalizations.of(context).translate('group_bachelor')) {
      widget.agreementInfo.rentedTo = "Group";
    }
    String societyId = await GlobalFunctions.getSocietyId();

    List<Map<String, String?>> tlist = <Map<String, String?>>[];
    // List<Map<String,String>> tlist = _addTenantInfoList.forEach((element) => element.toMap());
    _addTenantInfoList.forEach((element) => tlist.add(element.toMap()));

    _progressDialog!.show();
    Provider.of<UserManagementResponse>(context, listen: false)
        .addAgreement(
            societyId,
            widget.agreementInfo.block,
            widget.agreementInfo.flat,
            tlist,
            widget.agreementInfo.startDate,
            widget.agreementInfo.endDate,
            widget.agreementInfo.agreementAttachmentPath,
            widget.agreementInfo.rentedTo,
            widget.agreementInfo.isNocEmail,
            widget.agreementInfo.agreementAttachmentName.substring(
                widget.agreementInfo.agreementAttachmentName.indexOf(".") + 1,
                widget.agreementInfo.agreementAttachmentName.length),
            widget.isAdmin)
        .then((value) async {
      _progressDialog!.dismiss();

      GlobalFunctions.showToast(value.message!);
      if (value.status!) {
        getMessageInfo();
        await GlobalFunctions.removeFileFromDirectory(
            widget.agreementInfo.agreementAttachmentPath);

        //  Navigator.of(context).pop();
        // Navigator.of(context).pop();

        /* if (widget.agreementInfo.agreementAttachmentName != null && widget.agreementInfo.agreementAttachmentPath != null) {
          print('attachmentFilePath : ' + widget.agreementInfo.agreementAttachmentPath.toString());
          print('attachmentFileName : ' + widget.agreementInfo.agreementAttachmentName.toString());
          print('attachmentFileName : ' +
              widget.agreementInfo.agreementAttachmentPath.replaceAll(widget.agreementInfo.agreementAttachmentName, "").toString());

         */ /* File file = File(attachmentFilePath);
          Uint8List bytes = file.readAsBytesSync();
          _progressDialog.show();
          AWSClient()
              .uploadData('uploads', attachmentFileName, bytes)
              .then((value) {
            _progressDialog.hide();
          });*/ /*


*/ /*
          final tag = "File upload ${_tasks.length + 1}";
          final taskId = await uploader.enqueue(
              url: "https://societyrun.com//Uploads/",
              //required: url to upload to
              files: [
                FileItem(
                    filename: widget.agreementInfo.agreementAttachmentName,
                    savedDir: widget.agreementInfo.agreementAttachmentPath.replaceAll(
                        widget.agreementInfo.agreementAttachmentName, ""),
                    fieldname: "file")
              ],
              // required: list of files that you want to upload
              method: UploadMethod.POST,
              // HTTP method  (POST or PUT or PATCH)
              // headers: {"admin": "1234", "admin1": "1234"},
              //  data: {"name": "john"}, // any data you want to send in upload request
              showNotification: true,
              // send local notification (android only) for upload status
              tag: widget.agreementInfo.agreementAttachmentName); // unique tag for upload task

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
          });*/ /*

        }
*/
      }
    });
  }

  getMessageInfo() {
    //print('paymentId : ' + paymentId.toString());
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: AppContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: AppAssetsImage(
                            GlobalVariables.successIconPath,
                            imageWidth: 80,
                            imageHeight: 80,
                          ),
                        ),
                        /* Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('successful_payment'))),*/
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('tenant_add_status'),
                              textColor: GlobalVariables.primaryColor,
                              fontSize: GlobalVariables.textSizeNormal,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: text(
                                AppLocalizations.of(context)
                                    .translate('tenant_add_status_desc'),
                                textColor: GlobalVariables.grey,
                                fontSize: GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.normal)),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topRight,
                          child: AppButton(
                            textContent:
                                AppLocalizations.of(context).translate('okay'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ));
            }));
  }

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

  void changeBloodGroupDropDownItem(String? value) {
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

  addTenantInfo() {
    print('Size : ' + _addTenantInfoList.length.toString());
    print('pageCount : ' + pageCount.toString());
    // _addTenantInfoList.insert(pageCount,);
    _addTenantInfoList[pageCount] = AddTenantInfo(
      name: _nameController.text,
      gender: _selectedGender,
      dob: _dobController.text,
      mobile: _mobileController.text,
      alternateMobile: _alterMobileController.text,
      emailId: _emailController.text,
      membershipType: _selectedMembershipType,
      livesHere: _selectedLivesHere,
      occupations: _occupationController.text,
      bloodGroup: _selectedBloodGroup ?? '',
      permanentAddress: _addressController.text,
      //attachmentPhoto: attachmentCompressFilePath==null ?  '' : GlobalFunctions.convertFileToString(attachmentCompressFilePath),
      // attachmentIdentity: attachmentIdentityProofCompressFilePath==null ?  '' :GlobalFunctions.convertFileToString(attachmentIdentityProofCompressFilePath)
    );

    print('tanant list : ' + _addTenantInfoList.toString());
  }

  void removeViewData() {
    _nameController.text = '';
    _selectedGender = 'Male';
    _dobController.text = '';
    _mobileController.text = '';
    _alterMobileController.text = '';
    _emailController.text = '';
    //_selectedLivesHere=null;
    _occupationController.text = '';
    _selectedBloodGroup = null;
    _addressController.text = '';
    /* attachmentFileName=null;
    attachmentFilePath=null;
    attachmentCompressFilePath=null;
    attachmentIdentityProofFileName=null;
    attachmentIdentityProofFilePath=null;
    attachmentIdentityProofCompressFilePath=null;*/
  }
}

class AddTenantInfo {
  String? name,
      gender,
      dob,
      mobile,
      alternateMobile,
      membershipType,
      emailId,
      livesHere,
      occupations,
      bloodGroup,
      permanentAddress;

  AddTenantInfo({
    this.name,
    this.gender,
    this.dob,
    this.mobile,
    this.alternateMobile,
    this.membershipType,
    this.emailId,
    this.livesHere,
    this.occupations,
    this.bloodGroup,
    this.permanentAddress,
  });

  Map<String, String?> toMap() {
    return {
      GlobalVariables.NAME: name,
      GlobalVariables.GENDER: gender,
      GlobalVariables.DOB: dob,
      GlobalVariables.USER_NAME: emailId,
      GlobalVariables.MOBILE: mobile,
      GlobalVariables.ALTERNATE_CONTACT1: alternateMobile,
      GlobalVariables.BLOOD_GROUP: bloodGroup,
      GlobalVariables.OCCUPATION: occupations,
      GlobalVariables.LIVES_HERE: livesHere,
      GlobalVariables.TYPE: membershipType,
      GlobalVariables.ADDRESS: permanentAddress,
    };
  }
}
