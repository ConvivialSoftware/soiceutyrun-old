import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BroadcastResponse.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';

class BaseBroadcast extends StatefulWidget {
  @override
  _BaseBroadcastState createState() => _BaseBroadcastState();
}

class _BaseBroadcastState extends State<BaseBroadcast>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  String pageName;

  List<BroadcastSendTo> broadcastSendToList = List<BroadcastSendTo>();
  List<SMSTypes> smsTypesList = List<SMSTypes>();
  List<Hours> hoursList = List<Hours>();
  List<Minutes> minList = List<Minutes>();
  List<AMPM> ampmList = List<AMPM>();

  TextEditingController notificationSubject = TextEditingController();
  TextEditingController notificationDescription = TextEditingController();

  List<DropdownMenuItem<String>> _notificationSendToListItems =
      new List<DropdownMenuItem<String>>();
  String _notificationSendToSelectedItem;
  List<DropdownMenuItem<String>> _mailSendToListItems =
      new List<DropdownMenuItem<String>>();
  String _mailSendToSelectedItem;
  List<DropdownMenuItem<String>> _smsSendToListItems =
      new List<DropdownMenuItem<String>>();
  String _smsSendToSelectedItem;

  List<DropdownMenuItem<String>> _smsTypesListItems =
      new List<DropdownMenuItem<String>>();
  String _smsTypesSelectedItem;

  List<DropdownMenuItem<String>> _notificationFlatNoListItems =
      new List<DropdownMenuItem<String>>();
  String _notificationFlatNoSelectedItem;

  List<DropdownMenuItem<String>> _mailFlatNoListItems =
      new List<DropdownMenuItem<String>>();
  String _mailFlatNoSelectedItem;

  List<DropdownMenuItem<String>> _smsFlatNoListItems =
      new List<DropdownMenuItem<String>>();
  String _smsFlatNoSelectedItem;

  TextEditingController mailSubject = TextEditingController();
  TextEditingController mailDescription = TextEditingController();

  List<FlatMemberDetails> _notificationAssignFlatList =
      List<FlatMemberDetails>();
  List<FlatMemberDetails> _mailAssignFlatList = List<FlatMemberDetails>();
  List<FlatMemberDetails> _smsAssignFlatList = List<FlatMemberDetails>();

  // String notificationAttachmentFilePath;
  // String notificationAttachmentFileName;
  // String notificationAttachmentCompressFilePath;

  String mailAttachmentFilePath;
  String mailAttachmentFileName;
  String mailAttachmentCompressFilePath;

  ProgressDialog _progressDialog;

  bool isStoragePermission = false;

  List<DropdownMenuItem<String>> _smsHoursListItems =
      new List<DropdownMenuItem<String>>();
  String _smsHoursSelectedItem;

  List<DropdownMenuItem<String>> _smsMinListItems =
      new List<DropdownMenuItem<String>>();
  String _smsMinSelectedItem;

  List<DropdownMenuItem<String>> _smsAmPmListItems =
      new List<DropdownMenuItem<String>>();
  String _smsAmPmSelectedItem;

  String societyName,smsCredit='0',smsSent='0',smsBalance="0";

  List<DropdownMenuItem<String>> _smsHours2ListItems =
      new List<DropdownMenuItem<String>>();
  String _smsHours2SelectedItem;

  List<DropdownMenuItem<String>> _smsMin2ListItems =
      new List<DropdownMenuItem<String>>();
  String _smsMin2SelectedItem;

  List<DropdownMenuItem<String>> _smsAmPm2ListItems =
      new List<DropdownMenuItem<String>>();
  String _smsAmPm2SelectedItem;

  TextEditingController importantCommunicationController =
      TextEditingController();

  TextEditingController meetingNameController = TextEditingController();
  TextEditingController meetingDateController = TextEditingController();
  TextEditingController meetingVenueController = TextEditingController();

  TextEditingController waterSupplyDateController = TextEditingController();
  TextEditingController waterDisruptionDateController = TextEditingController();

  TextEditingController fillDrillDateController = TextEditingController();

  TextEditingController serviceDownReason1Controller = TextEditingController();
  TextEditingController serviceDownReason2Controller = TextEditingController();
  TextEditingController serviceDownDateController = TextEditingController();

  TextEditingController powerOutageDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getSocietyName();
    getBroadcastSendToList();
    getSMSTypesList();
    Provider.of<BroadcastResponse>(context, listen: false)
        .getFlatMemberDetails()
        .then((value) {
      for (int i = 0; i < value.length; i++) {
        _notificationFlatNoListItems.add(DropdownMenuItem(
          value: value[i].ID,
          child: Text(
            value[i].BLOCK +
                ' ' +
                value[i].FLAT +
                ' ' +
                value[i].NAME +
                '-' +
                value[i].TYPE,
            style: TextStyle(color: GlobalVariables.green),
          ),
        ));
        _mailFlatNoListItems.add(DropdownMenuItem(
          value: value[i].ID,
          child: Text(
            value[i].BLOCK +
                ' ' +
                value[i].FLAT +
                ' ' +
                value[i].NAME +
                '-' +
                value[i].TYPE,
            style: TextStyle(color: GlobalVariables.green),
          ),
        ));

        _smsFlatNoListItems.add(DropdownMenuItem(
          value: value[i].ID,
          child: Text(
            value[i].BLOCK +
                ' ' +
                value[i].FLAT +
                ' ' +
                value[i].NAME +
                '-' +
                value[i].TYPE,
            style: TextStyle(color: GlobalVariables.green),
          ),
        ));

        print('before setState');
        setState(() {});
      }
    });
  }

  List<BroadcastSendTo> getBroadcastSendToList() {
    broadcastSendToList
        .add(BroadcastSendTo("All Owners", "All Owners of this complex"));
    broadcastSendToList
        .add(BroadcastSendTo("Members", "All Members of this complex"));
    broadcastSendToList
        .add(BroadcastSendTo("Only Residents", "Only Residents"));
    broadcastSendToList.add(BroadcastSendTo("All Tenants", "All Tenants"));
    broadcastSendToList
        .add(BroadcastSendTo("Committee Member", "Committee Member"));
    broadcastSendToList
        .add(BroadcastSendTo("specific flat", "Select Specific Flat"));

    for (int i = 0; i < broadcastSendToList.length; i++) {
      _notificationSendToListItems.add(DropdownMenuItem(
        value: broadcastSendToList[i].sendToValue,
        child: Text(
          broadcastSendToList[i].sendToName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      setState(() {});
    }

    for (int i = 0; i < broadcastSendToList.length; i++) {
      _mailSendToListItems.add(DropdownMenuItem(
        value: broadcastSendToList[i].sendToValue,
        child: Text(
          broadcastSendToList[i].sendToName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      setState(() {});
    }

    for (int i = 0; i < broadcastSendToList.length; i++) {
      _smsSendToListItems.add(DropdownMenuItem(
        value: broadcastSendToList[i].sendToValue,
        child: Text(
          broadcastSendToList[i].sendToName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      setState(() {});
    }
  }

  List<SMSTypes> getSMSTypesList() {
    smsTypesList
        .add(SMSTypes("Important Communication", "Important Communication"));
    smsTypesList.add(SMSTypes("Meeting", "Meeting"));
    smsTypesList.add(SMSTypes("Water Supply", "Water Supply"));
    smsTypesList.add(SMSTypes("Water Disruption", "Water Disruption"));
    smsTypesList.add(SMSTypes("Fire Drill", "Fire Drill"));
    smsTypesList.add(SMSTypes("Service down", "Service down"));
    smsTypesList.add(SMSTypes("Power Outage", "Power Outage"));

    for (int i = 0; i < smsTypesList.length; i++) {
      _smsTypesListItems.add(DropdownMenuItem(
        value: smsTypesList[i].smsTypeValue,
        child: Text(
          smsTypesList[i].smsTypeName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
    }

    hoursList.add(Hours("1", "1"));
    hoursList.add(Hours("2", "2"));
    hoursList.add(Hours("3", "3"));
    hoursList.add(Hours("4", "4"));
    hoursList.add(Hours("5", "5"));
    hoursList.add(Hours("6", "6"));
    hoursList.add(Hours("7", "7"));
    hoursList.add(Hours("8", "8"));
    hoursList.add(Hours("9", "9"));
    hoursList.add(Hours("10", "10"));
    hoursList.add(Hours("11", "11"));

    for (int i = 0; i < hoursList.length; i++) {
      _smsHoursListItems.add(DropdownMenuItem(
        value: hoursList[i].hoursValue,
        child: Text(
          hoursList[i].hoursName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      _smsHours2ListItems.add(DropdownMenuItem(
        value: hoursList[i].hoursValue,
        child: Text(
          hoursList[i].hoursName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      _smsHoursSelectedItem = _smsHoursListItems[0].value;
      _smsHours2SelectedItem = _smsHours2ListItems[0].value;
    }

    minList.add(Minutes("0", "0"));
    minList.add(Minutes("15", "15"));
    minList.add(Minutes("30", "30"));
    minList.add(Minutes("45", "45"));

    for (int i = 0; i < minList.length; i++) {
      _smsMinListItems.add(DropdownMenuItem(
        value: minList[i].minValue,
        child: Text(
          minList[i].minName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      _smsMin2ListItems.add(DropdownMenuItem(
        value: minList[i].minValue,
        child: Text(
          minList[i].minName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      _smsMinSelectedItem = _smsMinListItems[0].value;
      _smsMin2SelectedItem = _smsMin2ListItems[0].value;
    }

    ampmList.add(AMPM("AM", "AM"));
    ampmList.add(AMPM("PM", "PM"));

    for (int i = 0; i < ampmList.length; i++) {
      _smsAmPmListItems.add(DropdownMenuItem(
        value: ampmList[i].ampmValue,
        child: Text(
          ampmList[i].ampmName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      _smsAmPm2ListItems.add(DropdownMenuItem(
        value: ampmList[i].ampmValue,
        child: Text(
          ampmList[i].ampmName,
          style: TextStyle(color: GlobalVariables.green),
        ),
      ));

      print('before setState');
      _smsAmPmSelectedItem = _smsAmPmListItems[0].value;
      _smsAmPm2SelectedItem = _smsAmPm2ListItems[0].value;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    return ChangeNotifierProvider<BroadcastResponse>.value(
      value: Provider.of(context),
      child: Consumer<BroadcastResponse>(
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
                  child: Icon(
                    Icons.arrow_back,
                    color: GlobalVariables.white,
                  ),
                ),
                title: text(
                  AppLocalizations.of(context).translate('my_gate'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: TabBarView(controller: _tabController, children: <Widget>[
                getNotificationBaseLayout(value),
                getMailBaseLayout(value),
                getSMSBaseLayout(value),
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
              text: AppLocalizations.of(context).translate('send_notification'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('send_email'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('send_sms'),
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

  getNotificationBaseLayout(BroadcastResponse broadcastResponse) {
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
                getNotificationLayout(broadcastResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getMailBaseLayout(BroadcastResponse broadcastResponse) {
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
                getMailLayout(broadcastResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getSMSBaseLayout(BroadcastResponse broadcastResponse) {
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
                getSMSLayout(broadcastResponse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getNotificationLayout(BroadcastResponse broadcastResponse) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              /*Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('broadcast'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),*/
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: _notificationSendToListItems,
                    value: _notificationSendToSelectedItem,
                    onChanged: (value) {
                      _notificationSendToSelectedItem = value;
                      setState(() {
                        print("value : " + value);
                      });
                    },
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('send_to') + '*',
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              _notificationSendToSelectedItem == 'specific flat'
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: _notificationFlatNoListItems,
                          value: _notificationFlatNoSelectedItem,
                          onChanged: (value) {
                            _notificationFlatNoSelectedItem = value;
                            setState(() {
                              print("value : " + value);
                              for (int i = 0;
                                  i < broadcastResponse.flatMemberList.length;
                                  i++) {
                                if (broadcastResponse.flatMemberList[i].ID ==
                                    value) {
                                  _notificationAssignFlatList
                                      .add(broadcastResponse.flatMemberList[i]);
                                  break;
                                }
                              }
                              print('_notificationAssignFlatList : ' +
                                  _notificationAssignFlatList.toString());
                            });
                          },
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('flat_no') +
                                '*',
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 14),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              _notificationSendToSelectedItem == 'specific flat'
                  ? Container(
                      //: MediaQuery.of(context).size.width / 1.1,
                      child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: MediaQuery.of(context).size.width / 150.0,
                      children: List.generate(
                        _notificationAssignFlatList.length,
                        (index) {
                          return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                  color: GlobalVariables.green,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: GlobalVariables.transparent,
                                    width: 3.0,
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: text(
                                      _notificationAssignFlatList[index].BLOCK +
                                          ' ' +
                                          _notificationAssignFlatList[index]
                                              .FLAT +
                                          ' ' /*+
                                          _notificationAssignFlatList[index]
                                              .NAME +
                                          '-' +
                                          _notificationAssignFlatList[index].TYPE*/,
                                      textColor: GlobalVariables.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppIconButton(
                                    Icons.clear,
                                    iconColor: GlobalVariables.white,
                                    onPressed: () {
                                      _notificationAssignFlatList
                                          .removeAt(index);
                                      setState(() {
                                        print('_notificationAssignFlatList : ' +
                                            _notificationAssignFlatList
                                                .toString());
                                      });
                                    },
                                  )
                                ],
                              ));
                        },
                      ),
                    ))
                  : SizedBox(),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('subject') + '*',
                controllerCallback: notificationSubject,
              ),
              Container(
                height: 150,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('description') +
                          '*',
                  controllerCallback: notificationDescription,
                  maxLines: 99,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                ),
              ),
              /*Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    notificationAttachmentFilePath == null
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
                          )
                        : AppFileImage(
                            notificationAttachmentFilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
                          ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: FlatButton.icon(
                            onPressed: () {
                              if (isStoragePermission) {
                                notificationOpenFile(context);
                              } else {
                                GlobalFunctions.askPermission(
                                        Permission.storage)
                                    .then((value) {
                                  if (value) {
                                    notificationOpenFile(context);
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context)
                                            .translate('download_permission'));
                                  }
                                });
                              }
                            },
                            icon: Icon(
                              Icons.attach_file,
                              color: GlobalVariables.mediumGreen,
                            ),
                            label: Text(
                              AppLocalizations.of(context)
                                  .translate('attach_photo'),
                              style: TextStyle(color: GlobalVariables.green),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            'OR',
                            style: TextStyle(color: GlobalVariables.lightGray),
                          ),
                        ),
                        Container(
                          child: FlatButton.icon(
                              onPressed: () {
                                if (isStoragePermission) {
                                  notificationOpenCamera(context);
                                } else {
                                  GlobalFunctions.askPermission(
                                          Permission.storage)
                                      .then((value) {
                                    if (value) {
                                      notificationOpenCamera(context);
                                    } else {
                                      GlobalFunctions.showToast(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'download_permission'));
                                    }
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                color: GlobalVariables.mediumGreen,
                              ),
                              label: Text(
                                AppLocalizations.of(context)
                                    .translate('take_picture'),
                                style: TextStyle(color: GlobalVariables.green),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),*/
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('send'),
                  onPressed: () {
                    verifyNotificationData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getMailLayout(BroadcastResponse broadcastResponse) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 40),
        padding: EdgeInsets.all(
            20), // height: MediaQuery.of(context).size.height / 0.5,
        decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          child: Column(
            children: <Widget>[
              /*Container(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context).translate('broadcast'),
                  style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),*/
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 2.0,
                    )),
                child: ButtonTheme(
                  child: DropdownButton(
                    items: _mailSendToListItems,
                    value: _mailSendToSelectedItem,
                    onChanged: (value) {
                      _mailSendToSelectedItem = value;
                      setState(() {
                        print("value : " + value);
                      });
                    },
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Text(
                      AppLocalizations.of(context).translate('send_to') + '*',
                      style: TextStyle(
                          color: GlobalVariables.lightGray, fontSize: 14),
                    ),
                  ),
                ),
              ),
              _mailSendToSelectedItem == 'specific flat'
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.mediumGreen,
                            width: 2.0,
                          )),
                      child: ButtonTheme(
                        child: DropdownButton(
                          items: _mailFlatNoListItems,
                          value: _mailFlatNoSelectedItem,
                          onChanged: (value) {
                            _mailFlatNoSelectedItem = value;
                            setState(() {
                              print("value : " + value);

                              for (int i = 0;
                                  i < broadcastResponse.flatMemberList.length;
                                  i++) {
                                if (broadcastResponse.flatMemberList[i].ID ==
                                    value) {
                                  _mailAssignFlatList
                                      .add(broadcastResponse.flatMemberList[i]);
                                  break;
                                }
                              }
                              print('_mailAssignFlatList : ' +
                                  _mailAssignFlatList.toString());
                            });
                          },
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: GlobalVariables.mediumGreen,
                          ),
                          underline: SizedBox(),
                          hint: Text(
                            AppLocalizations.of(context).translate('flat_no') +
                                '*',
                            style: TextStyle(
                                color: GlobalVariables.lightGray, fontSize: 14),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              _mailSendToSelectedItem == 'specific flat'
                  ? Container(
                      //: MediaQuery.of(context).size.width / 1.1,
                      child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio:
                          MediaQuery.of(context).size.width / 150.0,
                      children: List.generate(
                        _mailAssignFlatList.length,
                        (index) {
                          return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                  color: GlobalVariables.green,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: GlobalVariables.transparent,
                                    width: 3.0,
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: text(
                                      _mailAssignFlatList[index].BLOCK +
                                          ' ' +
                                          _mailAssignFlatList[index].FLAT +
                                          ' ' /*+
                                          _mailAssignFlatList[index].NAME +
                                          '-' +
                                          _mailAssignFlatList[index].TYPE*/,
                                      textColor: GlobalVariables.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppIconButton(
                                    Icons.clear,
                                    iconColor: GlobalVariables.white,
                                    onPressed: () {
                                      _mailAssignFlatList.removeAt(index);
                                      setState(() {
                                        print('_mailAssignFlatList : ' +
                                            _mailAssignFlatList.toString());
                                      });
                                    },
                                  )
                                ],
                              ));
                        },
                      ),
                    ))
                  : SizedBox(),
              AppTextField(
                textHintContent:
                    AppLocalizations.of(context).translate('subject') + '*',
                controllerCallback: mailSubject,
              ),
              Container(
                height: 150,
                child: AppTextField(
                  textHintContent:
                      AppLocalizations.of(context).translate('description') +
                          '*',
                  controllerCallback: mailDescription,
                  maxLines: 99,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    mailAttachmentFilePath == null
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
                          )
                        : AppFileImage(
                            mailAttachmentFilePath,
                            imageWidth: 50.0,
                            imageHeight: 50.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            radius: 25.0,
                          ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: FlatButton.icon(
                            onPressed: () {
                              if (isStoragePermission) {
                                mailOpenFile(context);
                              } else {
                                GlobalFunctions.askPermission(
                                        Permission.storage)
                                    .then((value) {
                                  if (value) {
                                    mailOpenFile(context);
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context)
                                            .translate('download_permission'));
                                  }
                                });
                              }
                            },
                            icon: Icon(
                              Icons.attach_file,
                              color: GlobalVariables.mediumGreen,
                            ),
                            label: Text(
                              AppLocalizations.of(context)
                                  .translate('attach_photo'),
                              style: TextStyle(color: GlobalVariables.green),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            'OR',
                            style: TextStyle(color: GlobalVariables.lightGray),
                          ),
                        ),
                        Container(
                          child: FlatButton.icon(
                              onPressed: () {
                                if (isStoragePermission) {
                                  mailOpenCamera(context);
                                } else {
                                  GlobalFunctions.askPermission(
                                          Permission.storage)
                                      .then((value) {
                                    if (value) {
                                      mailOpenCamera(context);
                                    } else {
                                      GlobalFunctions.showToast(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'download_permission'));
                                    }
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                color: GlobalVariables.mediumGreen,
                              ),
                              label: Text(
                                AppLocalizations.of(context)
                                    .translate('take_picture'),
                                style: TextStyle(color: GlobalVariables.green),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                height: 45,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppButton(
                  textContent: AppLocalizations.of(context).translate('send'),
                  onPressed: () {
                    verifyMailData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*  void notificationOpenFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      notificationAttachmentFilePath = value;
      getNotificationCompressFilePath();
    });
  }

  void notificationOpenCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      notificationAttachmentFilePath = value.path;
      getNotificationCompressFilePath();
    });
  }

  void getNotificationCompressFilePath() {
    notificationAttachmentFileName = notificationAttachmentFilePath.substring(
        notificationAttachmentFilePath.lastIndexOf('/') + 1,
        notificationAttachmentFilePath.length);
    print('file Name : ' + notificationAttachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(notificationAttachmentFilePath,
              value.toString() + '/' + notificationAttachmentFileName)
          .then((value) {
        notificationAttachmentCompressFilePath = value.toString();
        print('Cache file path : ' + notificationAttachmentCompressFilePath);
        setState(() {});
      });
    });
  }*/

  void verifyNotificationData() {
    if (notificationSubject.text.length > 0) {
      if (_notificationSendToSelectedItem != null) {
        if (notificationDescription.text.length > 0) {
          /*   String attachmentName;
          String attachment;


          if (notificationAttachmentFileName != null && notificationAttachmentFilePath != null) {
            attachmentName = notificationAttachmentFileName;
            attachment =
                GlobalFunctions.convertFileToString(notificationAttachmentCompressFilePath);
          }
*/
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context, listen: false)
              .postNotificationBroadcast(
                  _notificationAssignFlatList,
                  _notificationSendToSelectedItem,
                  notificationSubject.text,
                  notificationDescription.text)
              .then((value) {
                _progressDialog.hide();
            GlobalFunctions.showToast(value.message);

                if(value.status){
                  Navigator.of(context).pop();
                }
            print('Value result : ' + value.toString());
            //{data: [], status: true, message: Send Email Sucessfully}
          });
        } else {
          GlobalFunctions.showToast("Please Enter Description");
        }
      } else {
        GlobalFunctions.showToast("Please Select SendTo");
      }
    } else {
      GlobalFunctions.showToast("Please Enter Subject");
    }
  }

  void mailOpenFile(BuildContext context) {
    GlobalFunctions.getFilePath(context).then((value) {
      mailAttachmentFilePath = value;
      getMailCompressFilePath();
    });
  }

  void mailOpenCamera(BuildContext context) {
    GlobalFunctions.openCamera().then((value) {
      mailAttachmentFilePath = value.path;
      getMailCompressFilePath();
    });
  }

  void getMailCompressFilePath() {
    mailAttachmentFileName = mailAttachmentFilePath.substring(
        mailAttachmentFilePath.lastIndexOf('/') + 1,
        mailAttachmentFilePath.length);
    print('file Name : ' + mailAttachmentFileName.toString());
    GlobalFunctions.getTemporaryDirectoryPath().then((value) {
      print('cache file Path : ' + value.toString());
      GlobalFunctions.getFilePathOfCompressImage(mailAttachmentFilePath,
              value.toString() + '/' + mailAttachmentFileName)
          .then((value) {
        mailAttachmentCompressFilePath = value.toString();
        print('Cache file path : ' + mailAttachmentCompressFilePath);
        setState(() {});
      });
    });
  }

  void verifyMailData() {
    if (mailSubject.text.length > 0) {
      if (_mailSendToSelectedItem != null) {
        if (mailDescription.text.length > 0) {
          String attachmentName;
          String attachment;

          if (mailAttachmentFileName != null &&
              mailAttachmentFilePath != null) {
            attachmentName = mailAttachmentFileName;
            attachment = GlobalFunctions.convertFileToString(
                mailAttachmentCompressFilePath);
          }
          _progressDialog.show();

          Provider.of<BroadcastResponse>(context, listen: false)
              .postMailBroadcast(
                  _mailAssignFlatList,
                  attachment,
                  _mailSendToSelectedItem,
                  mailSubject.text,
                  mailDescription.text)
              .then((value) {

                _progressDialog.hide();
            GlobalFunctions.showToast(value.message);

            if(value.status){
              Navigator.of(context).pop();
            }
            print('Value result : ' + value.toString());
            //{data: [], status: true, message: Send Email Sucessfully}
          });
        } else {
          GlobalFunctions.showToast("Please Enter Description");
        }
      } else {
        GlobalFunctions.showToast("Please Select SendTo");
      }
    } else {
      GlobalFunctions.showToast("Please Enter Subject");
    }
  }

  getSMSLayout(BroadcastResponse broadcastResponse) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              // height: double.infinity,
              // color: GlobalVariables.black,
              //width: MediaQuery.of(context).size.width / 1.2,
              margin: EdgeInsets.fromLTRB(
                  10,
                  MediaQuery.of(context).size.height / 20,
                  10,
                  0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Card(
                shape: (RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
                elevation: 2.0,
                //  shadowColor: GlobalVariables.green.withOpacity(0.3),
              //  margin: EdgeInsets.all(20),
                color: GlobalVariables.white,
                child: Stack(
                  children: <Widget>[
                    /*Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AppAssetsImage(
                          GlobalVariables.whileBGPath,
                        ),
                      ),
                    ),*/
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: (){

                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(
                                            AppLocalizations.of(context).translate('available'),
                                            textColor: GlobalVariables.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeMedium),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(smsCredit,
                                            textColor: GlobalVariables.black,
                                            fontSize: GlobalVariables.textSizeNormal,
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

                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('sent'),
                                            textColor: GlobalVariables.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeMedium),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(smsSent,
                                            textColor: GlobalVariables.black,
                                            fontSize: GlobalVariables.textSizeNormal,
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

                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(AppLocalizations.of(context).translate('balance'),
                                            textColor: GlobalVariables.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: GlobalVariables.textSizeMedium),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: text(smsBalance,
                                            textColor: GlobalVariables.black,
                                            fontSize: GlobalVariables.textSizeNormal,
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
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
            padding: EdgeInsets.all(
                20), // height: MediaQuery.of(context).size.height / 0.5,
            decoration: BoxDecoration(
                color: GlobalVariables.white,
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: GlobalVariables.mediumGreen,
                          width: 2.0,
                        )),
                    child: ButtonTheme(
                      child: DropdownButton(
                        items: _smsSendToListItems,
                        value: _smsSendToSelectedItem,
                        onChanged: (value) {
                          _smsSendToSelectedItem = value;
                          setState(() {
                            print("value : " + value);
                          });
                        },
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: GlobalVariables.mediumGreen,
                        ),
                        underline: SizedBox(),
                        hint: Text(
                          AppLocalizations.of(context).translate('send_to') + '*',
                          style: TextStyle(
                              color: GlobalVariables.lightGray, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  _smsSendToSelectedItem == 'specific flat'
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          decoration: BoxDecoration(
                              color: GlobalVariables.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: GlobalVariables.mediumGreen,
                                width: 2.0,
                              )),
                          child: ButtonTheme(
                            child: DropdownButton(
                              items: _smsFlatNoListItems,
                              value: _smsFlatNoSelectedItem,
                              onChanged: (value) {
                                _smsFlatNoSelectedItem = value;
                                setState(() {
                                  print("value : " + value);

                                  for (int i = 0;
                                      i < broadcastResponse.flatMemberList.length;
                                      i++) {
                                    if (broadcastResponse.flatMemberList[i].ID ==
                                        value) {
                                      _smsAssignFlatList
                                          .add(broadcastResponse.flatMemberList[i]);
                                      break;
                                    }
                                  }
                                  print('_mailAssignFlatList : ' +
                                      _smsAssignFlatList.toString());
                                });
                              },
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: GlobalVariables.mediumGreen,
                              ),
                              underline: SizedBox(),
                              hint: Text(
                                AppLocalizations.of(context).translate('flat_no') +
                                    '*',
                                style: TextStyle(
                                    color: GlobalVariables.lightGray, fontSize: 14),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  _smsSendToSelectedItem == 'specific flat'
                      ? Container(
                          //: MediaQuery.of(context).size.width / 1.1,
                          child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio:
                              MediaQuery.of(context).size.width / 150.0,
                          children: List.generate(
                            _smsAssignFlatList.length,
                            (index) {
                              return Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  decoration: BoxDecoration(
                                      color: GlobalVariables.green,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: GlobalVariables.transparent,
                                        width: 3.0,
                                      )),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: text(
                                          _smsAssignFlatList[index].BLOCK +
                                              ' ' +
                                              _smsAssignFlatList[index].FLAT +
                                              ' ' /*+
                                              _smsAssignFlatList[index].NAME +
                                              '-' +
                                              _smsAssignFlatList[index].TYPE*/,
                                          textColor: GlobalVariables.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      AppIconButton(
                                        Icons.clear,
                                        iconColor: GlobalVariables.white,
                                        onPressed: () {
                                          _smsAssignFlatList.removeAt(index);
                                          setState(() {
                                            print('_mailAssignFlatList : ' +
                                                _smsAssignFlatList.toString());
                                          });
                                        },
                                      )
                                    ],
                                  ));
                            },
                          ),
                        ))
                      : SizedBox(),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: GlobalVariables.mediumGreen,
                          width: 2.0,
                        )),
                    child: ButtonTheme(
                      child: DropdownButton(
                        items: _smsTypesListItems,
                        value: _smsTypesSelectedItem,
                        onChanged: (value) {
                          _smsTypesSelectedItem = value;
                          setState(() {
                            print("value : " + value);
                          });
                        },
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: GlobalVariables.mediumGreen,
                        ),
                        underline: SizedBox(),
                        hint: Text(
                          AppLocalizations.of(context).translate('sms_type') + '*',
                          style: TextStyle(
                              color: GlobalVariables.lightGray, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: text(
                        AppLocalizations.of(context).translate('template_message') +
                            '*',
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  getDynamicSmsTypeTemplateLayout(),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: text(
                            AppLocalizations.of(context).translate('note') + ':',
                            textColor: GlobalVariables.red,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('sms_note_message'),
                              textColor: GlobalVariables.red,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    height: 45,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: AppButton(
                      textContent: AppLocalizations.of(context).translate('send'),
                      onPressed: () {
                        verifySMSData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getDynamicSmsTypeTemplateLayout() {
    switch (_smsTypesSelectedItem) {
      case "Important Communication":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context)
                    .translate('important_communication_1')),
                AppTextField(
                    textHintContent: "",
                    controllerCallback: importantCommunicationController),
                text(AppLocalizations.of(context)
                    .translate('important_communication_2')),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Meeting":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                    textHintContent: "",
                    controllerCallback: meetingNameController),
                text(AppLocalizations.of(context).translate('meeting_on')),
                AppTextField(
                  textHintContent: "",
                  controllerCallback: meetingDateController,
                  readOnly: true,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.mediumGreen,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        meetingDateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                      });
                    },
                  ),
                ),
                text(AppLocalizations.of(context).translate('at')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(", " +
                    AppLocalizations.of(context).translate('venue') +
                    ", "),
                AppTextField(
                    textHintContent: "",
                    controllerCallback: meetingVenueController),
                text(". " +
                    AppLocalizations.of(context).translate('attend_meeting') +
                    ". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Water Supply":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context)
                    .translate('water_supply_available')),
                AppTextField(
                  textHintContent: "",
                  controllerCallback: waterSupplyDateController,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  readOnly: true,
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.mediumGreen,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        waterSupplyDateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(AppLocalizations.of(context).translate('to')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHours2ListItems,
                            value: _smsHours2SelectedItem,
                            onChanged: (value) {
                              _smsHours2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMin2ListItems,
                            value: _smsMin2SelectedItem,
                            onChanged: (value) {
                              _smsMin2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPm2ListItems,
                            value: _smsAmPm2SelectedItem,
                            onChanged: (value) {
                              _smsAmPm2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(". " +
                    AppLocalizations.of(context)
                        .translate('water_supply_necessary_arrangements') +
                    ". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Water Disruption":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context).translate('water_outage_on')),
                AppTextField(
                    textHintContent: "",
                    controllerCallback: waterDisruptionDateController,
                    contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    readOnly: true,
                    suffixIcon: AppIconButton(
                      Icons.date_range,
                      iconColor: GlobalVariables.mediumGreen,
                      onPressed: () {
                        GlobalFunctions.getSelectedDate(context).then((value) {
                          waterDisruptionDateController.text =
                              value.day.toString().padLeft(2, '0') +
                                  "-" +
                                  value.month.toString().padLeft(2, '0') +
                                  "-" +
                                  value.year.toString();
                        });
                      },
                    )),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(AppLocalizations.of(context).translate('to')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHours2ListItems,
                            value: _smsHours2SelectedItem,
                            onChanged: (value) {
                              _smsHours2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMin2ListItems,
                            value: _smsMin2SelectedItem,
                            onChanged: (value) {
                              _smsMin2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPm2ListItems,
                            value: _smsAmPm2SelectedItem,
                            onChanged: (value) {
                              _smsAmPm2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(". " +
                    AppLocalizations.of(context)
                        .translate('water_supply_necessary_arrangements') +
                    ". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Fire Drill":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context).translate('fire_drill_on')),
                AppTextField(
                  textHintContent: "",
                  controllerCallback: fillDrillDateController,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  readOnly: true,
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.mediumGreen,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        fillDrillDateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(". " +
                    AppLocalizations.of(context)
                        .translate('fire_drill_participate_without_fail') +
                    ". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Service down":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context)
                    .translate('service_down_due_to')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: AppTextField(
                          textHintContent: "",
                          controllerCallback: serviceDownReason1Controller),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    text(","),
                    SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: 1,
                      child: AppTextField(
                          textHintContent: "",
                          controllerCallback: serviceDownReason2Controller),
                    ),
                  ],
                ),
                text(AppLocalizations.of(context)
                    .translate('service_down_from')),
                AppTextField(
                  textHintContent: "",
                  controllerCallback: serviceDownDateController,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  readOnly: true,
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.mediumGreen,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        serviceDownDateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(AppLocalizations.of(context).translate('to')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHours2ListItems,
                            value: _smsHours2SelectedItem,
                            onChanged: (value) {
                              _smsHours2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMin2ListItems,
                            value: _smsMin2SelectedItem,
                            onChanged: (value) {
                              _smsMin2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPm2ListItems,
                            value: _smsAmPm2SelectedItem,
                            onChanged: (value) {
                              _smsAmPm2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // text(". "+AppLocalizations.of(context).translate('water_supply_necessary_arrangements')+". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      case "Power Outage":
        {
          return Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(AppLocalizations.of(context).translate('power_outage_on')),
                AppTextField(
                  textHintContent: "",
                  controllerCallback: powerOutageDateController,
                  contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  readOnly: true,
                  suffixIcon: AppIconButton(
                    Icons.date_range,
                    iconColor: GlobalVariables.mediumGreen,
                    onPressed: () {
                      GlobalFunctions.getSelectedDate(context).then((value) {
                        powerOutageDateController.text =
                            value.day.toString().padLeft(2, '0') +
                                "-" +
                                value.month.toString().padLeft(2, '0') +
                                "-" +
                                value.year.toString();
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHoursListItems,
                            value: _smsHoursSelectedItem,
                            onChanged: (value) {
                              _smsHoursSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMinListItems,
                            value: _smsMinSelectedItem,
                            onChanged: (value) {
                              _smsMinSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPmListItems,
                            value: _smsAmPmSelectedItem,
                            onChanged: (value) {
                              _smsAmPmSelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(AppLocalizations.of(context).translate('to')),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsHours2ListItems,
                            value: _smsHours2SelectedItem,
                            onChanged: (value) {
                              _smsHours2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsMin2ListItems,
                            value: _smsMin2SelectedItem,
                            onChanged: (value) {
                              _smsMin2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: BoxDecoration(
                            color: GlobalVariables.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlobalVariables.mediumGreen,
                              width: 2.0,
                            )),
                        child: ButtonTheme(
                          child: DropdownButton(
                            items: _smsAmPm2ListItems,
                            value: _smsAmPm2SelectedItem,
                            onChanged: (value) {
                              _smsAmPm2SelectedItem = value;
                              setState(() {
                                print("value : " + value);
                              });
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: GlobalVariables.mediumGreen,
                            ),
                            underline: SizedBox(),
                            hint: Text(
                              "",
                              style: TextStyle(
                                  color: GlobalVariables.lightGray,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                text(". " +
                    AppLocalizations.of(context)
                        .translate('water_supply_necessary_arrangements') +
                    ". "),
                text("-" + societyName),
              ],
            ),
          );
        }
        break;
      default:
        {
          return SizedBox();
        }
    }
  }

  Future<void> getSocietyName() async {
    societyName = await GlobalFunctions.getSocietyName();
    smsCredit = await GlobalFunctions.getSMSCredit();
    Provider.of<UserManagementResponse>(context,listen: false).getUserManagementDashboard().then((value) {

      smsSent = value;
      smsBalance = (int.parse(smsCredit)-int.parse(smsSent)).toString();
      setState(() {

      });

    });
  }

  void verifySMSData() {
    switch (_smsTypesSelectedItem) {
      case "Important Communication":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context, listen: false)
              .importantCommunicationSMS(
                  _smsAssignFlatList,
                  _smsSendToSelectedItem,
                  _smsTypesSelectedItem,
                  importantCommunicationController.text,
                  societyName)
              .then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }

          });
        }
        break;
      case "Meeting":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context, listen: false)
              .meetingSMS(
                  _smsAssignFlatList,
                  _smsSendToSelectedItem,
                  _smsTypesSelectedItem,
                  meetingNameController.text,
                  meetingDateController.text,
                  _smsHoursSelectedItem,
                  _smsMinSelectedItem,
                  _smsAmPmSelectedItem,
                  meetingVenueController.text,
                  societyName)
              .then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }

          });
        }
        break;
      case "Water Supply":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context,listen: false).waterSupplySMS(_smsAssignFlatList, 
              _smsSendToSelectedItem, _smsTypesSelectedItem, waterSupplyDateController.text
              , _smsHoursSelectedItem, _smsMinSelectedItem, _smsAmPmSelectedItem, 
              _smsHours2SelectedItem, _smsMin2SelectedItem, _smsAmPm2SelectedItem, societyName).then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }

                
          });
          

        }
        break;
      case "Water Disruption":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context,listen: false).waterDisruptionSMS(_smsAssignFlatList, _smsSendToSelectedItem, _smsTypesSelectedItem, waterDisruptionDateController.text, _smsHoursSelectedItem, _smsMinSelectedItem, _smsTypesSelectedItem, _smsHours2SelectedItem, _smsMin2SelectedItem, _smsAmPm2SelectedItem, societyName).then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }
         //   GlobalFunctions.showToast(value.message);

          });
          
          
        }
        break;
      case "Fire Drill":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context,listen: false).fireDrillSMS(_smsAssignFlatList, _smsSendToSelectedItem, 
              _smsTypesSelectedItem, fillDrillDateController.text, _smsHoursSelectedItem, _smsMinSelectedItem, _smsAmPmSelectedItem, societyName).then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }
         //   GlobalFunctions.showToast(value.message);
                
          });
          
          
        }
        break;
      case "Service down":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context,listen: false).serviceDownSMS(_smsAssignFlatList, _smsSendToSelectedItem, _smsTypesSelectedItem, serviceDownReason1Controller.text, serviceDownReason2Controller.text, serviceDownDateController.text, _smsHoursSelectedItem, _smsMinSelectedItem, _smsAmPmSelectedItem, _smsHours2SelectedItem, _smsMin2SelectedItem, _smsAmPm2SelectedItem, societyName).then((value) {
            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }
            //GlobalFunctions.showToast(value.message);
          });
          
          
        }
        break;
      case "Power Outage":
        {
          _progressDialog.show();
          Provider.of<BroadcastResponse>(context,listen: false).powerOutageSMS(_smsAssignFlatList, _smsSendToSelectedItem, _smsTypesSelectedItem, powerOutageDateController.text, _smsHoursSelectedItem, _smsMinSelectedItem, _smsAmPmSelectedItem, _smsHours2SelectedItem, _smsMin2SelectedItem, _smsAmPm2SelectedItem, societyName).then((value) {

            _progressDialog.hide();
            GlobalFunctions.showToast(value.message);
            if (value.status) {
              print('sms1 response : ');
              Navigator.of(context).pop();
            }

          });


        }
        break;
    }
  }
}
