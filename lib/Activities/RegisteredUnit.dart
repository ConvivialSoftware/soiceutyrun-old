import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNewMemberByAdmin.dart';
import 'package:societyrun/Activities/StaffCategory.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/Activities/UnitDetails.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseRegisteredUnit extends StatefulWidget {
  BaseRegisteredUnit();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RegisteredUnitState();
  }
}

class RegisteredUnitState extends BaseStatefulState<BaseRegisteredUnit>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  ProgressDialog _progressDialog;

  /* var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';
*/

  var photo = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    //getSharedPreferenceData();
    _handleTabSelection();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: GlobalVariables.green,
                centerTitle: true,
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
                  AppLocalizations.of(context).translate('registered_unit'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: TabBarView(controller: _tabController, children: <Widget>[
                BaseUnitDetails(false),
                getUnRegisteredUnitLayout(value),
                //getHelperLayout(),
              ]),
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
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('registered_unit'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('unregister_user'),
            ),
          )
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

  getRegisteredUnitLayout(UserManagementResponse value) {
    // print('MyTicketLayout Tab Call');
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
                    context, 150.0),
                value.registerList.length == 0
                    ? GlobalFunctions.loadingWidget(context)
                    : getRegisteredUnitListDataLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getRegisteredUnitListDataLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 15, 10, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.registerList.length,
                      itemBuilder: (context, position) {
                        return getRegisteredUnitListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ],
      ),
    );
  }

  getRegisteredUnitListItemLayout(
      int position, UserManagementResponse userManagementResponse) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    // padding: EdgeInsets.all(20),
                    // alignment: Alignment.center,
                    /* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),*/
                    child: photo.isEmpty
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
                            photo,
                            imageWidth: 60.0,
                            imageHeight: 60.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 30.0,
                          )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  //  color:GlobalVariables.grey,
                                  child: text(
                                      userManagementResponse
                                          .registerList[position].NAME,
                                      textColor: GlobalVariables.green,
                                      fontSize:
                                          GlobalVariables.textSizeLargeMedium,
                                      fontWeight: FontWeight.bold,
                                      textStyleHeight: 1.0),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  child: AppIcon(
                                    userManagementResponse
                                            .registerList[position]
                                            .gcm_id
                                            .isNotEmpty
                                        ? Icons.phone_android
                                        : Icons.language,
                                    iconColor: GlobalVariables.mediumGreen,
                                    iconSize: GlobalVariables.textSizeNormal,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
                              decoration: boxDecoration(
                                bgColor: GlobalVariables.skyBlue,
                                color: GlobalVariables.white,
                                radius: GlobalVariables.textSizeNormal,
                              ),
                              child: text(
                                  userManagementResponse
                                          .registerList[position].BLOCK +
                                      ' ' +
                                      userManagementResponse
                                          .registerList[position].FLAT,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.white,
                                  fontWeight: FontWeight.bold,
                                  textStyleHeight: 0.0),
                            ),
                          ],
                        ),
                        Container(
                          child: text(
                              userManagementResponse
                                  .registerList[position].MOBILE,
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.black,
                              textStyleHeight: 1.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: text(
                                  userManagementResponse
                                      .registerList[position].TYPE,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.5),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: AppIcon(
                                    Icons.access_time,
                                    iconSize: GlobalVariables.textSizeSMedium,
                                    iconColor: GlobalVariables.grey,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                                  child: text(
                                      userManagementResponse
                                                  .registerList[position]
                                                  .LAST_LOGIN ==
                                              '0000-00-00 00:00:00'
                                          ? 'Never'
                                          : GlobalFunctions.getDaysFromDate(
                                                      GlobalFunctions
                                                          .getCurrentDate(
                                                              "yyyy-MM-dd"),
                                                      GlobalFunctions
                                                          .convertDateFormat(
                                                              userManagementResponse
                                                                  .registerList[
                                                                      position]
                                                                  .LAST_LOGIN,
                                                              "yyyy-MM-dd"))
                                                  .toString() +
                                              ' days',
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      textColor: GlobalVariables.grey,
                                      textStyleHeight: 1.0),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUnRegisteredUnitLayout(UserManagementResponse value) {
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
                    context, 180.0),
                value.unRegisterList.length == 0
                    ? GlobalFunctions.loadingWidget(context)
                    : getUnRegisteredUnitListDataLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUnRegisteredUnitListDataLayout(
      UserManagementResponse userManagementResponse) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      //padding: EdgeInsets.all(10),
      // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: userManagementResponse.unRegisterList.length,
                itemBuilder: (context, position) {
                  return getUnRegisteredUnitListItemLayout(
                      position, userManagementResponse);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getUnRegisteredUnitListItemLayout(
      int position, UserManagementResponse userManagementResponse) {
    return InkWell(
      onTap: () async {},
      child: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width / 1.1,
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: text(
                      userManagementResponse.unRegisterList[position].BLOCK +
                          ' ' +
                          userManagementResponse.unRegisterList[position].FLAT,
                      fontSize: GlobalVariables.textSizeMedium,
                      fontWeight: FontWeight.w500),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseAddNewMemberByAdmin(
                                userManagementResponse
                                    .unRegisterList[position].BLOCK,
                                userManagementResponse
                                    .unRegisterList[position].FLAT)));
                  },
                  child: Row(
                    children: [
                      Container(
                        child: AppIcon(
                          Icons.add,
                          iconSize: GlobalVariables.textSizeLargeMedium,
                          iconColor: GlobalVariables.green,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: text('Register',
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            textColor: GlobalVariables.green),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTabSelection() {
    _callAPI(_tabController.index);
  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              Provider.of<UserManagementResponse>(context, listen: false)
                  .getUseTypeList("Registered user");
            }
            break;
          case 1:
            {
              Provider.of<UserManagementResponse>(context, listen: false)
                  .getUseTypeList("Not yet Registered");
            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }
}
