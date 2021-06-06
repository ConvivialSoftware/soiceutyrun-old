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
    extends BaseStatefulState<BaseMemberPendingRequest>
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
        .getPendingRequest();
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
                value.pendingRequestList.length > 0
                    ? getMemberPendingRequestListDataLayout(value)
                    : GlobalFunctions.loadingWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMemberPendingRequestListDataLayout(UserManagementResponse value) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 12, 10, 0),
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
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                      textColor: GlobalVariables.green,
                                      fontSize:
                                          GlobalVariables.textSizeLargeMedium,
                                      fontWeight: FontWeight.bold,
                                      textStyleHeight: 1.0),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: boxDecoration(
                                bgColor: GlobalVariables.skyBlue,
                                color: GlobalVariables.white,
                                radius: GlobalVariables.textSizeNormal,
                              ),
                              child: text(
                                value.pendingRequestList[position].BLOCK +
                                    ' ' +
                                    value.pendingRequestList[position].FLAT,
                                fontSize: GlobalVariables.textSizeSMedium,
                                textColor: GlobalVariables.white,
                                textStyleHeight: 1.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: text(
                                  value.pendingRequestList[position].TYPE,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.5),
                            ),
                          ],
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
                                                  borderRadius: BorderRadius.circular(25.0)),
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
                                                                  textColor: GlobalVariables.green,
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
                                                                  textColor: GlobalVariables.green,
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
                                    fontSize: GlobalVariables.textSizeMedium,
                                    fontWeight: FontWeight.bold,
                                    textColor: GlobalVariables.green),
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
                                                borderRadius: BorderRadius.circular(25.0)),
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
                                                                textColor: GlobalVariables.green,
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
                                                                textColor: GlobalVariables.green,
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
                                    fontSize: GlobalVariables.textSizeMedium,
                                    fontWeight: FontWeight.bold,
                                    textColor: GlobalVariables.green),
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
          ),
        ],
      ),
    );
  }
}
