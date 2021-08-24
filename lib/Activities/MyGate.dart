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
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseMyGate extends StatefulWidget {
  String pageName;
  String _VID;

  BaseMyGate(this.pageName, this._VID);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyGateState(pageName, this._VID);
  }
}

class MyGateState extends BaseStatefulState<BaseMyGate>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  // List<Visitor> value.visitorList = new List<Visitor>();
  // List<ScheduleVisitor> value.scheduleVisitorList = new List<ScheduleVisitor>();

  var name = "", photo = "", societyId, flat, block, duesRs = "", duesDate = "";

  //String _selectedItem,_selectedText="";
  int position = 0;

  //List<DropdownMenuItem<String>> _societyListItems = new List<DropdownMenuItem<String>>();
  // List<LoginResponse> _societyList = new List<LoginResponse>();
  // LoginResponse _selectedSocietyLogin ;
  var username, password;
  ProgressDialog _progressDialog;

  // bool isActivitiesAPICall = false;
  bool isHelperAPICall = false;

  // List<Staff> _staffList = new List<Staff>();
  List<String> _scheduleList = new List<String>();
  List<DropdownMenuItem<String>> _scheduleListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedSchedule;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  String pageName;
  String _VID;

  MyGateState(this.pageName, this._VID);

  final ContactPicker _contactPicker = ContactPicker();
  Contact _contact;

  // List<StaffCount> value.staffListCount = List<StaffCount>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    print(pageName.toString());
    _handleTabSelection();
    // getTicketDescriptionList();
    //getDocumentDescriptionList();
    getScheduleTimeData();
  }

  void afterBuild(visitorList) {
    // executes after build is done
    print('After Build');
    if (_VID != null && visitorList.length > 0) {
      print('VID : ' + _VID.toString());
      for (int i = 0; i < visitorList.length; i++) {
        if (visitorList[i].ID == _VID) {
          print('value.visitorList[i].ID : ' + visitorList[i].ID.toString());
          showDialog(
              context: context,
              builder: (BuildContext context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      child: displayVisitorInfo(i, visitorList),
                    );
                  }));
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
    if (pageName != null) {
      redirectToPage(pageName);
    }
    print('after build');
    // TODO: implement build
    return ChangeNotifierProvider<GatePass>.value(
      value: Provider.of(context),
      child: Consumer<GatePass>(
        builder: (context, value, child) {
          return Builder(
            builder: (context) => Scaffold(
              backgroundColor: GlobalVariables.veryLightGray,
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
                  AppLocalizations.of(context).translate('my_gate'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: TabBarView(controller: _tabController, children: <Widget>[
                getMyActivitiesLayout(value),
                getStaffCategoryLayout(value),
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
              text: AppLocalizations.of(context).translate('my_activities'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Tab(
              text: AppLocalizations.of(context).translate('helpers'),
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

  getMyActivitiesLayout(GatePass value) {
    // print('MyTicketLayout Tab Call');
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
        // getSocietyDataLayout(),
        //   activitiesFilterDateLayout(),
        value.isLoading
            ? GlobalFunctions.loadingWidget(context)
            : getActivitiesListDataLayout(value),
        addActivitiesFabLayout(),
      ],
    );
  }

  getStaffCategoryLayout(GatePass value) {
    print(value.staffListCount.toString());
    return Stack(
      children: <Widget>[
        GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 180.0),
        (AppSocietyPermission.isSocHideHelperPermission)
            ? GlobalFunctions.showAdminPermissionDialogToAccessFeature(
                context, false)
            : (value.isLoading)
                ? GlobalFunctions.loadingWidget(context)
                : getStaffCategoryListDataLayout(value)
      ],
    );
  }

  getStaffCategoryListDataLayout(GatePass value) {
    return value.staffListCount.length > 0
        ? Container(
            margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      itemCount: value.staffListCount.length,
                      itemBuilder: (context, position) {
                        return getStaffCategoryListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          )
        : GlobalFunctions.noDataFoundLayout(context, "No Data Found");
  }

  getStaffCategoryListItemLayout(int position, GatePass value) {
    return InkWell(
        onTap: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseStaffListPerCategory(
                      value.staffListCount[position].ROLE)));
        },
        child: AppContainer(
          isListItem: true,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: text(value.staffListCount[position].ROLE,
                          fontSize: GlobalVariables.textSizeMedium),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: text(value.staffListCount[position].Role_count,
                        fontSize: GlobalVariables.textSizeSMedium),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: AppIcon(
                      Icons.arrow_forward_ios,
                      iconColor: GlobalVariables.lightGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

/*
  Future<void> getStaffCountData() async {
    isHelperAPICall=true;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClient.staffCount(societyId).then((value) {
      _progressDialog.hide();
      List<dynamic> _list = value.data;
      value.staffListCount = List<StaffCount>.from(_list.map((i)=>StaffCount.fromJson(i)));
      setState(() {});
    });

  }
*/

  /*getSocietyDataLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 250,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 50, 0, 0),
        //TODO : Dropdown
        child: ButtonTheme(
          //alignedDropdown: true,
          child: DropdownButton(
            items: _societyListItems,
            onChanged: changeDropDownItem,
            value: _selectedItem,
            underline: SizedBox(),
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: GlobalVariables.white,
            ),
            iconSize: 20,
            selectedItemBuilder: (BuildContext context){
             // String txt =  _societyListItems.elementAt(position).value;
              return _societyListItems.map((e) {
                return Container(
                  alignment: Alignment.center,
                    //margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Text(_selectedText,style: TextStyle(color: GlobalVariables.white),));
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  void changeDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        setState(() {
          _selectedItem = value;
          print('_selctedItem:' + _selectedItem.toString());
          for (int i = 0; i < _societyList.length; i++) {
            if (_selectedItem == _societyList[i].ID) {
              _selectedSocietyLogin = _societyList[i];
              _selectedSocietyLogin.PASSWORD = password;
              position=i;
              _selectedText =  _selectedSocietyLogin.BLOCK+
                  "-" +
                  _selectedSocietyLogin.FLAT +
                  " " +
                  _selectedSocietyLogin.Society_Name;
             /* GlobalFunctions.saveDataToSharedPreferences(
                  _selectedSocietyLogin);*/
              print('for _selctedItem:' + _selectedItem);
              break;
            }
          }
        });
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }
*/

  activitiesFilterDateLayout() {
    TextEditingController _dateController = TextEditingController();
    _dateController.text = DateTime.now().toLocal().day.toString() +
        "/" +
        DateTime.now().toLocal().month.toString() +
        "/" +
        DateTime.now().toLocal().year.toString();

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 10, 0, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.transparent,
          //  borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: GlobalVariables.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlobalVariables.mediumGreen,
                        width: 3.0,
                      )),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          hintText: "Filter",
                          hintStyle:
                              TextStyle(color: GlobalVariables.veryLightGray),
                          border: InputBorder.none,
                          suffixIcon: AppIcon(
                            Icons.search,
                            iconColor: GlobalVariables.mediumGreen,
                          )),
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                    color: GlobalVariables.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )),
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    style: TextStyle(color: GlobalVariables.green),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        hintText: "Date",
                        hintStyle:
                            TextStyle(color: GlobalVariables.veryLightGray),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () {
                            // GlobalFunctions.showToast('iDate icon click');
                            GlobalFunctions.getSelectedDate(context)
                                .then((value) {
                              _dateController.text = value.day.toString() +
                                  "/" +
                                  value.month.toString() +
                                  "/" +
                                  value.year.toString();
                            });
                          },
                          icon: AppIcon(
                            Icons.date_range,
                            iconColor: GlobalVariables.mediumGreen,
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  addActivitiesFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
                /* Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        BaseExpectedVisitor()));*/
                _nameController.text = '';
                _mobileController.text = '';
                showDialog(
                    context: context,
                    builder: (BuildContext context) => StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: scheduleVisitorLayout(),
                          );
                        }));
              },
              child: AppIcon(
                Icons.add,
                iconColor: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getActivitiesListDataLayout(GatePass value) {
    return SingleChildScrollView(
      child: value.scheduleVisitorList.length>0 || value.visitorList.length>0 ? Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.scheduleVisitorList.length,
                      itemBuilder: (context, position) {
                        return getScheduleVisitorListItemLayout(
                            position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.visitorList.length,
                      itemBuilder: (context, position) {
                        return getVisitorsListItemLayout(position, value);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ],
      ) : GlobalFunctions.noDataFoundLayout(context, "No Data Found"),
    );
  }

  getVisitorsListItemLayout(int position, GatePass value) {
    String Time = "";
    String Date = "";
    if (value.visitorList[position].OUT_TIME.length > 0) {
      if (value.visitorList[position].STATUS.toLowerCase() == 'out') {
        Time = /*value.visitorList[position].IN_TIME +
            " - " +*/
            value.visitorList[position].OUT_TIME;
      } else {
        Time = value.visitorList[position].IN_TIME;
      }
    } else {
      Time = value.visitorList[position].IN_TIME;
    }

    if (value.visitorList[position].OUT_DATE.length > 0) {
      if (value.visitorList[position].STATUS.toLowerCase() == 'out') {
        Date = /*value.visitorList[position].IN_DATE +
            " - " +*/
            value.visitorList[position].OUT_DATE;
      } else {
        Date = value.visitorList[position].IN_DATE;
      }
    } else {
      Date = value.visitorList[position].IN_DATE;
    }

    var visitorStatus = getVisitorAllowStatus(
        value.visitorList[position].VISITOR_STATUS,
        value.visitorList[position].VISITOR_USER_STATUS);
    var visitorUserStatus = value.visitorList[position].VISITOR_USER_STATUS;
    //  print('value.visitorList[position].VISITOR_STATUS : ' + visitorStatus);
    // print('value.visitorList[position].VISITOR_USER_STATUS : ' + visitorStatus);

    return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      child: displayVisitorInfo(position, value.visitorList),
                    );
                  }));
        },
        child: AppContainer(
          isListItem: true,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    value.visitorList[position].IMAGE.isEmpty
                        ? AppAssetsImage(
                            GlobalVariables.componentUserProfilePath,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            // radius: 10.0,
                          )
                        : AppNetworkImage(
                            value.visitorList[position].IMAGE,
                            imageWidth: 40.0,
                            imageHeight: 40.0,
                            borderColor: GlobalVariables.grey,
                            borderWidth: 1.0,
                            fit: BoxFit.cover,
                            //radius: 10.0,
                          ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: primaryText(
                                value.visitorList[position].VISITOR_NAME,
                              ),
                            ),
                            Container(
                              //margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: text(
                                      Date + '  ' + Time,
                                      textColor: GlobalVariables.grey,
                                      fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                              color: value.visitorList[position].VISITOR_STATUS
                                          .toLowerCase() ==
                                      'no-answer'
                                  ? GlobalVariables.grey
                                  : value.visitorList[position].STATUS
                                              .toLowerCase() ==
                                          'in'
                                      ? GlobalVariables.green
                                      : GlobalVariables.red,
                              borderRadius: BorderRadius.circular(5)),
                          child: text(
                            value.visitorList[position].VISITOR_STATUS
                                        .toLowerCase() ==
                                    'no-answer'
                                ? 'No-Answer'
                                : value.visitorList[position].STATUS
                                            .toLowerCase() ==
                                        'in'
                                    ? 'Arrived'
                                    : 'Left',
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                        ),
                        /* InkWell(
                        onTap: (){
                          launch('tel://' + value.visitorList[position].CONTACT);
                        },
                        child: Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Icon(Icons.call,color: GlobalVariables.mediumGreen,)
                        ),
                      ),*/
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              value.visitorList[position].FROM_VISITOR.length > 0 &&
                      value.visitorList[position].FROM_VISITOR != null
                  ? Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topLeft,
                              //margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: AppIconButton(
                                Icons.location_on,
                                iconColor: GlobalVariables.mediumGreen,
                                iconSize: 20.0,
                              )),
                          SizedBox(
                            width: 18,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            //margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
                            child: secondaryText(
                              value.visitorList[position].FROM_VISITOR,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 8,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        // margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                        child: AppIconButton(
                          Icons.person,
                          iconColor: GlobalVariables.mediumGreen,
                          iconSize: 20.0,
                        )),
                    SizedBox(
                      width: 18,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      //margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
                      child: secondaryText(
                        visitorStatus,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              if (visitorUserStatus.toLowerCase() !=
                                  'wrong entry') {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              child: displayWrongEntryLayout(
                                                  position, value));
                                        }));
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: AppIconButton(
                                  /* visitorUserStatus.toLowerCase() != 'wrong entry' ?*/
                                  Icons.block /*: null*/,
                                  iconColor: visitorUserStatus.toLowerCase() !=
                                          'wrong entry'
                                      ? GlobalVariables.mediumGreen
                                      : GlobalVariables.lightGreen,
                                  iconSize: 20.0,
                                )),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: text(
                                    visitorUserStatus.toLowerCase() !=
                                            'wrong entry'
                                        ? 'Wrong Entry'
                                        : 'Marked incorrect',
                                    textColor:
                                        visitorUserStatus.toLowerCase() !=
                                                'wrong entry'
                                            ? GlobalVariables.grey
                                            : GlobalVariables.lightGray,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(),
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: AppIconButton(Icons.call,
                              iconColor: GlobalVariables.green, onPressed: () {
                            launch(
                                'tel://' + value.visitorList[position].CONTACT);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              /*   Visibility(
              visible: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(50, 5, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: AppIcon(
                          Icons.perm_identity,
                          iconColor: GlobalVariables.mediumGreen,
                        )),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: text(
                        value.visitorList[position].VISITOR_NAME,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Container(
                height: 2,
                color: GlobalVariables.mediumGreen,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Divider(
                  height: 2,
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 30,
                      padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GlobalVariables.green,
                      ),
                      child: FlatButton.icon(
                        onPressed: () {},
                        icon: AppIcon(
                          Icons.edit,
                          iconColor: GlobalVariables.white,
                          iconSize: GlobalVariables.textSizeNormal,
                        ),
                        label: text(
                            AppLocalizations.of(context).translate('edit'),
                            textColor: GlobalVariables.white
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GlobalVariables.green,
                      ),
                      child: FlatButton.icon(
                          onPressed: () {},
                          icon: AppIcon(
                            Icons.cancel,
                            iconColor: GlobalVariables.white,
                            iconSize: GlobalVariables.textSizeNormal,
                          ),
                          label: text(
                            AppLocalizations.of(context).translate('cancel'),
                            textColor: GlobalVariables.white,
                          )),
                    ),
                  ],
                ),
              ),
            )*/
            ],
          ),
        ));
  }

  getScheduleVisitorListItemLayout(int position, GatePass value) {
    return AppContainer(
      isListItem: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    backgroundColor: GlobalVariables.grey,
                    child: AppAssetsImage(
                      getVisitorStatusIcon('visitor'),
                      imageWidth: 20,
                      imageHeight: 20,
                      imageColor: GlobalVariables.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Container(
                    //padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: primaryText(
                            value.scheduleVisitorList[position].NAME,
                          ),
                        ),
                        text(
                          GlobalFunctions.convertDateFormat(
                              value.scheduleVisitorList[position].DATE,
                              'dd-MM-yyyy'),
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSmall,
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: BoxDecoration(
                          color: GlobalVariables.skyBlue,
                          borderRadius: BorderRadius.circular(5)),
                      child: text(
                        'Expected',
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeSmall,
                      ),
                    ),
                    /* InkWell(
                      onTap: (){
                        launch('tel://' + value.visitorList[position].CONTACT);
                      },
                      child: Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Icon(Icons.call,color: GlobalVariables.mediumGreen,)
                      ),
                    ),*/
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: AppIcon(
                    Icons.vpn_key,
                    iconColor: GlobalVariables.mediumGreen,
                    iconSize: 25,
                  )),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 12),
                child: secondaryText(
                  value.scheduleVisitorList[position].PASS_CODE,
                  /*  textColor: GlobalVariables.grey,
                  fontSize: GlobalVariables.textSizeMedium,*/
                ),
              ),
            ],
          ),
          Divider(),
          Container(
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: AppIconButton(Icons.share,
                          iconColor: GlobalVariables.green,
                          iconSize: 20, onPressed: () async {
                        String googleParameter =
                            await GlobalFunctions.getGoogleCoordinate();
                        String userName =
                            await GlobalFunctions.getDisplayName();
                        DateTime earlier = DateTime.parse(
                            value.scheduleVisitorList[position].DATE);

                        DateTime date = DateTime.now();
                        String todayDate = GlobalFunctions.convertDateFormat(
                            earlier.toIso8601String(), 'dd MMM');
                        String currentTime = GlobalFunctions.convertDateFormat(
                            date.toIso8601String(), 'hh:mm aa');
                        String mapUrl = "http://www.google.com/maps/place/" +
                            googleParameter;

                        String sharedMsg = userName +
                            ' has invited you using <a href="https://societyrun.com/">societyrun.com</a> on ' +
                            GlobalFunctions.convertDateFormat(
                                value.scheduleVisitorList[position].DATE,
                                "dd MMM yyyy") +
                            ' till' +
                            ' 11: 59 PM. ' +
                            'Please use ' +
                            value.scheduleVisitorList[position].PASS_CODE +
                            ' as entry code at gate. ' +
                            'Google coordinates : <a href=' +
                            mapUrl +
                            '>' +
                            mapUrl +
                            '</a>' +
                            '';
                        var sharedDocument = parse(sharedMsg);
                        String sharedParsedString =
                            parse(sharedDocument.body.text)
                                .documentElement
                                .text;

                        GlobalFunctions.shareData(
                            'PassCode', sharedParsedString);
                      }),
                    ),
                  ),
                  VerticalDivider(),
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: AppIconButton(Icons.call,
                          iconColor: GlobalVariables.green,
                          iconSize: 20, onPressed: () {
                        launch('tel://' +
                            value.scheduleVisitorList[position].MOBILE_NO);
                      }),
                    ),
                  ),
                  VerticalDivider(),
                  Flexible(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: AppIconButton(Icons.delete,
                          iconColor: GlobalVariables.green,
                          iconSize: 20, onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                  return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: displayDeleteExpectedVisitorLayout(
                                          position, value));
                                }));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  scheduleVisitorLayout() {
    return AppContainer(
      /* width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(25),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: GlobalVariables.white),*/
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: primaryText(
              AppLocalizations.of(context).translate('visitor_arriving_on'),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 50,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
              decoration: BoxDecoration(
                  color: GlobalVariables.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GlobalVariables.mediumGreen,
                    width: 2.0,
                  )),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton(
                    items: _scheduleListItems,
                    value: _selectedSchedule,
                    onChanged: (String value) {
                      print('clickable value : ' + value.toString());
                      setState(() {
                        _selectedSchedule = value;
                        print('_selctedItem:' + _selectedSchedule.toString());
                      });
                    },
                    isExpanded: false,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down,
                      iconColor: GlobalVariables.mediumGreen,
                    ),
                    underline: SizedBox(),
                    hint: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: text(
                        "",
                        textColor: GlobalVariables.mediumGreen,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  AppTextField(
                    textHintContent: AppLocalizations.of(context)
                        .translate('name_of_person'),
                    controllerCallback: _nameController,
                    contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    suffixIcon: AppIconButton(
                      Icons.contacts,
                      iconColor: GlobalVariables.mediumGreen,
                      onPressed: () async {
                        Contact contact = await _contactPicker.selectContact();
                        print('contact Name : ' + contact.fullName);
                        print('contact Number : ' +
                            contact.phoneNumber.toString());
                        _contact = contact;
                        setState(() {
                          if (_contact != null) {
                            _nameController.text = _contact.fullName;
                            String phoneNumber = _contact.phoneNumber
                                .toString()
                                .substring(
                                    0,
                                    _contact.phoneNumber
                                            .toString()
                                            .indexOf('(') -
                                        1);
                            _mobileController.text = phoneNumber.toString();
                            // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                          }
                        });
                      },
                    ),
                  ),
                  AppTextField(
                    textHintContent: AppLocalizations.of(context)
                        .translate('contact_number'),
                    controllerCallback: _mobileController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    contentPadding: EdgeInsets.only(top: 14),
                    suffixIcon: AppIconButton(
                      Icons.phone_android,
                      iconColor: GlobalVariables.mediumGreen,
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            alignment: Alignment.topRight,
            //height: 45,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: AppButton(
              textContent: AppLocalizations.of(context).translate('add'),
              onPressed: () {
                verifyVisitorDetails();
              },
            ),
          ),
        ],
      ),
    );
  }

  void changeScheduleDropDownItem(String value) {
    print('clickable value : ' + value.toString());
    _selectedSchedule = value;
    print('_selctedItem:' + _selectedSchedule.toString());
    setState(() {});
  }

  void getScheduleTimeData() {
    _scheduleList = ["Today", "Tomorrow", "Day after tomorrow"];
    for (int i = 0; i < _scheduleList.length; i++) {
      _scheduleListItems.add(DropdownMenuItem(
        value: _scheduleList[i],
        child: text(
          _scheduleList[i],
          textColor: GlobalVariables.green,
        ),
      ));
    }
    _selectedSchedule = _scheduleListItems[0].value;
  }

  void verifyVisitorDetails() {
    if (_nameController.text.length > 0) {
      if (_mobileController.text.length > 0) {
        addScheduleVisitorGatePass();
      } else {
        GlobalFunctions.showToast("Please Enter Contact Number");
      }
    } else {
      GlobalFunctions.showToast("Please Enter Name");
    }
  }

  Future<void> addScheduleVisitorGatePass() async {
    _progressDialog.show();
    Provider.of<GatePass>(context, listen: false)
        .addScheduleVisitorGatePass(
            _nameController.text, _mobileController.text, _selectedSchedule)
        .then((value) async {
      print('add Schedule Visitor value : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        Navigator.of(context).pop();
        DateTime now = DateTime.now();
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        String date = formatter.format(now);
        if (_selectedSchedule == 'Today') {
        } else if (_selectedSchedule == 'Tomorrow') {
          now = now.add(Duration(days: 1));
          date = formatter.format(now);
        } else if (_selectedSchedule == 'Day after tomorrow') {
          now = now.add(Duration(days: 2));
          date = formatter.format(now);
        }
        /*  ScheduleVisitor scheduleVisitor = ScheduleVisitor();
        scheduleVisitor.MOBILE_NO = _mobileController.text;
        scheduleVisitor.NAME = _nameController.text;
        scheduleVisitor.PASS_CODE = value.pass_code;


        scheduleVisitor.DATE = date;
        if (value.scheduleVisitorList.length > 0) {
          value.scheduleVisitorList.insert(0, scheduleVisitor);
        } else {
          value.scheduleVisitorList.add(scheduleVisitor);
        }
        print('date : '+scheduleVisitor.DATE.toString());*/
        String userName = await GlobalFunctions.getDisplayName();
        String googleParameter = await GlobalFunctions.getGoogleCoordinate();
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: displayPassCode(
                        value.pass_code,
                        userName,
                        googleParameter,
                        _nameController.text,
                        _mobileController.text,
                        date),
                  );
                }));
        setState(() {});
        print('passCode : ' + value.pass_code);
      }
      GlobalFunctions.showToast(value.message);
    });
  }

