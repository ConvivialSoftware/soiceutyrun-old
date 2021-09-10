import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ProfileInfo.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseDisplayProfileInfo extends StatefulWidget {
  String userId, userType;

  BaseDisplayProfileInfo(this.userId, this.userType);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DisplayProfileInfoState(userId, userType);
  }
}

class DisplayProfileInfoState
    extends BaseStatefulState<BaseDisplayProfileInfo> {
  ProgressDialog _progressDialog;

  List<ProfileInfo> _profileList = List<ProfileInfo>();

  String userId,
      societyId,
      societyName,
      userType,
      loggedUserType = '',
      loggedUserId;
  bool isEdit = false;
  TextEditingController _reasonController = TextEditingController();

  DisplayProfileInfoState(this.userId, this.userType);
  bool isEditOptionDisplay = false;
  bool isDeleteOptionDisplay = false;

  @override
  void initState() {
    super.initState();
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        geProfileData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });

    if (loggedUserType.toLowerCase() == 'tenant' &&
        userType.toLowerCase() == 'tenant') {
      isEditOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() != 'tenant' &&
        userType.toLowerCase() == 'tenant') {
      isEditOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() != 'tenant' &&
        userType.toLowerCase() != 'tenant') {
      isEditOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() == 'tenant' &&
        userType.toLowerCase() != 'tenant') {
      isEditOptionDisplay = false;
    }
    print('loggedUserType : ' + loggedUserType.toLowerCase());
    print('userType : ' + userType.toLowerCase());



    if (loggedUserType.toLowerCase() == 'owner') {
      isDeleteOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() == 'owner family' &&
        userType == 'owner') {
      isDeleteOptionDisplay = false;
    } else if (loggedUserType.toLowerCase() == 'owner' &&
        userType == 'owner family') {
      isDeleteOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() == 'owner' &&
        userType == 'tenant') {
      isDeleteOptionDisplay = true;
    } else if (loggedUserType.toLowerCase() == 'owner' && userType == 'owner') {
      isDeleteOptionDisplay = false;
    } else if (loggedUserType.toLowerCase() == 'tenant' &&
        userType == 'tenant') {
      isDeleteOptionDisplay = true;
    }

    if (_profileList.length > 0) {
      if (loggedUserId == userId) {
        isDeleteOptionDisplay = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: GlobalVariables.veryLightGray,
        appBar: AppBar(
          backgroundColor: GlobalVariables.primaryColor,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              if (!isEdit) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop('profile');
              }
            },
            child: AppIcon(
              Icons.arrow_back,
              iconColor: GlobalVariables.white,
            ),
          ),
          actions: [
            PopupMenuButton(
                icon: AppIcon(Icons.more_vert,
                    iconColor:
                        // isMenuEnable ?
                        GlobalVariables.white
                    // : GlobalVariables.transparent
                    ),
                // add this line
                itemBuilder: (_) => <PopupMenuItem<String>>[
                  if(isEditOptionDisplay)

                      new PopupMenuItem<String>(
                          child: Container(
                              width: 100,
                              height: 30,
                              child: text("Edit",
                                  textColor: GlobalVariables.black,
                                  fontSize: GlobalVariables.textSizeSMedium)),
                          value: 'edit'),
                  new PopupMenuItem<String>(
                      child: Container(
                          width: 100,
                          height: 30,
                          child: text("Move Out",
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeSMedium)),
                      value: 'move_out'),
                    ],
                onSelected: (index) async {
                  switch (index) {
                    case 'move_out':
                      showDialog(
                          context: context,
                          builder: (BuildContext
                          context) =>
                              StatefulBuilder(builder:
                                  (BuildContext context,
                                  StateSetter
                                  setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10.0)),
                                  child:
                                  deleteFamilyMemberLayout(),
                                );
                              }));
                      break;
                    case 'edit':

                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BaseEditProfileInfo(userId, societyId)));

                      print('Back Result : ' + result.toString());
                      if (result == 'profile') {
                        isEdit = true;
                        geProfileData();
                      }

                      break;
                  }
                }),
          ],
          title: AutoSizeText(
            AppLocalizations.of(context).translate('my_profile'),
            style: TextStyle(color: GlobalVariables.white),
          ),
        ),
        body: WillPopScope(
            child: getBaseLayout(),
            onWillPop: () {
              if (!isEdit) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop('profile');
              }
              return;
            }),
      ),
    );
  }

  void geProfileData() async {
    societyName = await GlobalFunctions.getSocietyName();
    societyId = await GlobalFunctions.getSocietyId();
    loggedUserType = await GlobalFunctions.getUserType();
    loggedUserId = await GlobalFunctions.getUserId();
    print('loggedUserType : ' + loggedUserType.toString());
    print('societyName : ' + societyName.toString());
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    _progressDialog.show();
    restClient.getProfileData(societyId, userId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;
        _profileList =
            List<ProfileInfo>.from(_list.map((i) => ProfileInfo.fromJson(i)));
        print('Display User Type : ' + _profileList[0].TYPE.toString());
        print('Display User Type : ' + userType.toString());
        setState(() {});
      }
    });
  }

  getBaseLayout() {

    return _profileList.length > 0
        ? Stack(
            children: <Widget>[
              GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 200.0),
              getProfileInfoLayout(),
              //isEditOptionDisplay ? editProfileFabLayout() : Container(),
              /*AppPermission.isUserAdminPermission ?
              userType == 'tenant' ? Container(
                margin: EdgeInsets.only(left: 16,bottom: 8),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      AppButton(
                          textContent: AppLocalizations.of(context).translate('renew'),
                          onPressed: () {

                          }),
                      SizedBox(width: 8,),
                      AppButton(
                          textContent: AppLocalizations.of(context).translate('close'),
                          onPressed: () {

                          }),
                    ],
                  ),
                ),
              ):SizedBox() : SizedBox()*/
              // deleteProfileFabLayout(),
            ],
          )
        : SizedBox();
  }

  getProfileInfoLayout() {

    return _profileList.length > 0
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //SizedBox(height: 16),
                AppContainer(
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              child: _profileList[0].PROFILE_PHOTO.length == 0
                                  ? AppAssetsImage(
                                      GlobalVariables.componentUserProfilePath,
                                      imageWidth: 60.0,
                                      imageHeight: 60.0,
                                      borderColor: GlobalVariables.grey,
                                      borderWidth: 1.0,
                                      fit: BoxFit.cover,
                                      radius: 30.0,
                                    )
                                  : AppNetworkImage(
                                      _profileList[0].PROFILE_PHOTO,
                                      imageWidth: 60.0,
                                      imageHeight: 60.0,
                                      borderColor: GlobalVariables.grey,
                                      borderWidth: 1.0,
                                      fit: BoxFit.cover,
                                      radius: 30.0,
                                    )),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        child: primaryText(_profileList[0].NAME,
                                            maxLine: 2)),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    /*isDeleteOptionDisplay
                                        ? AppIconButton(
                                            Icons.delete,
                                            iconColor: GlobalVariables.green,
                                            onPressed: () {

                                            },
                                          )
                                        : Container(),*/
                                  ],
                                ),
                                secondaryText(societyName),
                                secondaryText(_profileList[0].BLOCK +
                                    _profileList[0].FLAT),
                                // secondaryText(_profileList[0].Phone),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppContainer(
                  isListItem: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 8),
                      primaryText('Personal Info'),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.person,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].NAME,
                              textStyleHeight: 1.0)
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.transgender_sharp,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].GENDER),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.bloodtype_sharp,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].BLOOD_GROUP),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.date_range,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].DOB == '0000-00-00'
                              ? ''
                              : GlobalFunctions.convertDateFormat(
                                  _profileList[0].DOB, "dd-MM-yyyy")),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.location_city_sharp,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].ADDRESS, maxLine: 3),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                AppContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 8),
                      primaryText('Contacts'),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.call,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].Phone),
                        ],
                      ),
                      Divider(),
                      _profileList[0].ALTERNATE_CONTACT1.isNotEmpty? SizedBox(height: 16):SizedBox(),
                      _profileList[0].ALTERNATE_CONTACT1.isNotEmpty?Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.call,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].ALTERNATE_CONTACT1??''),
                        ],
                      ):SizedBox(),
                      _profileList[0].ALTERNATE_CONTACT1.isNotEmpty?Divider():SizedBox(),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppIcon(
                            Icons.email_sharp,
                            iconColor: GlobalVariables.secondaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          secondaryText(_profileList[0].Email??''),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          )
        : Container();
  }

 /* editProfileFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () async {
                //GlobalFunctions.showToast('Fab CLick');

                // Navigator.of(context).pop('profile');

              },
              child: AppIcon(
                Icons.edit,
                iconColor: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }*/

  deleteFamilyMemberLayout() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: primaryText(
              AppLocalizations.of(context).translate('sure_delete'),
              textColor: GlobalVariables.black,
              /*fontSize: GlobalVariables.textSizeLargeMedium,
              fontWeight: FontWeight.bold,*/
            ),
          ),
          Container(
            height: 100,
            child: AppTextField(
              textHintContent:
                  AppLocalizations.of(context).translate('reason') + '*',
              controllerCallback: _reasonController,
              maxLines: 99,
              contentPadding: EdgeInsets.only(top: 14),
            ),
          ),
          Container(
            //margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                    onPressed: () {
                      if (_reasonController.text.length > 0) {
                        Navigator.of(context).pop();
                        moveOutMember();
                      } else {
                        GlobalFunctions.showToast('Please Enter Reason');
                      }
                    },
                    child: text(AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: text(
                        AppLocalizations.of(context).translate('no'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> moveOutMember() async {
    _progressDialog.show();
    Provider.of<UserManagementResponse>(context, listen: false)
        .deactivateUser(userId, _reasonController.text, _profileList[0].BLOCK,
            _profileList[0].FLAT)
        .then((value) {
      _progressDialog.hide();
      if (value.status) {
        Navigator.of(context).pop('back');
      }
      GlobalFunctions.showToast(value.message);
    });
  }
}
