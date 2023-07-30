import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/MyComplexResponse.dart';
import 'package:societyrun/Models/VehicleDirectory,.dart';
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
    return DirectoryState();
  }
}

class DirectoryState extends State<BaseDirectory> {
  final TextEditingController _searchQuery = TextEditingController();
  var societyId, flat, block;

  bool isNeighbours = false;
  bool isCommittee = false;
  bool isEmergency = false;
  bool isVehicle = false;

  List<VehicleDirectory> searchList = [];

  @override
  void initState() {
    super.initState();
    if (widget.directory.directoryType == 'Neighbours') {
      isNeighbours = true;
      isCommittee = false;
      isEmergency = false;
      isVehicle = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MyComplexResponse>(context, listen: false)
            .getNeighboursDirectoryData()
            .then((value) {
          // _progressDialog!.dismiss();
        });
      });
    }

    if (widget.directory.directoryType == 'Committee') {
      isCommittee = true;
      isNeighbours = false;
      isEmergency = false;
      isVehicle = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MyComplexResponse>(context, listen: false)
            .getCommitteeDirectoryData()
            .then((value) {});
      });
    }
    if (widget.directory.directoryType == 'Emergency') {
      isCommittee = false;
      isNeighbours = false;
      isEmergency = true;
      isVehicle = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MyComplexResponse>(context, listen: false)
            .getEmergencyDirectoryData()
            .then((value) {});
      });
    }
    if (widget.directory.directoryType == 'Vehicle') {
      isCommittee = false;
      isNeighbours = false;
      isEmergency = false;
      isVehicle = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MyComplexResponse>(context, listen: false)
            .getVehicleDirectoryData()
            .then((value) {
          searchList = Provider.of<MyComplexResponse>(context, listen: false)
              .vehicleList;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyComplexResponse>.value(
        value: Provider.of(context),
        child: Consumer<MyComplexResponse>(builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.veryLightGray,
              //resizeToAvoidBottomPadding: false,
              appBar: CustomAppBar(
                title: widget.directory.directoryType! +
                    ' ' +
                    AppLocalizations.of(context).translate('directory'),
              ),
              body: getDirectoryLayout(value),
            ),
          );
        }));
  }

  Widget getDirectoryLayout(MyComplexResponse value) {
    print('getDirectoryLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getDirectoryListDataLayout(value),
        getSearchBarLayout(value),
      ],
    );
  }

  //search vehicle bar
  Widget getSearchBarLayout(MyComplexResponse myComplexResponse) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(left: 8, right: 8),
        child: TextField(
          controller: _searchQuery,
          onChanged: (value) => _onVehicleSearch(myComplexResponse),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: GlobalVariables.grey,
            ),
            hintText: AppLocalizations.of(context).translate('search'),
            hintStyle: TextStyle(
              color: GlobalVariables.grey,
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: GlobalVariables.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  _onVehicleSearch(MyComplexResponse value) {
    //search by vehicle

    List<VehicleDirectory> tempSearchList = [];

    if (_searchQuery.text.isNotEmpty) {
      for (int i = 0; i < searchList.length; i++) {
        if (searchList[i]
            .VEHICLE_NO!
            .toLowerCase()
            .contains(_searchQuery.text.toLowerCase())) {
          tempSearchList.add(searchList[i]);
        }
      }
      searchList = tempSearchList;
    } else {
      searchList = value.vehicleList;
    }
    setState(() {});
  }

  getDirectoryListDataLayout(MyComplexResponse value) {
    int length = 0;

    if (isNeighbours) length = value.neighbourList.length;

    if (isCommittee) length = value.committeeList.length;

    if (isEmergency) length = value.emergencyList.length;

    if (isVehicle) length = searchList.length;

    return Container(
      margin: EdgeInsets.only(top: isVehicle ? 72 : 8),
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
    String? name = '',
        field = '',
        address = '',
        permission = '',
        flat = '',
        callNumber = '',
        emailId = '';
    if (widget.directory.directoryType == 'Committee') {
      name = value.committeeList[position].NAME! == null
          ? ''
          : value.committeeList[position].NAME!;

      field = value.committeeList[position].POST! == null
          ? ''
          : value.committeeList[position].POST!;

      flat = value.committeeList[position].FLAT == null ||
              value.committeeList[position].BLOCK == null
          ? ''
          : value.committeeList[position].BLOCK! +
              ' ' +
              value.committeeList[position].FLAT!;

      if (!AppSocietyPermission.isSocHideCommitteeContactPaidPermission) {
        value.committeeList[position].EMAIL!.length != 0
            ? email = true
            : email = false;

        value.committeeList[position].PHONE!.length != 0
            ? phone = true
            : phone = false;

        if (phone) callNumber = value.committeeList[position].PHONE!;

        if (email) emailId = value.committeeList[position].EMAIL!;
      }
    }

    if (widget.directory.directoryType == 'Neighbours') {
      name = value.neighbourList[position].NAME! == null
          ? ''
          : value.neighbourList[position].NAME!;

      field = value.neighbourList[position].TYPE! == null
          ? ''
          : value.neighbourList[position].TYPE!;

      flat = value.neighbourList[position].FLAT == null ||
              value.neighbourList[position].BLOCK == null
          ? ''
          : value.neighbourList[position].BLOCK! +
              ' ' +
              value.neighbourList[position].FLAT!;

      if (!AppSocietyPermission.isSocHideContactPermission) {
        permission = value.neighbourList[position].PERMISSIONS!;
        if (value.neighbourList[position].Phone != null) {
          if (permission.contains('memberPhone')) {
            phone = true;
          } else {
            phone = false;
          }

          if (phone) callNumber = value.neighbourList[position].Phone!;
        }
      }
    }

    if (widget.directory.directoryType == 'Emergency') {
      name = value.emergencyList[position].Name == null
          ? ''
          : value.emergencyList[position].Name!;

      address = value.emergencyList[position].Address == null
          ? ''
          : value.emergencyList[position].Address!;

      field = value.emergencyList[position].Category == null
          ? ''
          : value.emergencyList[position].Category!;

      value.emergencyList[position].Contact_No!.length != 0
          ? phone = true
          : phone = false;

      if (phone) callNumber = value.emergencyList[position].Contact_No!;
    }

    if (widget.directory.directoryType == 'Vehicle') {
      name = value.vehicleList[position].VEHICLE_NO ?? '';

      field = value.vehicleList[position].MODEL == null
          ? ''
          : value.vehicleList[position].MODEL!;

      flat = value.vehicleList[position].FLAT == null ||
              value.vehicleList[position].BLOCK == null
          ? ''
          : value.vehicleList[position].BLOCK! +
              ' ' +
              value.vehicleList[position].FLAT!;

      value.vehicleList[position].INTERCOM!.length != 0
          ? phone = true
          : phone = false;

      if (phone) callNumber = value.vehicleList[position].INTERCOM ?? '';
      return getVehicleRecentTransactionListItemLayout(searchList[position]);
    }

    return widget.directory.directoryType != 'Emergency'
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
                                launch("tel://" + callNumber!);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: AppIcon(
                                  Icons.call,
                                  iconColor: GlobalVariables.primaryColor,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                !isEmergency ? Divider() : Container(),
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
                                iconColor: GlobalVariables.secondaryColor,
                              ),
                            ),
                          )
                        : SizedBox(
                            // width: 24,height: 24,
                            ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
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
                                launch("tel://" + callNumber!);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: AppIcon(
                                  Icons.call,
                                  iconColor: GlobalVariables.primaryColor,
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
                  child: secondaryText(
                    address,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
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

  getVehicleRecentTransactionListItemLayout(VehicleDirectory directory) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  getIconForVehicle(directory.WHEEL ?? ''),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: primaryText(
                        directory.VEHICLE_NO ?? '',
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: secondaryText(
                          '${directory.BLOCK} - ${directory.FLAT}',
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
}
