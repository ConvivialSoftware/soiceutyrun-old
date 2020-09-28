
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:societyrun/Activities/base_stateful.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/GatePassResponse.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseMyGate extends StatefulWidget {
  String pageName;
  BaseMyGate(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyGateState(pageName);
  }
}

class MyGateState extends BaseStatefulState<BaseMyGate>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Visitor> _visitorList = new List<Visitor>();
  List<ScheduleVisitor> _scheduleVisitorList = new List<ScheduleVisitor>();

  var name = "", photo = "", societyId, flat, block, duesRs = "", duesDate = "";

  //String _selectedItem,_selectedText="";
  int position=0;
  //List<DropdownMenuItem<String>> _societyListItems = new List<DropdownMenuItem<String>>();
 // List<LoginResponse> _societyList = new List<LoginResponse>();
 // LoginResponse _selectedSocietyLogin ;
  var username, password;
  ProgressDialog _progressDialog;


  bool isActivitiesAPICall = false;
  bool isHelperAPICall = false;

  List<String> _scheduleList = new List<String>();
  List<DropdownMenuItem<String>> _scheduleListItems = new List<DropdownMenuItem<String>>();
  String _selectedSchedule;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  String pageName;
  MyGateState(this.pageName);

  final ContactPicker _contactPicker = ContactPicker();
  Contact _contact;



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
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        getScheduleVisitorData();
      } else {
        GlobalFunctions.showToast(AppLocalizations.of(context)
            .translate('pls_check_internet_connectivity'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      _progressDialog = GlobalFunctions.getNormalProgressDialogInstance(context);
      if (pageName != null) {
        redirectToPage(pageName);
      }

      if(_contact!=null){
        _nameController.text = _contact.fullName;
        String phoneNumber = _contact.phoneNumber.toString().substring(0,_contact.phoneNumber.toString().indexOf('(')-1);

        _mobileController.text = phoneNumber.toString();
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
          getHelperLayout(),
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
           width: MediaQuery.of(context).size.width/2,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_activities'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width/2,
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
             //   getDocumentListDataLayout(),
      Align(
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
                  child: Image.asset(GlobalVariables.comingSoonPath,fit: BoxFit.fitWidth,)
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(AppLocalizations.of(context).translate('coming_soon_text'),style: TextStyle(
                    color: GlobalVariables.black,fontSize: 18
                ),),
              )
            ],
          ),
        ),
      )
              ],
            ),
          ),
        ],
      ),
    );
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
    _dateController.text = DateTime.now().toLocal().day.toString()+"/"+DateTime.now().toLocal().month.toString()+"/"+DateTime.now().toLocal().year.toString();

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
                    style: TextStyle(
                      color: GlobalVariables.green
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        hintText: "Date",
                        hintStyle: TextStyle(color: GlobalVariables.veryLightGray),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: (){
                           // GlobalFunctions.showToast('iDate icon click');
                            GlobalFunctions.getSelectedDate(context).then((value){
                              _dateController.text = value.day.toString()+"/"+value.month.toString()+"/"+value.year.toString();
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
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
               /* Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        BaseExpectedVisitor()));*/
                Dialog infoDialog = Dialog(
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  child: scheduleVisitorLayout(),
                );
                showDialog(
                    context: context, builder: (BuildContext context) => StatefulBuilder(builder: (BuildContext context, StateSetter setState){
                      return infoDialog;
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
    return _visitorList.length>0 ? SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(
                10, MediaQuery.of(context).size.height / 20, 10, 0),
            alignment: Alignment.topLeft,
            child: Text(
              'Schedule Visitors',
              style: TextStyle(color: GlobalVariables.white, fontSize: 20),
            ),
          ),
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, 10, 10, 0),
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
            margin: EdgeInsets.fromLTRB(
                10, 10, 10, 0),
            alignment: Alignment.topLeft,
            child: Text(
              'Visitors',
              style: TextStyle(color: GlobalVariables.green, fontSize: 20),
            ),
          ),
          Container(
            //padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(
                10, 10, 10, 0),
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
    ) :  Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('Oops.!! No Data Found.',style: TextStyle(
            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
        ),),
      ),
    );
  }

  getVisitorsListItemLayout(int position) {

    String Time="";
    String Date="";
    String Image = _visitorList[position].IMAGE;
    if(_visitorList[position].OUT_TIME.length>0){
      Time = "Valid from "+_visitorList[position].IN_TIME + " to "+ _visitorList[position].OUT_TIME;
    }else{
      Time = "Valid from "+_visitorList[position].IN_TIME;
    }

    if(_visitorList[position].OUT_DATE.length>0){
      Date = "Valid for "+_visitorList[position].IN_DATE + " to "+_visitorList[position].OUT_DATE;
    }else{
      Date = "Valid for "+_visitorList[position].IN_DATE;
    }

    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
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
                    radius: 20,
                    backgroundColor: GlobalVariables.mediumGreen,
                    backgroundImage: NetworkImage(Image),
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
                                  _visitorList[position].CONTACT,
                                  style: TextStyle(
                                    color: GlobalVariables.grey,
                                    fontSize: 10,
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
                  // margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      color: GlobalVariables.skyBlue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    _visitorList[position].TYPE,
                    style: TextStyle(
                      color: GlobalVariables.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Icon(Icons.access_time,color: GlobalVariables.mediumGreen,)
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    Time,
                    style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Icon(Icons.date_range,color: GlobalVariables.mediumGreen,)
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(5 , 0, 0, 0),
                  child: Text(
                    Date,
                    style: TextStyle(
                      color: GlobalVariables.green,
                      fontSize: 12,
                    ),
                  ),
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
                      child: Icon(Icons.perm_identity,color: GlobalVariables.mediumGreen,)
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(
                      _visitorList[position].VISITOR_NAME,
                      style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 12,),
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
              child:Row(
                children: <Widget>[
                  Container(
                    height: 30,
                    padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: GlobalVariables.green,
                    ),
                    child: FlatButton.icon(
                      onPressed: (){},
                      icon: Icon(Icons.edit,color: GlobalVariables.white,size: 20,),
                      label:Text(AppLocalizations.of(context).translate('edit'),style: TextStyle(
                          color: GlobalVariables.white
                      ),),),
                  ),
                  Container(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: GlobalVariables.green,
                    ),
                    child: FlatButton.icon(onPressed: (){}, icon: Icon(Icons.cancel,color: GlobalVariables.white,size: 20,), label:Text(AppLocalizations.of(context).translate('cancel'),style: TextStyle(
                        color: GlobalVariables.white
                    ),)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  getScheduleVisitorListItemLayout(int position) {


    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Icon(Icons.person,color: GlobalVariables.mediumGreen,)
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Text(
                                _scheduleVisitorList[position].NAME,
                                style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          launch('tel://' + _scheduleVisitorList[position].MOBILE_NO);
                        },
                        child: Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Icon(Icons.call,color: GlobalVariables.mediumGreen,)
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
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Icon(Icons.vpn_key,color: GlobalVariables.mediumGreen,)
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          _scheduleVisitorList[position].PASS_CODE,
                          style: TextStyle(
                            color: GlobalVariables.black,
                           // fontSize: 14,
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
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Icon(Icons.date_range,color: GlobalVariables.mediumGreen,)
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          _scheduleVisitorList[position].DATE,
                          style: TextStyle(
                            color: GlobalVariables.black,
                          //  fontSize: 14,
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

/*
  Future<void> getAllSocietyData() async {

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    username = await GlobalFunctions.getUserName();
    password = await GlobalFunctions.getPassword();
    societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getAllSocietyData(username, password).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

        _societyList = List<LoginResponse>.from(
            _list.map((i) => LoginResponse.fromJson(i)));

        for (int i = 0; i < _societyList.length; i++) {
          LoginResponse loginResponse = _societyList[i];
          print('"loginResponse.ID : ' + loginResponse.ID);

          print('ShardPref societyId : ' + societyId);
          print('SocietyId ' + loginResponse.SOCIETY_ID);

          if (societyId == loginResponse.SOCIETY_ID) {
            if (_societyListItems.length > 0) {
              _societyListItems.insert(
                  0,
                  DropdownMenuItem(
                    value: loginResponse.ID,
                    child: Text(
                      loginResponse.BLOCK+
                          "-" +
                          loginResponse.FLAT +
                          " " +
                          loginResponse.Society_Name ,
                      style: TextStyle(color: GlobalVariables.black),
                    ),
                  ));
            } else {
              _societyListItems.add(DropdownMenuItem(
                value: loginResponse.ID,
                child: Text(
                  loginResponse.BLOCK+
                      "-" +
                      loginResponse.FLAT +
                      " " +
                      loginResponse.Society_Name ,
                  style: TextStyle(color: GlobalVariables.black),
                ),
              ));
            }
          } else {
            _societyListItems.add(DropdownMenuItem(
              value: loginResponse.ID,
              child: Text(
                loginResponse.BLOCK+
                    "-" +
                    loginResponse.FLAT +
                    " " +
                    loginResponse.Society_Name ,
                style: TextStyle(color: GlobalVariables.black),
              ),
            ));
          }
          print('value: ' + _societyListItems[i].value.toString());
        }
        print('size : ' + _societyListItems.length.toString());
        print('_societyListItems 0 : ' + _societyListItems[0].toString());
        _selectedItem = _societyListItems[0].value;
        _selectedSocietyLogin = _societyList[position];
        _selectedText =  _selectedSocietyLogin.BLOCK+
            "-" +
            _selectedSocietyLogin.FLAT +
            " " +
            _selectedSocietyLogin.Society_Name;
        print('_selectedItem initial : ' + _selectedItem.toString());
        _progressDialog.hide();
        setState(() {
        });
        _selectedSocietyLogin = _societyList[0];
       // _selectedSocietyLogin.PASSWORD = password;
       // GlobalFunctions.saveDataToSharedPreferences(_selectedSocietyLogin);
      }
      getScheduleVisitorData();
    });
  }*/

  scheduleVisitorLayout() {
    _nameController.text ='';
    _mobileController.text='';

    return Container(
      width: MediaQuery.of(context).size.width/0.2,
      height: 400,
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
                                  AppLocalizations.of(context).translate('visitor_arriving_on'),
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
                    )*/),
                                  child: ButtonTheme(
                                    child: DropdownButton(
                                      items: _scheduleListItems,
                                      value: _selectedSchedule,
                                      onChanged: changeScheduleDropDownItem,
                                      isExpanded: false,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: GlobalVariables.mediumGreen,
                                      ),
                                      underline: SizedBox(),
                                      hint: Container(
                                        padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                        child: Text(
                                          "",
                                          style: TextStyle(
                                              color: GlobalVariables.mediumGreen, fontSize: 16,fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: GlobalVariables.mediumGreen,
                                      width: 3.0,
                                    )
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).translate('name_of_person'),
                                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 14),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                          onPressed: () async {
                                            Contact contact = await _contactPicker.selectContact();
                                            print('contact Name : '+contact.fullName);
                                            print('contact Number : '+contact.phoneNumber.toString());
                                            _contact = contact;
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.contacts,color: GlobalVariables.mediumGreen,)),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: GlobalVariables.mediumGreen,
                                      width: 3.0,
                                    )
                                ),
                                child: TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).translate('contact_number'),
                                      hintStyle: TextStyle(color: GlobalVariables.lightGray,fontSize: 14),
                                      border: InputBorder.none
                                  ),
                                ),
                              ),
                          /*    Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: GlobalVariables.mediumGreen,
                                      width: 3.0,
                                    )),
                                child: ButtonTheme(
                                  child: DropdownButton(
                                    items: null,
                                    onChanged: null,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: GlobalVariables.mediumGreen,
                                    ),
                                    underline: SizedBox(),
                                    hint: Text(
                                      AppLocalizations.of(context).translate('flat_no'),
                                      style: TextStyle(
                                          color: GlobalVariables.lightGray, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),*/
                              Container(
                                alignment: Alignment.topLeft,
                                height: 45,
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: ButtonTheme(
                                  // minWidth: MediaQuery.of(context).size.width/2,
                                  child: RaisedButton(
                                    color: GlobalVariables.green,
                                    onPressed: () {

                                      verifyVisitorDetails();

                                    },
                                    textColor: GlobalVariables.white,
                                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),side: BorderSide(color: GlobalVariables.green)
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('add'),
                                      style: TextStyle(
                                          fontSize: GlobalVariables.largeText),
                                    ),
                                  ),
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
    setState(() {
      _selectedSchedule = value;
      print('_selctedItem:' + _selectedSchedule.toString());
    });
  }

  void getScheduleTimeData() {

    _scheduleList = ["Today","Tommorow","Day after tommorow"];
    for(int i=0;i<_scheduleList.length;i++){
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

    if(_nameController.text.length>0){

      if(_mobileController.text.length>0){

        addScheduleVisitorGatePass();

      }else{
        GlobalFunctions.showToast("Please Enter Contact Number");
      }

    }else{
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
    restClient.addScheduleVisitorGatePass(societyId, block, flat, _nameController.text, _mobileController.text, _selectedSchedule, userId).then((value) {
      print('add Schedule Visitor value : '+value.toString());
      _progressDialog.hide();
      if(value.status){
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context,
                    StateSetter setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(25.0)),
                    child: displayPassCode(value.pass_code,userName,googleParameter),
                  );
                }));
      }
      GlobalFunctions.showToast(value.message);

      print('passCode : '+value.pass_code);


      /* {pass_code: 303462, status: true, message: Visitor added successfully}*/

    })/*.catchError((Object obj) {
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
    })*/;

  }

  Future<void> getScheduleVisitorData() async {
    isActivitiesAPICall=true;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient.getGatePassData(societyId, block, flat).then((value) {
      if (value.status) {
        List<dynamic> _list = value.visitor;
        List<dynamic> _scheduleList = value.schedule_visitor;

        _visitorList = List<Visitor>.from(_list.map((i) => Visitor.fromJson(i)));
        _scheduleVisitorList = List<ScheduleVisitor>.from(_scheduleList.map((i) => ScheduleVisitor.fromJson(i)));

        setState(() {
        });
      }

     /* restClient.getGatePassScheduleVisitorData(societyId, block, flat).then((value) {
        if (value.status) {
          List<dynamic> _list = value.data;

        }
       // _progressDialog.hide();
      });*/
      _progressDialog.hide();
    });


  }

  void redirectToPage(String item) {

    if(item==AppLocalizations.of(context).translate('my_gate')){
      //Redirect to Discover
      _tabController.animateTo(0);
    }else if(item==AppLocalizations.of(context).translate('my_activities')){
      //Redirect to  Classified
      _tabController.animateTo(0);
    }else if(item==AppLocalizations.of(context).translate('helpers')){
      //Redirect to  Services
      _tabController.animateTo(1);
    }else{
      _tabController.animateTo(0);
    }


  }

  displayPassCode(String pass_code, String userName, String googleParameter)  {


    DateTime date = DateTime.now();
   // String strDate = DateFormat("dd-MMM").format(date);//date.day.toString().padLeft(2,'0')+'-'+date.month.toString().padLeft(2,'0')+'-'+date.year.toString();
    String todayDate = GlobalFunctions.convertDateFormat(date.toIso8601String(), 'dd MMM');
    //String strTime=date.hour.toString()+'.'+date.minute.toString();
    String currentTime = GlobalFunctions.convertDateFormat(date.toIso8601String(), 'hh:mm aa');

    String mapUrl = "http://www.google.com/maps/place/"+googleParameter;

    String msg = userName + ' has invited you using <a href="https://societyrun.com/">societyrun.com</a> on '+ todayDate + ' between '+currentTime+' - 11: 59 PM. '+'Please use '+pass_code+' as entry code at gate. '+'Google coordinates : <a href='+mapUrl+'>'+mapUrl+'</a>'+'';
    var document = parse(msg);

    String parsedString = parse(document.body.text).documentElement.text;

    print('msg : '+parsedString);
    return Container(
      width: MediaQuery.of(context).size.width/2,
      padding: EdgeInsets.fromLTRB(25,15,25,15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(pass_code,style: TextStyle(
                color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
            ),),
          ),
          Container(
            child: Row(
              children: [
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.share,color: GlobalVariables.green,), onPressed: (){
                        Navigator.of(context).pop();
                        GlobalFunctions.shareData('PassCode', parsedString);
                      }),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(AppLocalizations.of(context).translate('share'),style: TextStyle(
                            fontSize: 12
                            ,fontWeight: FontWeight.bold,color: GlobalVariables.green
                        ),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.content_copy,color: GlobalVariables.green,), onPressed: (){
                        Navigator.of(context).pop();
                        ClipboardManager.copyToClipBoard(pass_code).then((value) {
                          GlobalFunctions.showToast("Copied to Clipboard");
                        });
                      }),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(AppLocalizations.of(context).translate('copy'),style: TextStyle(
                            fontSize: 12
                            ,fontWeight: FontWeight.bold,color: GlobalVariables.green
                        ),),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
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

              }
            }
            break;
          case 1:
            {
              if (!isHelperAPICall) {

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

}


