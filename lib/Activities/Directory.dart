import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/CommitteeDirectory.dart';
import 'package:societyrun/Models/EmergencyDirectory.dart';
import 'package:societyrun/Models/MyComplexResponse.dart';
import 'package:societyrun/Models/NeighboursDirectory.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseDirectory extends StatefulWidget {
  // String pageName;
  // BaseDirectory(this.pageName);

  DirectoryType directory;

  BaseDirectory(this.directory);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DirectoryState(directory);
  }
}

class DirectoryState extends State<BaseDirectory> {
  var societyId, flat, block;

  ProgressDialog _progressDialog;
  DirectoryType directory;

  DirectoryState(this.directory);

  bool isNeighbours = false;
  bool isCommittee = false;
  bool isEmergency = false;

  @override
  void initState() {
    super.initState();
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    if (directory.directoryType == 'Neighbours') {
      isNeighbours = true;
      isCommittee = false;
      isEmergency = false;
      _progressDialog.show();
      Provider.of<MyComplexResponse>(context, listen: false)
          .getNeighboursDirectoryData()
          .then((value) {
        _progressDialog.hide();
      });
    }

    if (directory.directoryType == 'Committee') {
      isCommittee = true;
      isNeighbours = false;
      isEmergency = false;
      /* value.committeeList.clear();
      value.emergencyList.clear();*/
      _progressDialog.show();
      Provider.of<MyComplexResponse>(context, listen: false)
          .getCommitteeDirectoryData()
          .then((value) {
        _progressDialog.hide();
      });
    }
    if (directory.directoryType == 'Emergency') {
      isCommittee = false;
      isNeighbours = false;
      isEmergency = true;
      /*  value.committeeList.clear();
      value.committeeList.clear();*/
      _progressDialog.show();
      Provider.of<MyComplexResponse>(context, listen: false)
          .getEmergencyDirectoryData()
          .then((value) {
        _progressDialog.hide();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<MyComplexResponse>.value(
        value: Provider.of(context),
        child: Consumer<MyComplexResponse>(builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.veryLightGray,
              //resizeToAvoidBottomPadding: false,
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
                  directory.directoryType +
                      ' ' +
                      AppLocalizations.of(context).translate('directory'),
                  textColor: GlobalVariables.white,
                ),
              ),
              body: getDirectoryLayout(value),
            ),
          );
        }));
  }

  getDirectoryLayout(MyComplexResponse value) {
    print('getDirectoryLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getDirectoryListDataLayout(value)
      ],
    );
  }

  getDirectoryListDataLayout(MyComplexResponse value) {
    int length = 0;

    if (isNeighbours) length = value.neighbourList.length;

    if (isCommittee) length = value.committeeList.length;

    if (isEmergency) length = value.emergencyList.length;

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: length,
                itemBuilder: (context, position) {
                  return getDirectoryDescListItemLayout(position, value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getDirectoryDescListItemLayout(int position, MyComplexResponse value) {
    bool phone = false, email = false;
    String name = '',
        field = '',
        address = '',
        permission = '',
        flat = '',
        callNumber = '',
        emailId = '';
    if (directory.directoryType == 'Committee') {
      name = value.committeeList[position].NAME == null
          ? ''
          : value.committeeList[position].NAME;

      field = value.committeeList[position].POST == null
          ? ''
          : value.committeeList[position].POST;

      flat = value.committeeList[position].FLAT == null ||
              value.committeeList[position].BLOCK == null
          ? ''
          : value.committeeList[position].BLOCK +
              ' ' +
              value.committeeList[position].FLAT;

      value.committeeList[position].EMAIL.length != 0
          ? email = true
          : email = false;

      value.committeeList[position].PHONE.length != 0
          ? phone = true
          : phone = false;

      if (phone) callNumber = value.committeeList[position].PHONE;

      if (email) emailId = value.committeeList[position].EMAIL;
    }

    if (directory.directoryType == 'Neighbours') {
      name = value.neighbourList[position].NAME == null
          ? ''
          : value.neighbourList[position].NAME;

      field = value.neighbourList[position].TYPE == null
          ? ''
          : value.neighbourList[position].TYPE;

      flat = value.neighbourList[position].FLAT == null ||
              value.neighbourList[position].BLOCK == null
          ? ''
          : value.neighbourList[position].BLOCK +
              ' ' +
              value.neighbourList[position].FLAT;

      permission = value.neighbourList[position].PERMISSIONS;
      if (value.neighbourList[position].Phone != null) {
        if (permission.contains('memberPhone')) {
          phone = true;
        } else {
          phone = false;
        }

        if (phone) callNumber = value.neighbourList[position].Phone;
      }
    }

    if (directory.directoryType == 'Emergency') {
      name = value.emergencyList[position].Name == null
          ? ''
          : value.emergencyList[position].Name;

      address = value.emergencyList[position].Address == null
          ? ''
          : value.emergencyList[position].Address;

      field = value.emergencyList[position].Name == null
          ? ''
          : value.emergencyList[position].Name;

      value.emergencyList[position].Contact_No.length != 0
          ? phone = true
          : phone = false;

      if (phone) callNumber = value.emergencyList[position].Contact_No;
    }

    return directory.directoryType != 'Emergency'
        ? AppContainer(
            isListItem: true,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    !isEmergency
                        ? Expanded(
                            child: Container(
                              child: primaryText(
                                flat,
                              ),
                            ),
                          )
                        : Container(),
                    phone
                        ? Flexible(
                            child: InkWell(
                              onTap: () {
                                print('callNumber : ' + callNumber.toString());
                                launch("tel://" + callNumber);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: AppIcon(
                                  Icons.call,
                                  iconColor: GlobalVariables.green,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                !isEmergency
                    ? Divider()
                    : Container(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: secondaryText(
                          name,
                         /* textColor: GlobalVariables.black,
                          fontSize: GlobalVariables.textSizeLargeMedium,
                          fontWeight: FontWeight.bold,*/
                        ),
                      ),
                    ),
                    email
                        ? InkWell(
                            onTap: () {
                              Uri _emailUri = Uri(
                                  scheme: 'mailto',
                                  path: emailId,
                                  queryParameters: {'subject': ''});
                              launch(_emailUri.toString());
                            },
                            child: Container(
                              alignment: Alignment.topRight,
                              child: AppIcon(
                                Icons.email,
                                iconColor: GlobalVariables.mediumGreen,
                              ),
                            ),
                          )
                        : SizedBox(
                            // width: 24,height: 24,
                            ),
                  ],
                ),
                SizedBox(height: 8,),
                Container(
                  alignment: Alignment.topLeft,
                  child: text(field,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeSmall),
                ),
              ],
            ),
          )
        : AppContainer(
           isListItem: true,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                       // margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: primaryText(
                          name,
                         /* textColor: GlobalVariables.black,
                          fontSize: GlobalVariables.textSizeLargeMedium,
                          fontWeight: FontWeight.bold,*/
                        ),
                      ),
                    ),
                    phone
                        ? Flexible(
                            child: InkWell(
                              onTap: () {
                                print('callNumber : ' + callNumber.toString());
                                launch("tel://" + callNumber);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: AppIcon(
                                  Icons.call,
                                  iconColor: GlobalVariables.green,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Divider(),
                Container(
                  alignment: Alignment.topLeft,
                  child: secondaryText(address,),
                ),
                SizedBox(height: 4,),
                Container(
                  alignment: Alignment.topLeft,
                  child: text(field,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeSmall),
                ),
              ],
            ),
          );
  }
}
