import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:ndialog/ndialog.dart';
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

class BaseMemberPendingRequest extends StatefulWidget {
  BaseMemberPendingRequest();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MemberPendingRequestState();
  }
}

class MemberPendingRequestState
    extends State<BaseMemberPendingRequest>
    with SingleTickerProviderStateMixin {
  //TabController _tabController;

  /*var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
  var email = '', phone = '', consumerId = '', societyName = '',userType='';
*/

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(length: 2, vsync: this);
    //_tabController.addListener(_handleTabSelection);
    //  getSharedPreferenceData();
    //  _handleTabSelection();
    Provider.of<UserManagementResponse>(context, listen: false)
        .getPendingMemberRequest();
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
              backgroundColor: GlobalVariables.veryLightGray,
              appBar: AppBar(
                backgroundColor: GlobalVariables.primaryColor,
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
                  AppLocalizations.of(context).translate('pending_request'),
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getMemberPendingRequestLayout(value),
            ),
          );
        },
      ),
    );
  }

  getMemberPendingRequestLayout(UserManagementResponse value) {
    // print('MyTicketLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
            context, 150.0),
        !value.isLoading
            ? getMemberPendingRequestListDataLayout(value)
            : GlobalFunctions.loadingWidget(context),
      ],
    );
  }

  getMemberPendingRequestListDataLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                0, 8, 0, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.pendingRequestList.length,
                      itemBuilder: (context, position) {
                        return getMemberPendingRequestListItemLayout(
                            position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ],
      ),
    );
  }

  getMemberPendingRequestListItemLayout(
      int position, UserManagementResponse value) {
    return AppContainer(
      isListItem: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 5),
             //padding: EdgeInsets.all(20),
             alignment: Alignment.center,
            /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25)),*/
              child: value.pendingRequestList[position].PROFILE_PHOTO.isEmpty
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
                value.pendingRequestList[position].PROFILE_PHOTO,
                imageWidth: 30.0,
                imageHeight: 30.0,
                borderColor: GlobalVariables.grey,
                borderWidth: 1.0,
                fit: BoxFit.cover,
                radius: 15.0,
              )),
          SizedBox(width: 8,),
          Expanded(
            child: Container(
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
                                value.pendingRequestList[position].NAME,
                                textColor: GlobalVariables.primaryColor,
                                fontSize:
                                GlobalVariables.textSizeMedium,
                                fontWeight: FontWeight.bold,
                                textStyleHeight: 1.0),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        decoration: boxDecoration(
                          bgColor: GlobalVariables.skyBlue,
                          color: GlobalVariables.white,
                          radius: GlobalVariables.textSizeSmall,
                        ),
                        child: text(
                          value.pendingRequestList[position].BLOCK +
                              ' ' +
                              value.pendingRequestList[position].FLAT,
                          fontSize: GlobalVariables.textSizeSmall,
                          textColor: GlobalVariables.white,
                          textStyleHeight: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  value.pendingRequestList[position].EMAIL.isNotEmpty? Container(
                    child: text(
                        value.pendingRequestList[position].EMAIL,
                        fontSize: GlobalVariables.textSizeSMedium,
                        textColor: GlobalVariables.black,
                        textStyleHeight: 1.5),
                  ) : SizedBox(),
                  value.pendingRequestList[position].MOBILE.isNotEmpty ? Container(
                    child: text(
                        value.pendingRequestList[position].MOBILE,
                        fontSize: GlobalVariables.textSizeSMedium,
                        textColor: GlobalVariables.black,
                        textStyleHeight: 1.5),
                  ):SizedBox(),
                  Container(
                    child: text(
                        value.pendingRequestList[position].TYPE,
                        fontSize: GlobalVariables.textSizeSmall,
                        textColor: GlobalVariables.grey,
                        textStyleHeight: 1.5),
                  ),
                  divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0)),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: text(
                                                    AppLocalizations.of(context).translate('sure_cancel'),
                                                    fontSize: GlobalVariables.textSizeLargeMedium,
                                                    textColor: GlobalVariables.black,
                                                    fontWeight: FontWeight.bold),
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
                                                          _progressDialog.show();
                                                          Provider.of<UserManagementResponse>(context,listen: false).deleteFamilyMember(value.pendingRequestList[position].ID).then((value) {

                                                            _progressDialog.hide();
                                                            GlobalFunctions.showToast(value.message);
                                                            print('value : '+value.toString());

                                                          });
                                                        },
                                                        child: text(
                                                            AppLocalizations.of(context).translate('yes'),
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
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                    );
                                  }));
                        },
                        child: Container(
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('cancel'),
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold,
                              textColor: GlobalVariables.primaryColor),
                        ),
                      ),
                      InkWell(
                        onTap: (){

                          showDialog(
                              context: context,
                              builder: (BuildContext context) => StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0)),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: text(
                                                    AppLocalizations.of(context).translate('sure_approve'),
                                                    fontSize: GlobalVariables.textSizeLargeMedium,
                                                    textColor: GlobalVariables.black,
                                                    fontWeight: FontWeight.bold),
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
                                                          _progressDialog.show();
                                                          Provider.of<UserManagementResponse>(context,listen: false).approvePendingRequest(value.pendingRequestList[position].ID).then((value) {

                                                            _progressDialog.hide();
                                                            GlobalFunctions.showToast(value.message);
                                                            print('value : '+value.toString());

                                                          });
                                                        },
                                                        child: text(
                                                            AppLocalizations.of(context).translate('yes'),
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
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                    );
                                  }));

                        },
                        child: Container(
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('Approve'),
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold,
                              textColor: GlobalVariables.primaryColor),
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
    );
  }
}
