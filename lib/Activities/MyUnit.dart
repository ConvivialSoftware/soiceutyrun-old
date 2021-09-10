import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/DisplayTenantInfo.dart';
import 'package:societyrun/Activities/Dues.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/StaffCategory.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddAgreement.dart';
import 'base_stateful.dart';

class BaseMyUnit extends StatefulWidget {
  String pageName;

  BaseMyUnit(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyUnitState(pageName);
  }
}

class MyUnitState extends BaseStatefulState<BaseMyUnit>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  var firstTicketContainerColor = GlobalVariables.secondaryColor;
  var secondTicketContainerColor = GlobalVariables.white;

  var firstTicketTextColor = GlobalVariables.white;
  var secondTicketTextColor = GlobalVariables.primaryColor;
  bool isOpenTicket = true;
  bool isClosedTicket = false;

  var userId = "", societyId, name = "", flat, block;
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';
  ProgressDialog _progressDialog;
  String pageName;
  bool isDuesTabAPICall = false;
  bool isHouseholdTabAPICall = false;

  MyUnitState(this.pageName);

  @override
  void initState() {
    super.initState();
    getSharedPreferenceData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    print(pageName.toString());
    _handleTabSelection();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    if (pageName != null) {
      redirectToPage(pageName);
    }
    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.veryLightGray,
              //resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                backgroundColor: GlobalVariables.primaryColor,
                centerTitle: true,
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context, 'back');
                  },
                  child: AppIcon(
                    Icons.arrow_back,
                    iconColor: GlobalVariables.white,
                  ),
                ),
                title: text(
                  AppLocalizations.of(context).translate('my_unit'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: WillPopScope(
                  child:
                      TabBarView(controller: _tabController, children: <Widget>[
                    Container(
                      color: GlobalVariables.veryLightGray,
                      child: !AppUserPermission.isUserHideMyDuesPermission
                          ? value.isLoading
                              ? GlobalFunctions.loadingWidget(context)
                              : BaseDues(
                                  mBlock: block,
                                  mFlat: flat,
                                )
                          : GlobalFunctions
                              .showAdminPermissionDialogToAccessFeature(
                                  context, false),
                    ),
                    value.isLoading
                        ? GlobalFunctions.loadingWidget(context)
                        : getMyHouseholdLayout(value),
                  ]),
                  onWillPop: onWillPop),
            ),
          );
        },
      ),
    );
  }

  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
        /*  onTap: (index){
          print('Call onTap');
          _callAPI(index);
        },*/
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_dues'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_household'),
            ),
          ), /*Tab(
            text: AppLocalizations.of(context).translate('my_tickets'),
          ),*/
          /* Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_documents'),
            ),
          ), */ /*Tab(
            text: AppLocalizations.of(context).translate('my_tenants'),
          ),*/
        ],
        controller: _tabController,
        unselectedLabelColor: GlobalVariables.white30,
        indicatorColor: GlobalVariables.white,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        labelColor: GlobalVariables.white,
      ),
    );
  }

  getMyHouseholdLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
          Container(
            child: Column(
              children: [
                profileLayout(),
                getFamilyLayout(value),
                getTenantLayout(value),
                getStaffLayout(value),
                getVehicleLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getFamilyLayout(UserManagementResponse value) {
    return Column(
      children: [
        userType != 'Tenant'
            ? Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_family'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppUserPermission.isUserAddMemberPermission
                        ? InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseAddNewMember("family")));
                              print('result back : ' + result.toString());
                              if (result != 'back') {
                                Provider.of<UserManagementResponse>(context,
                                        listen: false)
                                    .getUnitMemberData();
                              }
                            },
                            child: smallTextContainerOutlineLayout(
                                AppLocalizations.of(context).translate('add')),
                          )
                        : Container(),
                  ],
                ),
              )
            : Container(),
        userType != 'Tenant'
            ? value.memberList.length > 0
                ? AppContainer(
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: value.memberList.length,
                              itemBuilder: (context, position) {
                                return getContactListItemLayout(
                                    value.memberList, position, 'family');
                              },
                              //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  )
                : Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(16),
                    child: text(
                        AppLocalizations.of(context)
                            .translate('add_family_details'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium),
                  )
            : Container(),
      ],
    );
  }

  getTenantLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_tenant'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSocietyPermission.isSocHideTenantPermission
                  ? SizedBox()
                  : userType != 'Tenant' ? Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseAddAgreement(block, flat, false)));
                          },
                          child: smallTextContainerOutlineLayout(
                            AppLocalizations.of(context)
                                .translate('add_tenant'),
                          ),
                        ),
                        /*SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BaseAddNewMember("tenant")));
                      if (result != 'back') {
                        Provider.of<UserManagementResponse>(context,
                                listen: false)
                            .getUnitMemberData();
                      }
                    },
                    child: smallTextContainerOutlineLayout(
                      AppLocalizations.of(context).translate('add'),
                    ),
                  ),*/
                      ],
                    ):SizedBox(),
            ],
          ),
        ),
        AppSocietyPermission.isSocHideTenantPermission
            ? GlobalFunctions.showAdminPermissionDialogToAccessFeature(
                context, false)
            : value.tenantList.length > 0
                ? AppContainer(
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: value.tenantList.length,
                              itemBuilder: (context, position) {
                                return getContactListItemLayout(
                                    value.tenantList, position, 'tenant',
                                    userManagementInstance: value);
                              },
                              //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  )
                : Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(16),
                    child: text(
                        AppLocalizations.of(context)
                            .translate('add_tenant_details'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSMedium),
                  ),
      ],
    );
  }

  getStaffLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_staff'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseStaffCategory(false,"Staff")));
                },
                child: smallTextContainerOutlineLayout(
                  AppLocalizations.of(context).translate('add'),
                ),
              ),
            ],
          ),
        ),
        value.staffList.length > 0
            ? AppContainer(
                child: Builder(
                    builder: (context) => ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: value.staffList.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                value.staffList, position, 'staff');
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              )
            : Container(
                padding: EdgeInsets.all(16),
                child: text(
                    AppLocalizations.of(context).translate('add_staff_details'),
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeSMedium),
              ),
      ],
    );
  }

  getVehicleLayout(UserManagementResponse value) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          //color: GlobalVariables.white,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: text(
                  AppLocalizations.of(context).translate('my_vehicle'),
                  textColor: GlobalVariables.black,
                  fontSize: GlobalVariables.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSocietyPermission.isSocAddVehiclePermission
                  ? AppSocietyPermission.isSocHideVehiclePermission
                      ? SizedBox()
                      : InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseAddVehicle()));
                            print('result back : ' + result.toString());
                            if (result != 'back') {
                              Provider.of<UserManagementResponse>(context,
                                      listen: false)
                                  .getUnitMemberData();
                            }
                          },
                          child: smallTextContainerOutlineLayout(
                              AppLocalizations.of(context).translate('add')),
                        )
                  : Container(),
            ],
          ),
        ),
        AppSocietyPermission.isSocHideVehiclePermission
            ? GlobalFunctions.showAdminPermissionDialogToAccessFeature(
                context, false)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  value.vehicleList.length > 0
                      ? AppContainer(
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    // scrollDirection: Axis.horizontal,
                                    itemCount: value.vehicleList.length,
                                    itemBuilder: (context, position) {
                                      return getVehicleRecentTransactionListItemLayout(
                                          position, value);
                                    },
                                    //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        )
                      : Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(16),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('add_vehicle_details'),
                              textColor: GlobalVariables.grey,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                ],
              ),
      ],
    );
  }

  profileLayout() {
    return InkWell(
      onTap: () {
        navigateToProfilePage();
      },
      child: AppContainer(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    child:
                        GlobalVariables.userImageURLValueNotifer.value.length ==
                                0
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
                                GlobalVariables.userImageURLValueNotifer.value,
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
                      primaryText(
                          GlobalVariables.userNameValueNotifer.value.isEmpty
                              ? name
                              : GlobalVariables.userNameValueNotifer.value),
                      secondaryText(email),
                      secondaryText(phone),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              //margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: AppIconButton(
                          Icons.call,
                          iconColor: GlobalVariables.primaryColor,
                          onPressed: () {
                            launch("tel:" + phone);
                          },
                        ),
                      ),
                    ),
                    VerticalDivider(),
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: AppIconButton(
                          Icons.share,
                          iconColor: GlobalVariables.grey,
                          onPressed: () {
                            if (phone.length > 0) {
                              GlobalFunctions.shareData(
                                  GlobalVariables.userNameValueNotifer.value,
                                  'Name : ' +
                                      GlobalVariables
                                          .userNameValueNotifer.value +
                                      '\nContact : ' +
                                      phone);
                            } else if (email.length > 0) {
                              GlobalFunctions.shareData(
                                  GlobalVariables.userNameValueNotifer.value,
                                  'Name : ' +
                                      GlobalVariables
                                          .userNameValueNotifer.value +
                                      '\nMail ID : ' +
                                      email);
                            } else {
                              GlobalFunctions.showToast(
                                  AppLocalizations.of(context)
                                      .translate('mobile_email_not_found'));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getContactListItemLayout(var _list, int position, String memberType,
      {UserManagementResponse userManagementInstance}) {
    var call = '', email = '', userId, userType;
    if (memberType == 'family' || memberType == 'tenant') {
      if(memberType == 'tenant')
        call = _list[position].MOBILE.toString();
        else
        call = _list[position].Phone.toString();

      userId = _list[position].ID.toString();
      userType = _list[position].TYPE.toString();
      //    email = _list[position].EMAIL.toString();
    } else {
      call = _list[position].CONTACT.toString();
      userId = _list[position].SID.toString();
    }
    if (call == 'null') {
      call = '';
    }

    return InkWell(
      onTap: () async {
        print('userId : ' + userId);
        print('societyId : ' + societyId);
        if (memberType == 'family') {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseDisplayProfileInfo(userId, userType)));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        } else if (memberType == 'tenant') {
          List<TenantRentalRequest> tenantRentalRequest = userManagementInstance
              .tenantAgreementList
              .where((element) => element.ID == _list[position].AGREEMENT_ID)
              .toList();
//private/var/mobile/Containers/Data/Application/7C6B9535-92F8-437A-ABE7-BE8F1CA0F15E/tmp/com.convivial.SocietyRunApp-Inbox/Pay Slip September pdf (1).pdf
          if (tenantRentalRequest.length > 0) {
            var result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BaseTenantInfo(tenantRentalRequest[0], false)));
            if (result == 'back') {
              Provider.of<UserManagementResponse>(context, listen: false)
                  .getUnitMemberData();
            }
          }
        } else {
          print('_list[position] : ' + _list[position].toString());
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseStaffDetails(_list[position])));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        }
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    //margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: memberType == 'family' || memberType == 'tenant'
                        ? _list[position].PROFILE_PHOTO.length == 0
                            ? AppAssetsImage(
                                GlobalVariables.componentUserProfilePath,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                            : AppNetworkImage(
                                _list[position].PROFILE_PHOTO,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                        : _list[position].IMAGE.length == 0
                            ? AppAssetsImage(
                                GlobalVariables.componentUserProfilePath,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )
                            : AppNetworkImage(
                                _list[position].IMAGE,
                                imageWidth: 50.0,
                                imageHeight: 50.0,
                                borderColor: GlobalVariables.grey,
                                borderWidth: 1.0,
                                fit: BoxFit.cover,
                                radius: 25.0,
                              )),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      primaryText(
                        memberType == 'family' || memberType == 'tenant'
                            ? _list[position].NAME
                            : _list[position].STAFF_NAME,
                        maxLine: 2,
                      ),
                      call.length > 0
                          ? InkWell(
                              onTap: () {
                                launch("tel://" + call);
                              },
                              child: secondaryText(call,
                                  maxLine: 2,
                                  textColor: GlobalVariables.skyBlue),
                            )
                          : memberType == 'family' || memberType == 'tenant'
                              ? InkWell(
                                  onTap: () async {
                                    var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseEditProfileInfo(
                                                    userId, societyId)));
                                    if (result == 'profile') {
                                      Provider.of<UserManagementResponse>(
                                              context,
                                              listen: false)
                                          .getUnitMemberData();
                                    }
                                  },
                                  child: Container(
                                    //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                    alignment: Alignment.topLeft,
                                    child: secondaryText(
                                      AppLocalizations.of(context)
                                          .translate('add_phone'),
                                      textColor: GlobalVariables.skyBlue,
                                    ),
                                  ),
                                )
                              : Container(),
                    ],
                  ),
                ),
                Container(
                  child: AppIconButton(
                    Icons.share,
                    iconColor: GlobalVariables.grey,
                    iconSize: 20.0,
                    onPressed: () {
                      String name =
                          memberType == 'family' || memberType == 'tenant'
                              ? _list[position].NAME
                              : _list[position].STAFF_NAME;
                      String title = '';
                      String text = 'Name : ' + name + '\nContact : ' + call;
                      memberType == 'family' || memberType == 'tenant'
                          ? title = _list[position].NAME
                          : title = _list[position].STAFF_NAME;
                      print('titlee : ' + title);
                      GlobalFunctions.shareData(title, text);
                    },
                  ),
                )
              ],
            ),
            position != _list.length - 1 ? Divider() : Container(),
            /*call.length > 0
                ? Container(
                    // margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              launch("tel://" + call);
                            },
                            child: Container(
                              width: double.infinity,
                              child: AppIconButton(
                                Icons.call,
                                iconColor: GlobalVariables.green,
                                iconSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30, child: verticalDivider()),
                        Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              String name = family
                                  ? _list[position].NAME
                                  : _list[position].STAFF_NAME;
                              String title = '';
                              String text =
                                  'Name : ' + name + '\nContact : ' + call;
                              family
                                  ? title = _list[position].NAME
                                  : title = _list[position].STAFF_NAME;
                              print('titlee : ' + title);
                              GlobalFunctions.shareData(title, text);
                            },
                            child: Container(
                              width: double.infinity,
                              child: AppIconButton(
                                Icons.share,
                                iconColor: GlobalVariables.grey,
                                iconSize: 20.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))
                : family
                    ? InkWell(
                        onTap: () async {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseEditProfileInfo(userId, societyId)));
                          if (result == 'profile') {
                            Provider.of<UserManagementResponse>(context,
                                    listen: false)
                                .getUnitMemberData();
                          }
                        },
                        child: Container(
                          //margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                          alignment: Alignment.center,
                          child: text(
                            '+ ' +
                                AppLocalizations.of(context)
                                    .translate('add_phone'),
                            textColor: GlobalVariables.grey,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                    : Container()*/
          ],
        ),
      ),
    );
  }

  getVehicleRecentTransactionListItemLayout(
      int position, UserManagementResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      //margin: position == 0 ? EdgeInsets.only(top: 10) : EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: getIconForVehicle(value.vehicleList[position].WHEEL),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: primaryText(
                    value.vehicleList[position].MODEL,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: secondaryText(
                      value.vehicleList[position].VEHICLE_NO,
                      /* textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeMedium,
                        textStyleHeight: 1.0*/
                    ),
                  ),
                  /*AppPermission.isSocAddVehiclePermission
                      ? */
                  InkWell(
                    onTap: () {
                      print('Delete Position :' + position.toString());
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: deleteVehicleLayout(position, value),
                                );
                              }));
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: AppIcon(
                          Icons.delete,
                          iconColor: GlobalVariables.secondaryColor,
                        )),
                  )
                  // : Container(),
                ],
              )
            ],
          ),
          position != value.vehicleList.length - 1 ? Divider() : Container(),
        ],
      ),
    );
  }

  deleteVehicleLayout(int position, UserManagementResponse value) {
    return AppContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('sure_delete'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteVehicle(position, value);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.primaryColor,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
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

  getIconForVehicle(String vehicleType) {
    if (vehicleType == '4 Wheeler' ||
        vehicleType == '4' ||
        vehicleType == 'four') {
      return AppIcon(
        Icons.directions_car,
        iconColor: GlobalVariables.secondaryColor,
      );
    } else if (vehicleType == '2 Wheeler' ||
        vehicleType == '2' ||
        vehicleType == 'two') {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.secondaryColor,
      );
    } else {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.secondaryColor,
      );
    }
  }

  void redirectToPage(String item) {
    print('Call redirectToPage');

    if (item == AppLocalizations.of(context).translate('my_unit')) {
      //Redirect to my Unit
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('my_dues')) {
      //Redirect to  My Dues
      _tabController.animateTo(0);
      print('redirectToPage ' + pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_household')) {
      //Redirect to  My Household
      _tabController.animateTo(1);
      print('redirectToPage ' + pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_documents')) {
      //Redirect to  My Documents
      _tabController.animateTo(2);
    } else if (item == AppLocalizations.of(context).translate('my_tenants')) {
      //Redirect to  My Tenants
    } else {
      _tabController.animateTo(0);
    }
    if (pageName != null) {
      pageName = null;
      if (_tabController.index == 0) {
        _handleTabSelection();
      }
    }
  }

  void _handleTabSelection() {
    if (pageName == null) {
      print('Call _handleTabSelection');
      //if(_tabController.indexIsChanging){
      _callAPI(_tabController.index);
      //}
    }
  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              if (!AppUserPermission.isUserHideMyDuesPermission) {
                if (!isDuesTabAPICall) {
                  Provider.of<UserManagementResponse>(context, listen: false)
                      .getPayOption(block, flat)
                      .then((value) {});
                }
              }
            }
            break;
          case 1:
            {
              if (!isHouseholdTabAPICall) {
                Provider.of<UserManagementResponse>(context, listen: false)
                    .getUnitMemberData()
                    .then((value) {});
              }
            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  Future<void> navigateToProfilePage() async {
    String userType = await GlobalFunctions.getUserType();
    String userId = await GlobalFunctions.getUserId();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseDisplayProfileInfo(userId, userType)));
  }

  Future<bool> onWillPop() {
    Navigator.pop(context, 'back');
    return Future.value(true);
  }

  Future<void> getSharedPreferenceData() async {
    societyId = await GlobalFunctions.getSocietyId();
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    GlobalVariables.userNameValueNotifer.value = name;
    GlobalVariables.userNameValueNotifer.notifyListeners();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    userType = await GlobalFunctions.getUserType();

    print('societyId : ' + societyId);
    print('UserId : ' + userId);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('userType : ' + userType);
  }

  Future<void> deleteVehicle(
      int position, UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    String id = UserManagementResponse.vehicleList[position].ID;
    _progressDialog.show();
    restClient.deleteVehicle(id, societyId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        UserManagementResponse.vehicleList.removeAt(position);
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
    });
  }
}