/*
  Future<void> getScheduleVisitorData() async {
    isActivitiesAPICall = true;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient.getGatePassData(societyId, block, flat).then((value) async {
      //_progressDialog.hide();
      Navigator.of(context).pop();
      if (value.status) {
        List<dynamic> _list = value.visitor;
        List<dynamic> _scheduleList = value.schedule_visitor;

        value.visitorList = List<Visitor>.from(_list.map((i) => Visitor.fromJson(i)));
        print('_visitor length : ' + value.visitorList.length.toString());
        value.scheduleVisitorList = List<ScheduleVisitor>.from(
            _scheduleList.map((i) => ScheduleVisitor.fromJson(i)));

        setState(() {
          print('_VID : '+_VID.toString());
        });
        if(_VID!=null) {
          await afterBuild();
        }
      }
    });
  }
*/

  void redirectToPage(String item) {
    if (item == AppLocalizations.of(context).translate('my_gate')) {
      //Redirect to Discover
      _tabController.animateTo(0);
    } else if (item ==
        AppLocalizations.of(context).translate('my_activities')) {
      //Redirect to  Classified
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('helpers')) {
      //Redirect to  Services
      _tabController.animateTo(1);
    } else {
      _tabController.animateTo(0);
    }
    if (pageName != null) {
      pageName = null;
      if (_tabController.index == 0) {
        _handleTabSelection();
      }
    }
  }

  displayPassCode(String pass_code, String userName, String googleParameter,
      String visitorName, String visitorContact, String visitorDate) {
    DateTime date = DateTime.now();
    String todayDate =
        GlobalFunctions.convertDateFormat(date.toIso8601String(), 'dd MMM');
    String currentTime =
        GlobalFunctions.convertDateFormat(date.toIso8601String(), 'hh:mm aa');
    String mapUrl = "http://www.google.com/maps/place/" + googleParameter;
/*

    String msg = 'Entry code created for \n<p style="color:black">' +
        visitorName +
        '</p>' +
        '\n<p style="color:green";"font-size:20px">' +
        pass_code +
        '</p>\n' +
        '<p style="color:gray">Please tell this number at security gate hassle free entry at society</p>';
    var document = parse(msg);
    String parsedString = parse(document.body.text).documentElement.text;*/

    String sharedMsg = userName +
        ' has invited you using <a href="https://societyrun.com/">societyrun.com</a> on ' +
        GlobalFunctions.convertDateFormat(visitorDate, "dd MMM yyyy") +
        ' till' +
        ' 11: 59 PM. ' +
        'Please use ' +
        pass_code +
        ' as entry code at gate. ' +
        'Google coordinates : <a href=' +
        mapUrl +
        '>' +
        mapUrl +
        '</a>' +
        '';
    var sharedDocument = parse(sharedMsg);
    String sharedParsedString =
        parse(sharedDocument.body.text).documentElement.text;

    String line1 = "Entry code created for";
    String line2 = visitorName;
    String line3 = pass_code;
    String line4 =
        "Please tell this number at security gate hassle free entry at society";
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 70.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(20),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: AppIconButton(
                        Icons.close,
                        iconColor: GlobalVariables.green,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    text(
                      line1,
                      textColor: GlobalVariables.black,
                      fontSize: GlobalVariables.textSizeMedium,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    text(
                      line2,
                      textColor: GlobalVariables.black,
                      fontSize: GlobalVariables.textSizeLargeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    text(
                      line3,
                      textColor: GlobalVariables.green,
                      fontSize: GlobalVariables.textSizeNormal,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    text(
                      line4,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeMedium,
                      fontWeight: FontWeight.normal,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                child: Container(
                  child: IconButton(
                      icon: AppIcon(
                        Icons.share,
                        iconColor: GlobalVariables.white,
                        iconSize: GlobalVariables.textSizeLarge,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        GlobalFunctions.shareData(
                            'PassCode', sharedParsedString);
                      }),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            transform: Matrix4.translationValues(0.0, -130.0, 0.0),
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                color: GlobalVariables.white, shape: BoxShape.circle),
            child: CircleAvatar(
              child: SvgPicture.asset(
                GlobalVariables.appIconPath,
                width: 20,
                height: 20,
                color: GlobalVariables.white,
              ),
            ),
          ),
        ),
        /*Align(
          alignment: Alignment.center,
          child: Container(
              transform: Matrix4.translationValues(
                  MediaQuery.of(context).size.width * 0.3,
                  -MediaQuery.of(context).size.width * 0.29,
                  0.0),
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                  color: GlobalVariables.green, shape: BoxShape.circle),
              child: InkWell(
                child: AppIcon(
                  Icons.close,
                  iconColor: GlobalVariables.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ),*/
        //_buildDialogCloseWidget(),
      ],
    );
  }

  displayVisitorInfo(int position, List<Visitor> visitorList) {
    String Time = "";
    String Date = "";
    // String image = value.visitorList[position].IMAGE;
    if (visitorList[position].OUT_TIME.length > 0) {
      if (visitorList[position].STATUS.toLowerCase() == 'out') {
        Time = /*value.visitorList[position].IN_TIME +
            " - " +*/
            visitorList[position].OUT_TIME;
      } else {
        Time = visitorList[position].IN_TIME;
      }
    } else {
      Time = visitorList[position].IN_TIME;
    }

    if (visitorList[position].OUT_DATE.length > 0) {
      if (visitorList[position].STATUS.toLowerCase() == 'out') {
        Date = /* value.visitorList[position].IN_DATE +
            " - " +*/
            visitorList[position].OUT_DATE;
      } else {
        Date = visitorList[position].IN_DATE;
      }
    } else {
      Date = visitorList[position].IN_DATE;
    }

    var visitorStatus = getVisitorAllowStatus(
        visitorList[position].VISITOR_STATUS,
        visitorList[position].VISITOR_USER_STATUS);
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                //width: MediaQuery.of(context).size.width ,
                // padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 90.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(20),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppIconButton(
                          Icons.close,
                          iconColor: GlobalVariables.green,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: BoxDecoration(
                          color: visitorList[position]
                                      .VISITOR_STATUS
                                      .toLowerCase() ==
                                  'no-answer'
                              ? GlobalVariables.grey
                              : visitorList[position].STATUS.toLowerCase() ==
                                      'in'
                                  ? GlobalVariables.skyBlue
                                  : GlobalVariables.grey,
                          borderRadius: BorderRadius.circular(5)),
                      child: text(
                        visitorList[position].VISITOR_STATUS.toLowerCase() ==
                                'no-answer'
                            ? 'No-Answer'
                            : visitorList[position].STATUS.toLowerCase() == 'in'
                                ? 'Arrived'
                                : 'Left',
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeSMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            // Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0.0,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            // borderRadius: BorderRadius.circular(20),
                                            //borderRadius: BorderRadius.all(Radius.circular(50))
                                          ),
                                          child: Image.network(
                                            visitorList[position].IMAGE,
                                            scale: 1.0,
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2,
                                          ),
                                        ),
                                      );
                                    }));
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: GlobalVariables.mediumGreen,
                            backgroundImage:
                                NetworkImage(visitorList[position].IMAGE),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        primaryText(
                          visitorList[position].VISITOR_NAME,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        AppIconButton(
                          Icons.call,
                          iconSize: 20.0,
                          iconColor: GlobalVariables.green,
                          onPressed: () {
                            launch('tel://' + visitorList[position].CONTACT);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Divider(),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: AppIconButton(
                                      Icons.access_time,
                                      iconColor: GlobalVariables.mediumGreen,
                                      iconSize: 20.0,
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    child: text(
                                      Date + ' ' + Time,
                                      textColor: GlobalVariables.grey,
                                      fontSize: GlobalVariables.textSizeSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: AppIconButton(
                                      Icons.person,
                                      iconColor: GlobalVariables.mediumGreen,
                                      iconSize: 20.0,
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: text(
                                    visitorStatus,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: AppIconButton(
                                      Icons.location_on,
                                      iconColor: GlobalVariables.mediumGreen,
                                      iconSize: 20.0,
                                    )),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: text(
                                    visitorList[position].FROM_VISITOR,
                                    textColor: GlobalVariables.grey,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            transform: Matrix4.translationValues(0.0, -100.0, 0.0),
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                color: GlobalVariables.white, shape: BoxShape.circle),
            child: CircleAvatar(
              child: SvgPicture.asset(
                getVisitorStatusIcon(visitorList[position].TYPE),
                width: 50,
                height: 50,
                color: GlobalVariables.white,
              ),
            ),
          ),
        ),
        /*Align(
          alignment: Alignment.center,
          child: Container(
              transform: Matrix4.translationValues(
                  MediaQuery.of(context).size.width * 0.38,
                  -MediaQuery.of(context).size.width * 0.24,
                  0.0),
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                  color: GlobalVariables.green, shape: BoxShape.circle),
              child: InkWell(
                child: AppIcon(
                  Icons.close,
                  iconColor: GlobalVariables.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ),*/
        //_buildDialogCloseWidget(),
      ],
    );
  }

  void _handleTabSelection() {
    if (pageName == null) {
      print('Call _handleTabSelection');
      //if(_tabController.indexIsChanging){
      _callAPI(_tabController.index);
      //}
    }
  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              Provider.of<GatePass>(context, listen: false)
                  .getGatePassData()
                  .then((value) {
                afterBuild(value);
              });
            }
            break;
          case 1:
            {
              if (!AppSocietyPermission.isSocHideHelperPermission) {
                if (!isHelperAPICall) {
                  //getStaffRoleDetailsData();
                  Provider.of<GatePass>(context, listen: false)
                      .getStaffCountData()
                      .then((value) {});
                }
              }
            }
            break;
        }
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  String getVisitorAllowStatus(String visitorStatus, String visitorUserStatus) {
    String status = "";

    if (visitorStatus.toLowerCase() == 'rejected' &&
        visitorUserStatus.toLowerCase() == 'no-answer') {
      status = "Disallowed by security";
    } else if (visitorStatus.toLowerCase() == 'accepted') {
      status = "Allowed by you";
    } else if (visitorStatus.toLowerCase() == 'scheduled') {
      status = "Pre-approved by you";
    } else if (visitorStatus.toLowerCase() == 'rejected') {
      status = "Disallowed by you";
    } else if (visitorStatus.toLowerCase() == 'leave at gate') {
      status = "You asked to leave at gate";
    } else if (visitorStatus.toLowerCase() == 'manual check-in') {
      status = "Allowed by security";
    } else if (visitorStatus.toLowerCase() == 'wait at gate') {
      status = "You asked to wait at gate";
    } else if (visitorStatus.toLowerCase() == 'wrong entry') {
      status = "Marked as Wrong Entry by you";
    }

    return status;
  }

  String getVisitorStatusIcon(String type) {
    var icon = GlobalVariables.visitorIconPath;
    if (type.toLowerCase() == 'delivery') {
      icon = GlobalVariables.deliveryManIconPath;
    } else if (type.toLowerCase() == 'taxi') {
      icon = GlobalVariables.taxiIconPath;
    }
    return icon;
  }

  Future<void> addGatePassWrongEntry(int position, GatePass value) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient
        .addGatePassWrongEntry(
            societyId, value.visitorList[position].ID, 'Wrong Entry')
        .then((value1) {
      if (value1.status) {
        value.visitorList[position].VISITOR_USER_STATUS = 'Wrong Entry';
        setState(() {});
      }
      GlobalFunctions.showToast(value1.message);
      _progressDialog.hide();
    });
  }

  Future<void> deleteExpectedVisitor(int position, GatePass value) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    String srNo = value.scheduleVisitorList[position].SR_NO;
    _progressDialog.show();
    restClient.deleteExpectedVisitor(societyId, srNo).then((value1) {
      _progressDialog.hide();
      if (value1.status) {
        value.scheduleVisitorList.removeAt(position);
        setState(() {});
      }
      GlobalFunctions.showToast(value1.message);
    });
  }

  displayWrongEntryLayout(int position, GatePass value) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('wrong_entry_str'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
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
                        addGatePassWrongEntry(position, value);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
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
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  displayDeleteExpectedVisitorLayout(int position, GatePass value) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('expected_delete'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
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
                        deleteExpectedVisitor(position, value);
                      },
                      child: text(
                        AppLocalizations.of(context).translate('yes'),
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      )),
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
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

