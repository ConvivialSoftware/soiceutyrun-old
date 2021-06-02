import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/ActiveUser.dart';
import 'package:societyrun/Activities/MemberPendingRequest.dart';
import 'package:societyrun/Activities/MobileUser.dart';
import 'package:societyrun/Activities/MoveOutRequest.dart';
import 'package:societyrun/Activities/RegisteredUnit.dart';
import 'package:societyrun/Activities/RentalRequest.dart';
import 'package:societyrun/Activities/UnitDetails.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseUserManagement extends StatefulWidget {
  @override
  _BaseUserManagementState createState() => _BaseUserManagementState();
}

class _BaseUserManagementState extends BaseStatefulState<BaseUserManagement> {

  @override
  void initState() {
    super.initState();
    Provider.of<UserManagementResponse>(context,listen: false).getUserManagementDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserManagementResponse>.value(
        value: Provider.of<UserManagementResponse>(context),
      child: Consumer<UserManagementResponse>(builder: (context,value,child){
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
                  AppLocalizations.of(context).translate('user_management'),
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getBaseUserLayout(value),
            ));
      }),
    );
  }

  getBaseUserLayout(UserManagementResponse userManagementResponse) {
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
                //GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
                //    getSearchLayout(),
                userManagementResponse.isLoading ?GlobalFunctions.loadingWidget(context) : getUserManagementLayout(userManagementResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUserManagementLayout(UserManagementResponse userManagementResponse) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 40, 0, 40),
        padding: EdgeInsets.all(10),
        // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 16,),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseUnitDetails(true)));
                },
                child: Container(
                  padding: EdgeInsets.all(
                      16), // height: MediaQuery.of(context).size.height / 0.5,
                  decoration: BoxDecoration(
                      color: GlobalVariables.lightOrange,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: text('No of. Units',
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: text(userManagementResponse.noOfUnits,
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeXXLarge,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.all(
                  16), // height: MediaQuery.of(context).size.height / 0.5,
                decoration: BoxDecoration(
                    color: GlobalVariables.lightCyan,
                    borderRadius: BorderRadius.circular(15)),

                child: Column(
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseRegisteredUnit()));
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('registered_unit'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.registerUser,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.white,
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseActiveUser()));
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('active_user'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.activeUser,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.white,
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseMobileUser()));
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('mobile_user'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.mobileUser,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.all(
                    16), // height: MediaQuery.of(context).size.height / 0.5,
                decoration: BoxDecoration(
                    color: GlobalVariables.lightPurple,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseRentalRequest()));
                                },
                                child: Container(
                                  //color: GlobalVariables.lightGray,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('rental_request'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.rentalRequest,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.white,
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseMemberPendingRequest()));
                                },
                                child: Container(

                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('pending_request'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.pendingRequest,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.white,
                              )),
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseMoveOutRequest()));
                                },
                                child: Container(
                                  //color: GlobalVariables.lightGray,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('move_out_request'),
                                            textColor: GlobalVariables.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(userManagementResponse.moveOutRequest,
                                            textColor: GlobalVariables.white,
                                            fontSize: GlobalVariables.textSizeXXLarge,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
