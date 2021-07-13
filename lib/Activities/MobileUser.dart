import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/StaffCategory.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
import 'package:societyrun/Activities/StaffListPerCategory.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/PollOption.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseMobileUser extends StatefulWidget {

  BaseMobileUser();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MobileUserState();
  }
}

class MobileUserState extends BaseStatefulState<BaseMobileUser>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '',userType='';

//var photo="";

  List<String> inviteUserList = List<String>();
  ProgressDialog _progressDialog;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    getSharedPreferenceData();
    _handleTabSelection();

  }
  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);

    // TODO: implement build
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context,value,child){
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
                  AppLocalizations.of(context).translate('mobile_user'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: TabBarView(controller: _tabController, children: <Widget>[
               getMobileUserLayout(value),
                getUnMobileUserLayout(value),
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
              text: AppLocalizations.of(context).translate('mobile_user'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('not_mobile_user'),
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

  getMobileUserLayout(UserManagementResponse value) {
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
               value.mobileUserList.length==0 ? GlobalFunctions.loadingWidget(context) :getMobileUserListDataLayout(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMobileUserListDataLayout(UserManagementResponse value) {
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
                  itemCount: value.mobileUserList.length,
                  itemBuilder: (context, position) {
                    return getMobileUserListItemLayout(position,value);
                  }, //  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                )),
          ),
        ],
      ),
    );
  }

  getMobileUserListItemLayout(int position, UserManagementResponse userManagementResponse) {

    print('value.activeUserList : '+userManagementResponse.mobileUserList.length.toString());
    var inDays = GlobalFunctions.getDaysFromDate(GlobalFunctions.getCurrentDate("yyyy-MM-dd"),
        GlobalFunctions.convertDateFormat(userManagementResponse.mobileUserList[position].LAST_LOGIN, "yyyy-MM-dd")
    );
    if(inDays.toString()=='0'){
      inDays = 'Today';
    }else{
      inDays = inDays.toString()+ ' days';
    }

    return AppContainer(
      child: Column(
        children: <Widget>[
          Container(
            //padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 5),
                  // padding: EdgeInsets.all(20),
                  // alignment: Alignment.center,
                  /* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25)),*/
                    child: photo.isEmpty
                        ? AppAssetsImage(
                      GlobalVariables.componentUserProfilePath,
                      imageWidth: 30.0,
                      imageHeight: 30.0,
                      borderColor: GlobalVariables.grey,
                      borderWidth: 1.0,
                      fit: BoxFit.cover,
                      radius: 15.0,
                    )
                        : AppNetworkImage(
                      photo,
                      imageWidth: 30.0,
                      imageHeight: 30.0,
                      borderColor: GlobalVariables.grey,
                      borderWidth: 1.0,
                      fit: BoxFit.cover,
                      radius: 15.0,
                    )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              //  color:GlobalVariables.grey,
                              child: text(userManagementResponse.mobileUserList[position].NAME,
                                  textColor: GlobalVariables.green,
                                  fontSize: GlobalVariables.textSizeLargeMedium,
                                  fontWeight: FontWeight.bold,
                                  textStyleHeight: 1.0
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              decoration: boxDecoration(
                                bgColor: GlobalVariables.skyBlue,
                                color: GlobalVariables.white,
                                radius: GlobalVariables.textSizeVerySmall,
                              ),
                              child: text(
                                  userManagementResponse.mobileUserList[position].BLOCK + ' ' + userManagementResponse.mobileUserList[position].FLAT,
                                  fontSize: GlobalVariables.textSizeVerySmall,
                                  textColor: GlobalVariables.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: text(
                              userManagementResponse.mobileUserList[position].MOBILE,
                              fontSize: GlobalVariables.textSizeSMedium,
                              textColor: GlobalVariables.black,
                              textStyleHeight: 1.0
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: text(
                                  userManagementResponse.mobileUserList[position].TYPE,
                                  fontSize: GlobalVariables.textSizeSmall,
                                  textColor: GlobalVariables.grey,
                                  textStyleHeight: 1.0
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: AppIcon(Icons.access_time,iconSize: GlobalVariables.textSizeSmall,iconColor: GlobalVariables.grey,),
                                ),
                                SizedBox(width: 4,),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                                  child: text(
                                      userManagementResponse
                                          .mobileUserList[position]
                                          .LAST_LOGIN ==
                                          '0000-00-00 00:00:00'
                                          ? 'Never' :
                                      inDays.toString(),
                                      fontSize: GlobalVariables.textSizeSmall,
                                      textColor: GlobalVariables.grey,
                                      textStyleHeight: 1.0
                                  ),
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


  getUnMobileUserLayout(UserManagementResponse value) {
   
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
                value.notMobileUserList.length==0 ? GlobalFunctions.loadingWidget(context) : getUnMobileUserListDataLayout(value),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AppButton(textContent: 'Invite', onPressed: (){
                      _progressDialog.show();
                      Provider.of<UserManagementResponse>(context,listen: false).sendInviteAPI(inviteUserList).then((value) {

                        _progressDialog.hide();
                        if(value.status){
                          Navigator.of(context).pop();
                        }

                      });

                    }),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUnMobileUserListDataLayout(UserManagementResponse value) {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 15, 10, 0),
      //padding: EdgeInsets.all(20), // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: value.notMobileUserList.length,
            itemBuilder: (context, position) {
              return getUnMobileUserListItemLayout(position,value);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    );
  }

  getUnMobileUserListItemLayout(int position, UserManagementResponse userManagementResponse) {

    return InkWell(
      onTap: () async {
        if(inviteUserList.contains(userManagementResponse.notMobileUserList[position].USER_ID)){
          inviteUserList.remove(userManagementResponse.notMobileUserList[position].USER_ID);
        }else{
          inviteUserList.add(userManagementResponse.notMobileUserList[position].USER_ID);
        }

        print('inviteUserList : '+inviteUserList.toString());
        setState(() {

        });
      },
      child: AppContainer(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: inviteUserList.contains(userManagementResponse.notMobileUserList[position].USER_ID)
                          ? GlobalVariables.green
                          : GlobalVariables.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: inviteUserList.contains(userManagementResponse.notMobileUserList[position].USER_ID)
                            ? GlobalVariables.green
                            : GlobalVariables.mediumGreen,
                        width: 2.0,
                      )),
                  child: AppIcon(
                    Icons.check,
                    iconColor: inviteUserList.contains(userManagementResponse.notMobileUserList[position].USER_ID)
                        ? GlobalVariables.white
                        : GlobalVariables.transparent,
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          //  color:GlobalVariables.grey,
                          child: text(userManagementResponse.notMobileUserList[position].NAME,
                              textColor:GlobalVariables.green,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.bold,
                              textStyleHeight: 1.0
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Container(
                              child: text(
                                  userManagementResponse.notMobileUserList[position].BLOCK+' '+userManagementResponse.notMobileUserList[position].FLAT +' - ',
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.0
                              ),
                            ),
                            //SizedBox(width: 8,),
                            Container(
                              child: text(
                                  userManagementResponse.notMobileUserList[position].TYPE,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.0
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      )
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
              Provider.of<UserManagementResponse>(context,listen: false).getUseTypeList("Mobile user");
            }
            break;
          case 1:
            {
              Provider.of<UserManagementResponse>(context,listen: false).getUseTypeList("Not Mobile user");
            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }


  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    societyId = await GlobalFunctions.getSocietyId();
    userType = await GlobalFunctions.getUserType();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    setState(() {});
  }
}