/*  getHelperListDataLayout() {
    return _staffList.length>0 ? Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).size.height / 20, 10, 0),
      padding: EdgeInsets.all(20), // height: MediaQuery.of(context).size.height / 0.5,
      decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(20)),

      child: Builder(
          builder: (context) => ListView.builder(
            // scrollDirection: Axis.vertical,
            itemCount: _staffList.length,
            itemBuilder: (context, position) {
              return getHelperListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    ):Container();
  }*/

/*getHelperListItemLayout(int position) {
    List<String> _workHouseList = _staffList[position].ASSIGN_FLATS.split(',');

    var staffImage = _staffList[position].IMAGE;

    var notes = _staffList[position].RATINGS;
    bool isRattingDone = false;
    double totalRate = 0.0;

    List<String> _unitRateList = List<String>();

    if (notes.contains(':')) {
      isRattingDone = true;
    }
    if (isRattingDone) {
      _unitRateList = _staffList[position].RATINGS.split(',');
      for (int i = 0; i < _unitRateList.length; i++) {
        List<String> _rate = List<String>();
        _rate = _unitRateList[i].split(':');
        print('_rate[1] : ' + _rate[1]);
        totalRate += int.parse(_rate[1]);
        print('totalRate : ' + totalRate.toString());
      }
      totalRate = totalRate / _unitRateList.length;
    }

    return InkWell(
      onTap: () async {
        var result = Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseStaffDetails(_staffList[position])));
        if(result=='back'){
          getStaffRoleDetailsData();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        // padding: EdgeInsets.all(10),
        // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              children: [
                //profileLayout(),
                Container(
                    padding: EdgeInsets.all(10),
                    // alignment: Alignment.center,
                    */ /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/ /*
                    child: staffImage.length == 0
                        ? Image.asset(
                      GlobalVariables.componentUserProfilePath,
                      width: 60,
                      height: 60,
                    )
                        : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(staffImage),
                              fit: BoxFit.cover),
                          border: Border.all(
                              color:
                              GlobalVariables.mediumGreen,
                              width: 2.0)),
                    )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            _staffList[position].STAFF_NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  child: Icon(
                                    Icons.star,
                                    color: GlobalVariables.skyBlue,
                                    size: 15,
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  totalRate.toString(),
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    color: GlobalVariables.orangeYellow,
                                    size: 10,
                                  )
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  _workHouseList.length.toString()+' House',
                                  style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Icon(Icons.arrow_forward_ios,color: GlobalVariables.lightGray,),
                ),
              ],
            ),
            position !=_staffList.length-1? Container(
              //color: GlobalVariables.black,
              //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Divider(
                thickness: 1,
                color: GlobalVariables.lightGray,
              ),
            ):Container(),
          ],
        ),
      ),
    );
  }*/

/* Future<void> getStaffRoleDetailsData() async {
    isHelperAPICall=true;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClient.staffRoleDetails(societyId,'').then((value) {
      _progressDialog.hide();
      Navigator.of(context).pop();
      List<dynamic> _list = value.data;
      _staffList = List<Staff>.from(_list.map((i)=>Staff.fromJson(i)));
      setState(() {});

    });

  }*/
}
