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

    if (directory.directoryType == 'Neighbours') {
      isNeighbours = true;
      isCommittee = false;
      isEmergency = false;
      /* value.committeeList.clear();
      value.emergencyList.clear();*/
      Provider.of<MyComplexResponse>(context, listen: false).getNeighboursDirectoryData();
    }

    if (directory.directoryType == 'Committee') {
      isCommittee = true;
      isNeighbours = false;
      isEmergency = false;
      /* value.committeeList.clear();
      value.emergencyList.clear();*/
      Provider.of<MyComplexResponse>(context, listen: false)
          .getCommitteeDirectoryData();
    }
    if (directory.directoryType == 'Emergency') {
      isCommittee = false;
      isNeighbours = false;
      isEmergency = true;
      /*  value.committeeList.clear();
      value.committeeList.clear();*/
      Provider.of<MyComplexResponse>(context, listen: false)
          .getEmergencyDirectoryData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    // TODO: implement build
    return ChangeNotifierProvider<MyComplexResponse>.value(
        value: Provider.of(context),
        child: Consumer<MyComplexResponse>(builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              //resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                backgroundColor: GlobalVariables.green,
                centerTitle: true,
                leading: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: GlobalVariables.white,
                  ),
                ),
                title: Text(
                  directory.directoryType +
                      ' ' +
                      AppLocalizations.of(context).translate('directory'),
                  style: TextStyle(color: GlobalVariables.white),
                ),
              ),
              body: getDirectoryLayout(value),
            ),
          );
        }));
  }

  getDirectoryLayout(MyComplexResponse value) {
    print('getDirectoryLayout Tab Call');
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
                value.isLoading?  GlobalFunctions.loadingWidget(context) :  getDirectoryListDataLayout(value)
              ],
            ),
          ),
        ],
      ),
    );
  }

  getDirectoryListDataLayout(MyComplexResponse value) {
    int length = 0;

    if (isNeighbours) length = value.neighbourList.length;

    if (isCommittee) length =value.committeeList.length;

    if (isEmergency) length = value.emergencyList.length;

    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: length,
                itemBuilder: (context, position) {
                  return getDirectoryDescListItemLayout(position,value);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }

  getDirectoryDescListItemLayout(int position,MyComplexResponse value) {
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

      value.committeeList[position].EMAIL.length != 0 ? email = true : email = false;

      value.committeeList[position].PHONE.length != 0 ? phone = true : phone = false;

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
        ? Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: GlobalVariables.white),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    !isEmergency
                        ? Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 5, 5, 0),
                              child: Text(
                                flat,
                                style: TextStyle(
                                    color: GlobalVariables.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
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
                                //color: GlobalVariables.lightGray,
                                // color: GlobalVariables.black,
                                // height: 10,
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                child: Icon(
                                  Icons.call,
                                  color: GlobalVariables.mediumGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                !isEmergency
                    ? Container(
                        height: 1,
                        color: GlobalVariables.lightGray,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Divider(
                          height: 1,
                        ),
                      )
                    : Container(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: Text(
                          name,
                          style: TextStyle(
                              color: GlobalVariables.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    email
                        ? Flexible(
                            child: InkWell(
                              onTap: () {
                                Uri _emailUri = Uri(
                                    scheme: 'mailto',
                                    path: emailId,
                                    queryParameters: {'subject': ''});
                                launch(_emailUri.toString());
                              },
                              child: Container(
                                // color: GlobalVariables.lightGray,
                                // color: GlobalVariables.black,
                                // height: 10,
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                child: Icon(
                                  Icons.email,
                                  color: GlobalVariables.mediumGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            // width: 24,height: 24,
                            ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(10, 5, 5, 5),
                  child: Text(
                    field,
                    style: TextStyle(
                      color: GlobalVariables.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: MediaQuery.of(context).size.width / 1.1,
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: GlobalVariables.white),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: Text(
                          name,
                          style: TextStyle(
                              color: GlobalVariables.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
                                //color: GlobalVariables.lightGray,
                                // color: GlobalVariables.black,
                                // height: 10,
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                child: Icon(
                                  Icons.call,
                                  color: GlobalVariables.mediumGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                        child: Text(
                          address,
                          style: TextStyle(
                              color: GlobalVariables.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(10, 5, 5, 5),
                  child: Text(
                    field,
                    style: TextStyle(
                      color: GlobalVariables.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
