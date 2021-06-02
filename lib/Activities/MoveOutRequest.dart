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

class BaseMoveOutRequest extends StatefulWidget {

  BaseMoveOutRequest();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MoveOutRequestState();
  }
}

class MoveOutRequestState extends BaseStatefulState<BaseMoveOutRequest>
    with SingleTickerProviderStateMixin {
  //TabController _tabController;

/*
  var userId = "", name = "", photo = "", societyId = "", flat = "", block = "";
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
    Provider.of<UserManagementResponse>(context,listen: false).getMoveOutRequest();
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
                  AppLocalizations.of(context).translate('move_out_request'),
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getMoveOutRequestLayout(value),
            ),
          );
        },
      ),
    );
  }

  getMoveOutRequestLayout(UserManagementResponse value) {
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
               value.moveOutRequestList.length>0 ? getMoveOutRequestListDataLayout(value): GlobalFunctions.loadingWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMoveOutRequestListDataLayout(UserManagementResponse value) {
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
                  itemCount: value.moveOutRequestList.length,
                  itemBuilder: (context, position) {
                    return getMoveOutRequestListItemLayout(position,value);
                  }, //  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                )),
          ),
        ],
      ),
    );
  }

  getMoveOutRequestListItemLayout(int position, UserManagementResponse value) {
    List<Tenant> tenantDetailsList =  List<Tenant>.from(value.moveOutRequestList[position].tenant_name.map((i) => Tenant.fromJson(i)));

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
                                  child: text(tenantDetailsList[0].NAME,
                                      textColor:GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeLargeMedium,
                                      fontWeight: FontWeight.bold,
                                      textStyleHeight: 1.0
                                  ),
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
                                  tenantDetailsList[0].BLOCK + ' ' + tenantDetailsList[0].FLAT,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              child: AppIcon(Icons.date_range,iconColor: GlobalVariables.grey,),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Container(
                              child: text(
                                  GlobalFunctions.convertDateFormat(value.moveOutRequestList[position].AGREEMENT_TO, "dd-MM-yyyy"),
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.0
                              ),
                            ),
                          ],
                        ),
                        /*   Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: text(
                                  userType,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  textColor: GlobalVariables.black,
                                  textStyleHeight: 1.5
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: AppIcon(Icons.access_time,iconSize: GlobalVariables.textSizeSMedium,iconColor: GlobalVariables.grey,),
                                ),
                                SizedBox(width: 4,),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                                  child: text(
                                      '10 days',
                                      fontSize: GlobalVariables.textSizeSMedium,
                                      textColor: GlobalVariables.grey,
                                      textStyleHeight: 1.0
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),*/
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
