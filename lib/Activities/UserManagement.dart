import 'package:flutter/material.dart';
import 'package:societyrun/Activities/RegisterUser.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseUserManagement extends StatefulWidget {
  @override
  _BaseUserManagementState createState() => _BaseUserManagementState();
}

class _BaseUserManagementState extends BaseStatefulState<BaseUserManagement> {
  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context).translate('user'),
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getBaseUserLayout(),
            ));
  }

  getBaseUserLayout() {
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
                //    getSearchLayout(),
                getUserManagementLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getUserManagementLayout() {
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
              Container(
                padding: EdgeInsets.all(
                    16), // height: MediaQuery.of(context).size.height / 0.5,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: text('No of. Units',
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: text('19',
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeXXLarge,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.all(
                  16), // height: MediaQuery.of(context).size.height / 0.5,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>BaseRegisterUser()));
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('register_user'),
                                            textColor: GlobalVariables.grey,
                                            fontSize: GlobalVariables.textSizeSMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text('4',
                                            textColor: GlobalVariables.green,
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
                                color: GlobalVariables.black,
                              )),
                          Flexible(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: text(AppLocalizations.of(context).translate('active_user'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: text('3',
                                          textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeXXLarge,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.black,
                              )),
                          Flexible(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: text(AppLocalizations.of(context).translate('mobile_user'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: text('2',
                                          textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeXXLarge,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
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
                    color: GlobalVariables.white,
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
                              child: Container(
                                //color: GlobalVariables.lightGray,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: text(AppLocalizations.of(context).translate('rental_request'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: text('4',
                                          textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeXXLarge,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.black,
                              )),
                          Flexible(
                              flex: 1,
                              child: Container(

                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: text(AppLocalizations.of(context).translate('pending_request'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: text('3',
                                          textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeXXLarge,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              //TODO: Divider
                              height:100,
                              width: 4,
                              child: VerticalDivider(
                                color: GlobalVariables.black,
                              )),
                          Flexible(
                              flex: 1,
                              child: Container(
                                //color: GlobalVariables.lightGray,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: text(AppLocalizations.of(context).translate('move_out_request'),
                                          textColor: GlobalVariables.grey,
                                          fontSize: GlobalVariables.textSizeSMedium),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: text('2',
                                          textColor: GlobalVariables.green,
                                          fontSize: GlobalVariables.textSizeXXLarge,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
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
