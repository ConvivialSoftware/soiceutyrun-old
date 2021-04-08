import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppTextField.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BaseMyGate extends StatefulWidget {
  String pageName;
  String _VID;

  BaseMyGate(this.pageName,this._VID);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyGateState(pageName,this._VID);
  }
}

class MyGateState extends BaseStatefulState<BaseMyGate>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Visitor> _visitorList = new List<Visitor>();
  List<ScheduleVisitor> _scheduleVisitorList = new List<ScheduleVisitor>();

  var name = "", photo = "", societyId, flat, block, duesRs = "", duesDate = "";

  //String _selectedItem,_selectedText="";
  int position = 0;

  //List<DropdownMenuItem<String>> _societyListItems = new List<DropdownMenuItem<String>>();
  // List<LoginResponse> _societyList = new List<LoginResponse>();
  // LoginResponse _selectedSocietyLogin ;
  var username, password;
  ProgressDialog _progressDialog;

  bool isActivitiesAPICall = false;
  bool isHelperAPICall = false;

  List<Staff> _staffList = new List<Staff>();
  List<String> _scheduleList = new List<String>();
  List<DropdownMenuItem<String>> _scheduleListItems =
      new List<DropdownMenuItem<String>>();
  String _selectedSchedule;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  String pageName;
  String _VID;
  MyGateState(this.pageName,this._VID);

  final ContactPicker _contactPicker = ContactPicker();
  Contact _contact;
  List<StaffCount> _staffListCount = List<StaffCount>();

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
  void afterBuild() {
    // executes after build is done
    print('After Build');
    if(_VID!=null && _visitorList.length>0){
      print('VID : '+_VID.toString());
      for(int i=0;i<_visitorList.length;i++){
        if(_visitorList[i].ID==_VID){
          print('_visitorList[i].ID : '+_visitorList[i].ID.toString());
          showDialog(
              context: context,
              builder: (BuildContext context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      child: displayVisitorInfo(i),
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
    // TODO: implement build
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
          title: Text(
            AppLocalizations.of(context).translate('my_gate'),
            style: TextStyle(color: GlobalVariables.white),
          ),
          bottom: getTabLayout(),
          elevation: 0,
        ),
        body: TabBarView(controller: _tabController, children: <Widget>[
          getMyActivitiesLayout(),
          getStaffCategoryLayout(),
          //getHelperLayout(),
        ]),
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

  getMyActivitiesLayout() {
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
                // getSocietyDataLayout(),
                //   activitiesFilterDateLayout(),
                getActivitiesListDataLayout(),
                addActivitiesFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getHelperLayout() {
    //  print('MyDocumentsLayout Tab Call');
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
                    context, 150.0), //ticketOpenClosedLayout(),
                getHelperListDataLayout(),
                /*Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    // margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/40, 0, 0),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            margin: EdgeInsets.all(20),
                            child: Image.asset(
                              GlobalVariables.comingSoonPath,
                              fit: BoxFit.fitWidth,
                            )),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('coming_soon_text'),
                            style: TextStyle(
                                color: GlobalVariables.black, fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                )*/
              ],
            ),
          ),
        ],
      ),
    );
  }



  getStaffCategoryLayout() {
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
                getStaffCategoryListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getStaffCategoryListDataLayout() {
    return _staffListCount.length>0 ? Container(
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
            itemCount: _staffListCount.length,
            itemBuilder: (context, position) {
              return getStaffCategoryListItemLayout(position);
            }, //  scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )),
    ):Container();
  }

  getStaffCategoryListItemLayout(int position) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseStaffListPerCategory(_staffListCount[position].ROLE)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(_staffListCount[position].ROLE),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(_staffListCount[position].Role_count),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Icon(Icons.arrow_forward_ios,color: GlobalVariables.lightGray,),
                ),
              ],
            ),
            Container(
              //color: GlobalVariables.black,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Divider(
                thickness: 1,
                color: GlobalVariables.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getStaffCountData() async {
    isHelperAPICall=true;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClient.staffCount(societyId).then((value) {
      _progressDialog.hide();
      List<dynamic> _list = value.data;
      _staffListCount = List<StaffCount>.from(_list.map((i)=>StaffCount.fromJson(i)));
      setState(() {});
    });

  }



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
                          suffixIcon: Icon(
                            Icons.search,
                            color: GlobalVariables.mediumGreen,
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
                          icon: Icon(
                            Icons.date_range,
                            color: GlobalVariables.mediumGreen,
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
            padding: EdgeInsets.all(10),
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
                    builder: (BuildContext context) =>
                        StatefulBuilder(builder:
                            (BuildContext context,
                            StateSetter setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    25.0)),
                            child: scheduleVisitorLayout(),
                          );
                        }));
              },
              child: Icon(
                Icons.add,
                color: GlobalVariables.white,
              ),
              backgroundColor: GlobalVariables.green,
            ),
          )
        ],
      ),
    );
  }

  getActivitiesListDataLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 20, 10, 0),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _scheduleVisitorList.length,
                      itemBuilder: (context, position) {
                        return getScheduleVisitorListItemLayout(position);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 60),
            child: Builder(
                builder: (context) => ListView.builder(
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _visitorList.length,
                      itemBuilder: (context, position) {
                        return getVisitorsListItemLayout(position);
                      }, //  scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    )),
          ),
        ],
      ),
    );
  }

  getVisitorsListItemLayout(int position) {
    String Time = "";
    String Date = "";
    if (_visitorList[position].OUT_TIME.length > 0) {
      if (_visitorList[position].STATUS.toLowerCase() == 'out') {
        Time = /*_visitorList[position].IN_TIME +
            " - " +*/
            _visitorList[position].OUT_TIME;
      } else {
        Time = _visitorList[position].IN_TIME;
      }
    } else {
      Time = _visitorList[position].IN_TIME;
    }

    if (_visitorList[position].OUT_DATE.length > 0) {
      if (_visitorList[position].STATUS.toLowerCase() == 'out') {
        Date = /*_visitorList[position].IN_DATE +
            " - " +*/
            _visitorList[position].OUT_DATE;
      } else {
        Date = _visitorList[position].IN_DATE;
      }
    } else {
      Date = _visitorList[position].IN_DATE;
    }

    var visitorStatus =
        getVisitorAllowStatus(_visitorList[position].VISITOR_STATUS,_visitorList[position].VISITOR_USER_STATUS);
    var visitorUserStatus = _visitorList[position].VISITOR_USER_STATUS;
  //  print('_visitorList[position].VISITOR_STATUS : ' + visitorStatus);
   // print('_visitorList[position].VISITOR_USER_STATUS : ' + visitorStatus);

    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: displayVisitorInfo(position),
                  );
                }));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  _visitorList[position].IMAGE.isEmpty
                  ? AppAssetsImage(
                    GlobalVariables
                        .componentUserProfilePath,
                    imageWidth:20.0,
                    imageHeight:20.0,
                    borderColor: GlobalVariables.grey,
                    borderWidth: 1.0,
                    fit: BoxFit.cover,
                    radius: 10.0,
                  )
                      : AppNetworkImage(
                    _visitorList[position].IMAGE,
                    imageWidth:20.0,
                    imageHeight:20.0,
                    borderColor: GlobalVariables.grey,
                    borderWidth: 1.0,
                    fit: BoxFit.cover,
                    radius: 13.0,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            child: Text(
                              _visitorList[position].VISITOR_NAME,
                              style: TextStyle(
                                  color: GlobalVariables.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    Date + '  ' + Time,
                                    style: TextStyle(
                                      color: GlobalVariables.grey,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        decoration: BoxDecoration(
                            color:_visitorList[position].VISITOR_STATUS.toLowerCase()=='no-answer'? GlobalVariables.grey:
                                _visitorList[position].STATUS.toLowerCase() ==
                                        'in'
                                    ? GlobalVariables.green
                                    : GlobalVariables.red,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(_visitorList[position].VISITOR_STATUS.toLowerCase()=='no-answer'? 'No-Answer':
                        _visitorList[position].STATUS.toLowerCase() == 'in'
                              ? 'Arrived'
                              : 'Left',
                          style: TextStyle(
                            color: GlobalVariables.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      /* InkWell(
                        onTap: (){
                          launch('tel://' + _visitorList[position].CONTACT);
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
            _visitorList[position].FROM_VISITOR.length>0 && _visitorList[position].FROM_VISITOR!=null? Container(
              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                      child: Icon(
                        Icons.location_on,
                        color: GlobalVariables.mediumGreen,
                        size: 25,
                      )),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
                    child: Text(
                      _visitorList[position].FROM_VISITOR,
                      style: TextStyle(
                        color: GlobalVariables.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ): Container(),
            Container(
              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                      child: Icon(
                        Icons.person,
                        color: GlobalVariables.mediumGreen,
                        size: 25,
                      )),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
                    child: Text(
                      visitorStatus,
                      style: TextStyle(
                        color: GlobalVariables.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 3,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Divider(
                height: 3,
                color: GlobalVariables.lightGray,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment:  MainAxisAlignment.spaceAround,
                children: [
                 Align(
                   alignment: Alignment.center,
                   child: InkWell(
                     onTap: () {
                       if (visitorUserStatus.toLowerCase() != 'wrong entry') {
                         showDialog(
                             context: context,
                             builder: (BuildContext context) =>
                                 StatefulBuilder(
                                     builder: (BuildContext context,
                                         StateSetter setState) {
                                       return Dialog(
                                           shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius
                                                   .circular(25.0)),
                                           child: displayWrongEntryLayout(
                                               position)
                                       );
                                     }));
                       }
                     },
                     child: Row(
                              children: <Widget>[
                                Container(
                                    // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Icon(
                                     /* visitorUserStatus.toLowerCase() != 'wrong entry' ?*/ Icons.block /*: null*/,
                                      color: visitorUserStatus.toLowerCase() != 'wrong entry' ?  GlobalVariables.mediumGreen : GlobalVariables.lightGreen,
                                      size: 25,
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(
                                    visitorUserStatus.toLowerCase() != 'wrong entry' ? 'Wrong Entry' : 'Marked incorrect',
                                    style: TextStyle(
                                      color: visitorUserStatus.toLowerCase() != 'wrong entry' ? GlobalVariables.grey :GlobalVariables.lightGray ,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                   ),
                 ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                            // width: 20,
                            height: 35,
                            child: VerticalDivider(
                              width: 20,
                              color: GlobalVariables.lightGray,
                            ),
                          ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: GlobalVariables.green,
                        ),
                        onPressed: () {
                          launch('tel://' + _visitorList[position].CONTACT);
                        }),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(50, 5, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Icon(
                          Icons.perm_identity,
                          color: GlobalVariables.mediumGreen,
                        )),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        _visitorList[position].VISITOR_NAME,
                        style: TextStyle(
                          color: GlobalVariables.green,
                          fontSize: 12,
                        ),
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
                        icon: Icon(
                          Icons.edit,
                          color: GlobalVariables.white,
                          size: 20,
                        ),
                        label: Text(
                          AppLocalizations.of(context).translate('edit'),
                          style: TextStyle(color: GlobalVariables.white),
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
                          icon: Icon(
                            Icons.cancel,
                            color: GlobalVariables.white,
                            size: 20,
                          ),
                          label: Text(
                            AppLocalizations.of(context).translate('cancel'),
                            style: TextStyle(color: GlobalVariables.white),
                          )),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getScheduleVisitorListItemLayout(int position) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    backgroundColor: GlobalVariables.mediumGreen,
                    child: SvgPicture.asset(
                      getVisitorStatusIcon('visitor'),
                      width: 20,
                      height: 20,
                      color: GlobalVariables.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Text(
                            _scheduleVisitorList[position].NAME,
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  GlobalFunctions.convertDateFormat(
                                      _scheduleVisitorList[position].DATE,
                                      'dd-MM-yyyy'),
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: BoxDecoration(
                          color: GlobalVariables.skyBlue,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        'Expected',
                        style: TextStyle(
                          color: GlobalVariables.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    /* InkWell(
                      onTap: (){
                        launch('tel://' + _visitorList[position].CONTACT);
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
          Row(
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: Icon(
                    Icons.vpn_key,
                    color: GlobalVariables.mediumGreen,
                    size: 25,
                  )),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Text(
                  _scheduleVisitorList[position].PASS_CODE,
                  style: TextStyle(
                    color: GlobalVariables.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 3,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Divider(
              height: 3,
              color: GlobalVariables.lightGray,
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: GlobalVariables.green,
                        ),
                        onPressed: () async {
                          String googleParameter =
                              await GlobalFunctions.getGoogleCoordinate();
                          String userName = await GlobalFunctions.getDisplayName();
                          DateTime earlier = DateTime.parse(
                              _scheduleVisitorList[position].DATE);

                          DateTime date = DateTime.now();
                          String todayDate = GlobalFunctions.convertDateFormat(
                              earlier.toIso8601String(), 'dd MMM');
                          String currentTime =
                              GlobalFunctions.convertDateFormat(
                                  date.toIso8601String(), 'hh:mm aa');
                          String mapUrl = "http://www.google.com/maps/place/" +
                              googleParameter;

                          String sharedMsg = userName +
                              ' has invited you using <a href="https://societyrun.com/">societyrun.com</a> on ' +
                              GlobalFunctions.convertDateFormat(_scheduleVisitorList[position].DATE, "dd MMM yyyy")  +
                              ' till' +
                              ' 11: 59 PM. ' +
                              'Please use ' +
                              _scheduleVisitorList[position].PASS_CODE +
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
                Flexible(
                  flex: 1,
                  child: Container(
                    width: 20,
                    height: 35,
                    child: VerticalDivider(
                      width: 20,
                      color: GlobalVariables.lightGray,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: GlobalVariables.green,
                        ),
                        onPressed: () {
                          launch('tel://' +
                              _scheduleVisitorList[position].MOBILE_NO);
                        }),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: 20,
                    height: 35,
                    child: VerticalDivider(
                      width: 20,
                      color: GlobalVariables.lightGray,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: GlobalVariables.green,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25.0)),
                                          child: displayDeleteExpectedVisitorLayout(position)
                                        );
                                      }));

                        }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  scheduleVisitorLayout() {

    return Container(
      width: MediaQuery.of(context).size.width,
      //height: 400,
//      height: Med,
      decoration: BoxDecoration(
        color: GlobalVariables.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: false,
            child: Align(
              alignment: Alignment(1.15, -1.15),
              child: Container(
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: GlobalVariables.white,
                      size: 30,
                    )),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: GlobalVariables.white),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('visitor_arriving_on'),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  //alignment: Alignment.topLeft,
                                  //width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    /*borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GlobalVariables.mediumGreen,
                      width: 3.0,
                    )*/
                                  ),
                                  child: StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setState){
                                      return DropdownButton(
                                        items: _scheduleListItems,
                                        value: _selectedSchedule,
                                        onChanged: (String value){
                                          print('clickable value : ' + value.toString());
                                          setState(() {
                                            _selectedSchedule = value;
                                            print('_selctedItem:' + _selectedSchedule.toString());
                                          });
                                        },
                                        isExpanded: false,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: GlobalVariables.mediumGreen,
                                        ),
                                        underline: SizedBox(),
                                        hint: Container(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 0, 15, 0),
                                          child: Text(
                                            "",
                                            style: TextStyle(
                                                color:
                                                GlobalVariables.mediumGreen,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState){
                                  return Column(
                                    children: [
                                      AppTextField(textHintContent: AppLocalizations.of(context)
                                          .translate('name_of_person'),
                                        controllerCallback: _nameController,
                                        contentPadding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                        suffixIcon: AppIconButton(Icons.contacts,
                                          iconColor: GlobalVariables.mediumGreen,
                                          onPressed: () async {
                                          Contact contact = await _contactPicker
                                              .selectContact();
                                          print('contact Name : ' +
                                              contact.fullName);
                                          print('contact Number : ' +
                                              contact.phoneNumber.toString());
                                          _contact = contact;
                                          setState(() {
                                            if (_contact != null) {
                                              _nameController.text = _contact.fullName;
                                              String phoneNumber = _contact.phoneNumber
                                                  .toString()
                                                  .substring(0, _contact.phoneNumber.toString().indexOf('(') - 1);
                                              _mobileController.text = phoneNumber.toString();
                                              // _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));
                                            }
                                          });
                                        },),

                                      ),
                                      AppTextField(
                                        textHintContent: AppLocalizations.of(context).translate('contact_number'),
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
                                alignment: Alignment.topLeft,
                                height: 45,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        child: Text(
          _scheduleList[i],
          style: TextStyle(color: GlobalVariables.green),
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
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();
    String userName = await GlobalFunctions.getDisplayName();
    String googleParameter = await GlobalFunctions.getGoogleCoordinate();

    _progressDialog.show();
    restClient
            .addScheduleVisitorGatePass(
                societyId,
                block,
                flat,
                _nameController.text,
                _mobileController.text,
                _selectedSchedule,
                userId)
            .then((value) {
      print('add Schedule Visitor value : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        Navigator.of(context).pop();
        ScheduleVisitor scheduleVisitor = ScheduleVisitor();
        scheduleVisitor.MOBILE_NO = _mobileController.text;
        scheduleVisitor.NAME = _nameController.text;
        scheduleVisitor.PASS_CODE = value.pass_code;

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
        scheduleVisitor.DATE = date;
        if (_scheduleVisitorList.length > 0) {
          _scheduleVisitorList.insert(0, scheduleVisitor);
        } else {
          _scheduleVisitorList.add(scheduleVisitor);
        }
        print('date : '+scheduleVisitor.DATE.toString());
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
                        _mobileController.text,date),
                  );
                }));
        setState(() {});
        print('passCode : ' + value.pass_code);
      }
      GlobalFunctions.showToast(value.message);

      /* {pass_code: 303462, status: true, message: Visitor added successfully}*/
    }) /*.catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            _progressDialog.hide();
          }
          break;
        default:
      }
    })*/
        ;
  }

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

        _visitorList = List<Visitor>.from(_list.map((i) => Visitor.fromJson(i)));
        print('_visitor length : ' + _visitorList.length.toString());
        _scheduleVisitorList = List<ScheduleVisitor>.from(
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
    if(pageName!=null) {
      pageName=null;
      if(_tabController.index==0){
        _handleTabSelection();
      }
    }
  }

  displayPassCode(String pass_code, String userName, String googleParameter, String visitorName, String visitorContact, String visitorDate) {
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
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
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
                    SizedBox(
                      height: 80,
                    ),
                    Text(
                      line1,
                      style: TextStyle(
                        color: GlobalVariables.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      line2,
                      style: TextStyle(
                          color: GlobalVariables.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      line3,
                      style: TextStyle(
                          color: GlobalVariables.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      line4,
                      style: TextStyle(
                          color: GlobalVariables.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
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
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0)),
                ),
                child: Container(
                  child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: GlobalVariables.white,
                        size: 24,
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
        Align(
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
                child: Icon(
                  Icons.close,
                  color: GlobalVariables.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ),
        //_buildDialogCloseWidget(),
      ],
    );
  }

  displayVisitorInfo(int position) {
    String Time = "";
    String Date = "";
    // String image = _visitorList[position].IMAGE;
    if (_visitorList[position].OUT_TIME.length > 0) {
      if (_visitorList[position].STATUS.toLowerCase() == 'out') {
        Time = /*_visitorList[position].IN_TIME +
            " - " +*/
            _visitorList[position].OUT_TIME;
      } else {
        Time = _visitorList[position].IN_TIME;
      }
    } else {
      Time = _visitorList[position].IN_TIME;
    }

    if (_visitorList[position].OUT_DATE.length > 0) {
      if (_visitorList[position].STATUS.toLowerCase() == 'out') {
        Date =/* _visitorList[position].IN_DATE +
            " - " +*/
            _visitorList[position].OUT_DATE;
      } else {
        Date = _visitorList[position].IN_DATE;
      }
    } else {
      Date = _visitorList[position].IN_DATE;
    }

    var visitorStatus =
        getVisitorAllowStatus(_visitorList[position].VISITOR_STATUS,_visitorList[position].VISITOR_USER_STATUS);
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
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
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
                    SizedBox(
                      height: 70,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                      decoration: BoxDecoration(
                          color: _visitorList[position].VISITOR_STATUS.toLowerCase()=='no-answer'? GlobalVariables.grey:
                          _visitorList[position].STATUS.toLowerCase() == 'in' ? GlobalVariables.skyBlue : GlobalVariables.grey,
                          borderRadius: BorderRadius.circular(25)),
                      child: Text(_visitorList[position].VISITOR_STATUS.toLowerCase()=='no-answer'? 'No-Answer':
                        _visitorList[position].STATUS.toLowerCase() == 'in'
                            ? 'Arrived'
                            : 'Left',
                        style: TextStyle(
                            color: GlobalVariables.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                            _visitorList[position].IMAGE,
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
                            radius: 25,
                            backgroundColor: GlobalVariables.mediumGreen,
                            backgroundImage:
                                NetworkImage(_visitorList[position].IMAGE),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          _visitorList[position].VISITOR_NAME,
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Container(
                          //margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                          child: IconButton(
                            icon: Icon(Icons.call),
                            iconSize: 25.0,
                            color: GlobalVariables.mediumGreen,
                            onPressed: () {
                              launch('tel://' + _visitorList[position].CONTACT);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Divider(
                          thickness: 1,
                          color: GlobalVariables.lightGray,
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: Icon(
                                      Icons.access_time,
                                      color: GlobalVariables.mediumGreen,
                                      size: 25,
                                    )),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text(
                                      Date + ' ' + Time,
                                      style: TextStyle(
                                        color: GlobalVariables.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: Icon(
                                      Icons.person,
                                      color: GlobalVariables.mediumGreen,
                                      size: 25,
                                    )),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(
                                    visitorStatus,
                                    style: TextStyle(
                                      color: GlobalVariables.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    alignment: Alignment.topLeft,
                                    child: Icon(
                                      Icons.location_on,
                                      color: GlobalVariables.mediumGreen,
                                      size: 25,
                                    )),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(
                                    _visitorList[position].FROM_VISITOR,
                                    style: TextStyle(
                                      color: GlobalVariables.black,
                                      fontSize: 16,
                                    ),
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
            transform: Matrix4.translationValues(0.0, -120.0, 0.0),
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                color: GlobalVariables.white, shape: BoxShape.circle),
            child: CircleAvatar(
              child: SvgPicture.asset(
                getVisitorStatusIcon(_visitorList[position].TYPE),
                width: 50,
                height: 50,
                color: GlobalVariables.white,
              ),
            ),
          ),
        ),
        Align(
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
                child: Icon(
                  Icons.close,
                  color: GlobalVariables.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ),
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
              if (!isActivitiesAPICall) {
                getScheduleVisitorData();
              }
            }
            break;
          case 1:
            {
              if (!isHelperAPICall) {
                //getStaffRoleDetailsData();
                getStaffCountData();
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

  String getVisitorAllowStatus(String visitorStatus,String visitorUserStatus) {
    String status = "";

    if(visitorStatus.toLowerCase()=='rejected' && visitorUserStatus.toLowerCase()=='no-answer'){
      status = "Disallowed by security";
    }else if (visitorStatus.toLowerCase() == 'accepted') {
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

  Future<void> addGatePassWrongEntry(int position) async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.addGatePassWrongEntry(societyId, _visitorList[position].ID, 'Wrong Entry').then((value) {
      if (value.status) {

        _visitorList[position].VISITOR_USER_STATUS='Wrong Entry';
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
    });
  }

  Future<void> deleteExpectedVisitor(int position) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    String srNo = _scheduleVisitorList[position].SR_NO;
    _progressDialog.show();
    restClient.deleteExpectedVisitor(societyId,srNo).then((value) {
      _progressDialog.hide();
      if (value.status) {
        _scheduleVisitorList.removeAt(position);
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
    });
  }

  displayWrongEntryLayout(int position) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery
          .of(context)
          .size
          .width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Text(
              AppLocalizations.of(context).translate('wrong_entry_str'),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
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
                        addGatePassWrongEntry(position);
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('yes'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('no'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  displayDeleteExpectedVisitorLayout(int position) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery
          .of(context)
          .size
          .width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Text(
              AppLocalizations.of(context).translate('expected_delete'),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
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
                        deleteExpectedVisitor(position);
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('yes'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('no'),
                        style: TextStyle(
                            color: GlobalVariables.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  getHelperListDataLayout() {
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
  }

  getHelperListItemLayout(int position) {
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
                    /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
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
  }

  Future<void> getStaffRoleDetailsData() async {
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

  }
}
