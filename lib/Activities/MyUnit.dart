import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/AlreadyPaid.dart';
import 'package:societyrun/Activities/ComplaintInfoAndComments.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/EditStaffMember.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/VerifyStaffMember.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/ChangeLanguageNotifier.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Documents.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:url_launcher/url_launcher.dart';

import 'base_stateful.dart';

class BaseMyUnit extends StatefulWidget {
  String pageName;
  BaseMyUnit(this.pageName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyUnitState(pageName);
  }
}

class MyUnitState extends BaseStatefulState<BaseMyUnit>
    with SingleTickerProviderStateMixin {
  TabController _tabController;



  //List<Bills> _billList = new List<Bills>();

  List<RecentTransaction> _transactionList = new List<RecentTransaction>();
  List<VehicleRecentTransaction> _vehicleTransactionList =
      new List<VehicleRecentTransaction>();
  List<TicketDescription> _ticketDescriptionList =
      new List<TicketDescription>();
  List<Documents> _documentList = new List<Documents>();

  // List<LedgerResponse> _ledgerResponseList = new List<LedgerResponse>();
  List<Ledger> _ledgerList = new List<Ledger>();
  List<PayOption> _payOptionList = new List<PayOption>();
  bool hasPayTMGateway = false;
  bool hasRazorPayGateway = false;

  List<OpeningBalance> _openingBalanceList = new List<OpeningBalance>();
  List<Bills> _billList = new List<Bills>();

  List<Member> _memberList = new List<Member>();
  List<Staff> _staffList = new List<Staff>();
  List<Vehicle> _vehicleList = new List<Vehicle>();
  List<Complaints> _complaintList = new List<Complaints>();
  List<Complaints> _openComplaintList = new List<Complaints>();
  List<Complaints> _closedComplaintList = new List<Complaints>();

  // ScrollController _scrollController= ScrollController();
  var firstTicketContainerColor = GlobalVariables.mediumBlue;
  var secondTicketContainerColor = GlobalVariables.white;
  
  var firstTicketTextColor = GlobalVariables.white;
  var secondTicketTextColor = GlobalVariables.darkBlue;
  bool isOpenTicket = true;
  bool isClosedTicket = false;

  var firstDocumentsContainerColor = GlobalVariables.mediumBlue;
  var secondDocumentsContainerColor = GlobalVariables.white;
  var firstDocumentsTextColor = GlobalVariables.white;
  var secondDocumentsTextColor = GlobalVariables.darkBlue;
  bool isOpenDocuments = true;
  bool isClosedDocuments = false;

  var name = "", photo = "", societyId, flat, block, duesRs = "", duesDate = "";
  var email='', phone='',consumerId='',societyName='';

  var amount, invoiceNo, referenceNo,billType;

  var _localPath;
  ReceivePort _port = ReceivePort();
  String _taskId;

  //var _progressDialog;

  Map<String, String> _duesMap = Map<String, String>();
  ProgressDialog _progressDialog;
  String pageName;

  // MyUnitState(this.pageName);

  Razorpay _razorpay;

  bool isStoragePermission = false;

  String _selectedPaymentGateway = "PayTM";

  bool isDuesTabAPICall = false;
  bool isHouseholdTabAPICall = false;

  MyUnitState(this.pageName);

  TextEditingController _emailTextController = TextEditingController();
  bool isEditEmail=false;

  @override
  void initState() {
    super.initState();
   /* getDisplayName();
    getLocalPath();
    getDisplayPhoto();
    getMobile();
    getEmail();
    getConsumerID();*/
    getSharedPreferenceData();
    getSharedPreferenceDuesData();
    GlobalFunctions.checkPermission(Permission.storage).then((value) {
      isStoragePermission = value;
    });
    // flutterDownloadInitialize();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    print(pageName.toString());
    _handleTabSelection();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){
        if(status == DownloadTaskStatus.complete){
          _progressDialog.hide();
          print("TASKID >>> $_taskId");
          _openDownloadedFile(_taskId)
              .then((success) {
            if (!success) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(
                  content: Text(
                      'Cannot open this file')));
            }
          });
        }else{
          _progressDialog.hide();
          Scaffold.of(context)
              .showSnackBar(SnackBar(
              content: Text(
                  'Download failed!')));
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);

    // getBillList();
   /* getVehicleRecentTransactionList();


    getTransactionList();
    getTicketDescriptionList();*/
    // getDocumentDescriptionList();
  }

  @override
  void dispose() {
    if (_razorpay != null) {
      _razorpay.clear();
    }
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {

    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    send.send([id, status, progress]);

  }

  void downloadAttachment(var url,var _localPath) async {
    _progressDialog.show();
    String localPath = _localPath + Platform.pathSeparator+"Download";
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    _taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: localPath,
      headers: {"auth": "test_for_sql_encoding"},
      //fileName: "SocietyRunImage/Document",
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );



  }
  Future<bool> _openDownloadedFile(String id) {
    return FlutterDownloader.open(taskId: id);
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
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: GlobalVariables.darkBlue,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context,'back');
            },
            child: Icon(
              Icons.arrow_back,
              color: GlobalVariables.white,
            ),
          ),
          title: Text(
            AppLocalizations.of(context).translate('my_unit'),
            style: TextStyle(color: GlobalVariables.white),
          ),
          bottom: getTabLayout(),
          elevation: 0,
        ),
        body:WillPopScope(child:   TabBarView(controller: _tabController, children: <Widget>[
        Container(
          color: GlobalVariables.veryLightGray,
          child: getMyDuesLayout(),
        ),
        SingleChildScrollView(
          child: getMyHouseholdLayout(),
        ), //  getMyTicketLayout(),
        /* getMyDocumentsLayout(), */ /*SingleChildScrollView(
            child: getMyTanentsLayout(),
          )*/
      ]), onWillPop: onWillPop),

      ),
    );
  }

  getListItemLayout(var position) {
    print("_ledgerList[position].LEDGER : " +
        _ledgerList[position].LEDGER.toString());
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    _ledgerList[position].LEDGER,
                    style: TextStyle(color: GlobalVariables.grey, fontSize: 16),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(5),
                child: Text(
                  "",
                  style:
                      TextStyle(color: GlobalVariables.lightGray, fontSize: 14),
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseViewBill(
                              _ledgerList[position].RECEIPT_NO)));
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Rs. " + _ledgerList[position].AMOUNT,
                    style: TextStyle(
                        color: GlobalVariables.darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: GlobalVariables.mediumBlue,
          height: 1,
        ),
      ],
    );
  }

  duesLayout() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        // color: GlobalVariables.black,
        //width: MediaQuery.of(context).size.width / 1.2,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Card(
          shape: (RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
          elevation: 1.0,
          margin: EdgeInsets.all(20),
          color: GlobalVariables.white,
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    GlobalVariables.whileBGPath,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('total_due'),
                          style: TextStyle(
                              color: GlobalVariables.mediumBlue, fontSize: 14),
                        ),
                        Text(
                          AppLocalizations.of(context).translate('due_date'),
                          style: TextStyle(
                            color: GlobalVariables.mediumBlue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Rs. " + duesRs,
                          style: TextStyle(
                              color: GlobalVariables.darkBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          duesDate,
                          style: TextStyle(
                              color: GlobalVariables.darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      color: GlobalVariables.mediumBlue,
                      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: Divider(
                        height: 1,
                        color: GlobalVariables.mediumBlue,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).translate('pay_now'),
                          style: TextStyle(
                            color: GlobalVariables.darkBlue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getTabLayout() {
    return PreferredSize(
      preferredSize: Size.fromHeight(40.0),
      child: TabBar(
      /*  onTap: (index){
          print('Call onTap');
          _callAPI(index);
        },*/
        tabs: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_dues'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_household'),
            ),
          ), /*Tab(
            text: AppLocalizations.of(context).translate('my_tickets'),
          ),*/
          /* Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Tab(
              text: AppLocalizations.of(context).translate('my_documents'),
            ),
          ), */ /*Tab(
            text: AppLocalizations.of(context).translate('my_tenants'),
          ),*/
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

  /*getBillList() {
    _billList = [
      Bills(
          billType: "Maintainance Bills",
          billRs: "6587.00",
          billDueDate: "25/02/2020"),
      Bills(
          billType: "Electricity Bills",
          billRs: "1343.00",
          billDueDate: "12/03/2020"),
      Bills(
          billType: "Miscellaneous Bills",
          billRs: "2235.00",
          billDueDate: "12/03/2020"),
    ];
  }*/

  getVehicleRecentTransactionList() {
    _vehicleTransactionList = [
      VehicleRecentTransaction(
          vehicleName: "Ford Figo",
          vehicleColor: "Rudy Red",
          vehicleNumber: "MH47-AN1234",
          vehicleType: "4 Wheeler"),
      VehicleRecentTransaction(
          vehicleName: "Honda Activa 5G",
          vehicleColor: "Gray",
          vehicleNumber: "MH47-AQ1234",
          vehicleType: "2 Wheeler"),
      VehicleRecentTransaction(
          vehicleName: "Hero Honda Splender",
          vehicleColor: "",
          vehicleNumber: "MH02-B1234",
          vehicleType: "2 Wheeler"),
    ];
  }

  getTransactionList() {
    _transactionList = [
      RecentTransaction(
          maintenanceMonth: "Maintenance for March'20",
          maintenanceRs: "Rs. 2466.00",
          maintenanceStatus: "Processing"),
      RecentTransaction(
          maintenanceMonth: "Maintenance for Feb'20",
          maintenanceRs: "Rs. 2466.00",
          maintenanceStatus: ""),
      RecentTransaction(
          maintenanceMonth: "Banquet Bill",
          maintenanceRs: "Rs. 2466.00",
          maintenanceStatus: "Processing"),
      RecentTransaction(
          maintenanceMonth: "Maintenance for Dec'19",
          maintenanceRs: "Rs. 2466.00",
          maintenanceStatus:
              ""), /*RecentTransaction(
          maintenanceMonth: "Maintenance for Nov'20",
          maintenanceRs: "Rs. 2466.00"),
      RecentTransaction(
          maintenanceMonth: "Maintenance for Oct'20",
          maintenanceRs: "Rs. 2466.00"),*/
    ];
  }

  getTicketDescriptionList() {
    _ticketDescriptionList = [
      TicketDescription(
          category: "New",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2),
      TicketDescription(
          category: "In-Progress",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2),
      TicketDescription(
          category: "Re-Open",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2),
      TicketDescription(
          category: "New",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2),
      TicketDescription(
          category: "In-Progress",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2),
      TicketDescription(
          category: "Re-Open",
          ticketNo: "123456789",
          ticketTitle: "Water Timing need to Chnage",
          ticketDesc:
              "Currently drinking water timing is morning 6.00 am to 9.00 am. This need to chnage..",
          ticketIssuedOn: "15/05/2019",
          chatCount: 2)
    ];
  }

  /*getDocumentDescriptionList() {
    _documentDescriptionList = [
      DocumentDescription(
          documentTitle: "Rent Agreement",
          documentType: "Others",
          documentDesc: "Authorised rent agreement",
          documentName: "Rent_agreement.pdf",
          documentPostBy: "ABC"),
      DocumentDescription(
          documentTitle: "Annual Financial State",
          documentType: "Financial",
          documentDesc: "Authorised rent agreement",
          documentName: "financial_state18-19.pdf",
          documentPostBy: "XYZ"),
      DocumentDescription(
          documentTitle: "Notice-AGM 2019-20 ",
          documentType: "AGM-EM",
          documentDesc: "AGM Notice for the year of 2019-20",
          documentName: "agm_notice.pdf",
          documentPostBy: "PQR"),
      DocumentDescription(
          documentTitle: "Rent Agreement",
          documentType: "Others",
          documentDesc: "Authorised rent agreement",
          documentName: "Rent_agreement.pdf",
          documentPostBy: "ABC"),
      DocumentDescription(
          documentTitle: "Annual Financial State",
          documentType: "Financial",
          documentDesc: "Authorised rent agreement",
          documentName: "financial_state18-19.pdf",
          documentPostBy: "XYZ"),
      DocumentDescription(
          documentTitle: "Notice-AGM 2019-20 ",
          documentType: "AGM-EM",
          documentDesc: "AGM Notice for the year of 2019-20",
          documentName: "agm_notice.pdf",
          documentPostBy: "PQR"),
    ];
  }
*/
  getMyDuesLayout() {

    print('getMyDuesLayout Tab call');

    return GlobalVariables.isERPAccount ? SingleChildScrollView(
     // scrollDirection: Axis.vertical,
      child: Container(
        width: MediaQuery.of(context).size.width,
        //height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: GlobalVariables.veryLightGray,
        ),
        child: Stack(
          children: <Widget>[
            GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 60, 0, 0),
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _billList.length,
                              itemBuilder: (context, position) {
                                return getBillListItemLayout(position, context);
                              }, //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  ),
                  _ledgerList.length > 0 ? Container(
                    alignment: Alignment.topLeft, //color: GlobalVariables.white,
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('recent_transaction'),
                      style: TextStyle(
                        color: GlobalVariables.darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ):Container(),
                  _ledgerList.length > 0 ? Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: Builder(
                        builder: (context) => ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ledgerList.length,
                              itemBuilder: (context, position) {
                                return getListItemLayout(position);
                              }, //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  ) : Container(),
                  _ledgerList.length>0 ?   Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                      //color: GlobalVariables.white,
                      decoration: BoxDecoration(
                          color: GlobalVariables.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseLedger()));
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('view_more'),
                                style: TextStyle(
                                    color: GlobalVariables.darkBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              child: Icon(
                                Icons.fast_forward,
                                color: GlobalVariables.darkBlue,
                              ),
                            )
                          ],
                        ),
                      )) : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    ) : getNoERPAccountLayout();
  }

  getMyHouseholdLayout() {
    print('MyHouseHold Tab Call');
    return Container(
      width: MediaQuery.of(context)
          .size
          .width, //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
              profileLayout(),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_family'),
                        style: TextStyle(
                          color: GlobalVariables.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        child: RaisedButton(
                      onPressed: () {

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BaseAddNewMember("family")));
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('plus_add'),
                        style: TextStyle(
                            color: GlobalVariables.white, fontSize: 12),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: GlobalVariables.darkBlue)),
                      textColor: GlobalVariables.white,
                      color: GlobalVariables.darkBlue,
                    )),
                  ],
                ),
              ),
              Container(
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(15, 10, 0, 0),
                width: 600,
                height: 190,
                child: Builder(
                    builder: (context) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _memberList.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                _memberList, position, true);
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_staff'),
                        style: TextStyle(
                          color: GlobalVariables.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Container(
                          child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BaseVerifyStaffMember()));
                        },
                        child: Text(
                          AppLocalizations.of(context).translate('plus_add'),
                          style: TextStyle(
                              color: GlobalVariables.white, fontSize: 12),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: GlobalVariables.darkBlue)),
                        textColor: GlobalVariables.white,
                        color: GlobalVariables.darkBlue,
                      )),
                    ),
                  ],
                ),
              ),
              Container(
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(15, 10, 0, 0),
                width: 600,
                height: 190,
                child: Builder(
                    builder: (context) => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _staffList.length,
                          itemBuilder: (context, position) {
                            return getContactListItemLayout(
                                _staffList, position, false);
                          },
                          //  scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )),
              ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_vehicle'),
                        style: TextStyle(
                          color: GlobalVariables.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseAddVehicle()));
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('plus_add'),
                        style: TextStyle(
                            color: GlobalVariables.white, fontSize: 12),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: GlobalVariables.darkBlue)),
                      textColor: GlobalVariables.white,
                      color: GlobalVariables.darkBlue,
                    )),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    //height: 500,
                    //padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    decoration: BoxDecoration(
                        color: GlobalVariables.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Builder(
                        builder: (context) => ListView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // scrollDirection: Axis.horizontal,
                              itemCount: _vehicleList.length,
                              itemBuilder: (context, position) {
                                return getVehicleRecentTransactionListItemLayout(
                                    position);
                              }, //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*getMyTicketLayout() {
    print('MyTicketLayout Tab Call');
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
                ticketOpenClosedLayout(), //ticketFilterLayout(),
                getTicketListDataLayout(), addTicketFabLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }
*/
  getMyDocumentsLayout() {
    print('MyDocumentsLayout Tab Call');
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
                documentOwnCommonLayout(),
                getDocumentListDataLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }
 /* getMyTanentsLayout() {
    print('MyTanents Tab Call');
    return Container(
      width: MediaQuery.of(context)
          .size
          .width, //height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: GlobalVariables.veryLightGray,
      ),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(context, 150.0),
              Column(
                children: <Widget>[
                  Container(
                    //padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(15, 10, 0, 0),
                    width: 600,
                    height: 190,
                    child: Builder(
                        builder: (context) => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _memberList.length,
                              itemBuilder: (context, position) {
                                return getContactListItemLayout(
                                    _memberList, position, true);
                              },
                              //  scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            )),
                  ),
                  Container(
                    alignment:
                        Alignment.topRight, //color: GlobalVariables.white,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                        child: RaisedButton(
                      onPressed: () {},
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('plus_add_delete'),
                        style: TextStyle(
                            color: GlobalVariables.white, fontSize: 12),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: GlobalVariables.green)),
                      textColor: GlobalVariables.white,
                      color: GlobalVariables.green,
                    )),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(30, 20, 20, 0),
                    child: Text(
                      AppLocalizations.of(context).translate('documents'),
                      style: TextStyle(
                        color: GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  getTantentsListDataLayout(),
                  Container(
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      alignment: Alignment.topRight,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('request_documents'),
                          style: TextStyle(
                              color: GlobalVariables.white, fontSize: 12),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: GlobalVariables.green)),
                        textColor: GlobalVariables.white,
                        color: GlobalVariables.green,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
*/
  profileLayout() {
    return InkWell(
      onTap: (){
        navigateToProfilePage();
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          // color: GlobalVariables.black,
          //width: MediaQuery.of(context).size.width / 1.2,
          margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height / 30,
              0, 0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0))),
            elevation: 1.0,
            margin: EdgeInsets.all(20),
            color: GlobalVariables.white,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      GlobalVariables.whileBGPath,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            // alignment: Alignment.center,
                            /* decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)),*/
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: GlobalVariables.mediumBlue,
                              backgroundImage: NetworkImage(photo),
                            ),
                          ),
                          Text(
                            name,
                            style: TextStyle(
                              color: GlobalVariables.darkBlue,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: GlobalVariables.mediumBlue,
                        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Divider(
                          height: 1,
                          color: GlobalVariables.mediumBlue,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          if(phone.length>0) {
                            GlobalFunctions.shareData(name,'Name : ' + name+'\nContact : ' + phone);
                          } else if(email.length>0){
                            GlobalFunctions.shareData(name, 'Name : ' + name+'\nMail ID : '+email);
                          }else{
                            GlobalFunctions.showToast(AppLocalizations.of(context).translate('mobile_email_not_found'));
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Icon(
                                    Icons.share,
                                    color: GlobalVariables.mediumBlue,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('share_address'),
                                    style: TextStyle(
                                      color: GlobalVariables.darkBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*ticketOpenClosedLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 60, 0, 0),
        decoration: BoxDecoration(
          color: GlobalVariables.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: firstTicketContainerColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: FlatButton(
                      //color: GlobalVariables.grey,
                      child: Text(
                        AppLocalizations.of(context).translate('open'),
                        style: TextStyle(
                            fontSize: 15, color: firstTicketTextColor),
                      ),
                      onPressed: () {
                        GlobalFunctions.showToast("OPEN Click");
                        if (!isOpenTicket) {
                          isOpenTicket = true;
                          isClosedTicket = false;
                          firstTicketTextColor = GlobalVariables.white;
                          firstTicketContainerColor =
                              GlobalVariables.mediumGreen;
                          secondTicketTextColor = GlobalVariables.green;
                          secondTicketContainerColor = GlobalVariables.white;
                        }
                        setState(() {});
                      },
                    ),
                  )),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      color: secondTicketContainerColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0))),
                  child: ButtonTheme(
                    minWidth: 190,
                    height: 50,
                    child: FlatButton(
                      child: Text(
                        AppLocalizations.of(context).translate('closed'),
                        style: TextStyle(
                            fontSize: 15, color: secondTicketTextColor),
                      ),
                      onPressed: () {
                        GlobalFunctions.showToast("CLOSED Click");
                        if (!isClosedTicket) {
                          isOpenTicket = false;
                          isClosedTicket = true;
                          firstTicketContainerColor = GlobalVariables.white;
                          firstTicketTextColor = GlobalVariables.green;
                          secondTicketTextColor = GlobalVariables.white;
                          secondTicketContainerColor =
                              GlobalVariables.mediumGreen;
                        }
                        setState(() {});
                      },
                      color: GlobalVariables.transparent,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  ticketFilterLayout() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        //width: MediaQuery.of(context).size.width / 1.1,
        height: 50,
        margin: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 12, 0, 0),
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
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                alignment: Alignment.center,
                height: 50,
                color: GlobalVariables.transparent,
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
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
          ],
        ),
      ),
    );
  }

  addTicketFabLayout() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: FloatingActionButton(
              onPressed: () {
                //GlobalFunctions.showToast('Fab CLick');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseRaiseNewTicket()));
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
*/
  getContactListItemLayout(var _list, int position, bool family) {
    var call = '', email = '',userId;
    if (family) {
      call = _list[position].MOBILE.toString();
      userId = _list[position].ID.toString();
      //    email = _list[position].EMAIL.toString();
    } else {
      call = _list[position].CONTACT.toString();
      userId = _list[position].SID.toString();
    }
    if (call == 'null') {
      call = '';
    }

    return InkWell(
      onTap: (){
        print('userId : '+userId);
        print('societyId : '+societyId);
        if(family) {
          Navigator.push(
              context, MaterialPageRoute(
              builder: (context) =>
                  BaseDisplayProfileInfo(userId, societyId)));
        }/*else{
          print('_list[position] : '+ _list[position].toString());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseEditStaffMember(_list[position])));
        }*/
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: family
                  ? _list[position].PROFILE_PHOTO.length == 0
                      ? Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              color: GlobalVariables.lightBlue),
                        )
                      : CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              NetworkImage(_list[position].PROFILE_PHOTO),
                          backgroundColor: GlobalVariables.lightBlue,
                        )
                  : _list[position].IMAGE.length == 0
                      ? Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              color: GlobalVariables.lightBlue),
                        )
                      : CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(_list[position].IMAGE),
                          backgroundColor: GlobalVariables.lightBlue,
                        ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  family ? _list[position].NAME : _list[position].STAFF_NAME,
                  maxLines: 1,
                  style: TextStyle(color: GlobalVariables.darkBlue, fontSize: 16),
                )),
            call.length > 0
                ? Container(
                    margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: Divider(
                      color: GlobalVariables.mediumBlue,
                      height: 1,
                    ),
                  )
                : Container(),
            call.length > 0
                ? Container(
                    margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            launch("tel://" + call);
                          },
                          child: Container(
                              child: Icon(
                            Icons.call,
                            color: GlobalVariables.lightBlue,
                          )),
                        ),
                        InkWell(
                          onTap: () {
                            String name= family ? _list[position].NAME : _list[position].STAFF_NAME;
                            String title = '';
                            String text = 'Name : ' + name+'\nContact : ' + call;
                            family
                                ? title = _list[position].NAME
                                : title = _list[position].STAFF_NAME;
                            print('titlee : ' + title);
                            GlobalFunctions.shareData(title, text);
                          },
                          child: Container(
                              child: Icon(
                            Icons.share,
                            color: GlobalVariables.lightBlue,
                          )),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

 /* getTicketDescListItemLayout(int position) {
    return InkWell(
      onTap: () {
        GlobalFunctions.showToast(isOpenTicket
            ? _openComplaintList[position].TICKET_NO
            : _closedComplaintList[position].TICKET_NO);
        print('_openComplaintList[position].toString()  : ' +
            _openComplaintList[position].toString());
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BaseComplaintInfoAndComments(isOpenTicket
                    ? _openComplaintList[position]
                    : _closedComplaintList[position])));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          //margin:EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Text('Category',
                              style: TextStyle(
                                  color: GlobalVariables.green, fontSize: 14)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: SvgPicture.asset(
                            GlobalVariables.waterIconPath,
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          15, 0, 0, 0), //alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                              // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(
                                  isOpenTicket
                                      ? _openComplaintList[position].STATUS
                                      : _closedComplaintList[position].STATUS,
                                  style: TextStyle(
                                      color: GlobalVariables.white,
                                      fontSize: 12),
                                ),
                                decoration: BoxDecoration(
                                    color: getTicketCategoryColor(isOpenTicket
                                        ? _openComplaintList[position].STATUS
                                        : _closedComplaintList[position]
                                            .STATUS),
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              Container(
                                child: Text(
                                  'Ticket No: ' +
                                      (isOpenTicket
                                          ? _openComplaintList[position]
                                              .TICKET_NO
                                          : _closedComplaintList[position]
                                              .TICKET_NO),
                                  style: TextStyle(
                                      color: GlobalVariables.green,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          )),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Text(
                                isOpenTicket
                                    ? _openComplaintList[position].SUBJECT
                                    : _closedComplaintList[position].SUBJECT,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text(
                              isOpenTicket
                                  ? _openComplaintList[position].DESCRIPTION
                                  : _closedComplaintList[position].DESCRIPTION,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: GlobalVariables.mediumGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1,
              color: GlobalVariables.mediumGreen,
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(
                        'Issued on: ' +
                            (isOpenTicket
                                ? _openComplaintList[position].DATE
                                : _closedComplaintList[position].DATE),
                        style: TextStyle(color: GlobalVariables.mediumGreen)),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                          child: Icon(
                        Icons.chat_bubble,
                        color: GlobalVariables.lightGray,
                      )),
                      Container(
                        margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                        child: Text(
                            (isOpenTicket
                                    ? _openComplaintList[position].COMMENT_COUNT
                                    : _closedComplaintList[position]
                                        .COMMENT_COUNT) +
                                ' Comments',
                            style:
                                TextStyle(color: GlobalVariables.mediumGreen)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
*/
  getDocumentListItemLayout(int position) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: GlobalVariables.white),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Container(
                    child: SvgPicture.asset(
                      GlobalVariables.pdfIconPath,
                      color: GlobalVariables.mediumBlue,
                      width: 25,
                      height: 40,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        15, 0, 0, 0), //alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                            // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: Container(
                                child: Text(
                                  _documentList[position].TITLE,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: GlobalVariables.darkBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Text(
                                  _documentList[position].DOCUMENT_CATEGORY,
                                  style: TextStyle(
                                      color: GlobalVariables.white,
                                      fontSize: 12),
                                ),
                                decoration: BoxDecoration(
                                    color: getDocumentTypeColor(
                                        _documentList[position]
                                            .DOCUMENT_CATEGORY),
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        )),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Text(
                            _documentList[position].DESCRIPTION,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: GlobalVariables.lightGray),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 1,
            color: GlobalVariables.mediumBlue,
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Divider(
              height: 1,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Visibility(
                  visible:false,
                  child: Row(
                    children: <Widget>[
                      Container(
                          child: SvgPicture.asset(
                            GlobalVariables.downloadIconPath,
                            color: GlobalVariables.lightGray,
                            width: 25,
                            height: 20,
                          )),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                            "Document Name",
                            style: TextStyle(color: GlobalVariables.mediumBlue)),
                      ),
                    ],
                  ),
                ),
                _documentList[position].DOCUMENT.length != null
                    ? Container(
                        // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: InkWell(
                          onTap: () {
                            print("storagePermiassion : " +
                                isStoragePermission.toString());
                            if (isStoragePermission) {
                              GlobalFunctions.downloadAttachment(
                                  _documentList[position].DOCUMENT, _localPath);
                            } else {
                              GlobalFunctions.askPermission(Permission.storage)
                                  .then((value) {
                                if (value) {
                                  GlobalFunctions.downloadAttachment(
                                      _documentList[position].DOCUMENT,
                                      _localPath);
                                } else {
                                  GlobalFunctions.showToast(
                                      AppLocalizations.of(context)
                                          .translate('download_permission'));
                                }
                              });
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              Container(
                                  child: Icon(
                                Icons.attach_file,
                                color: GlobalVariables.mediumBlue,
                              )),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                  "Attachment",
                                  style: TextStyle(
                                    color: GlobalVariables.darkBlue,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Text(
                      _documentList[position].USER_NAME == null
                          ? 'Posted By: - '
                          : 'Posted By: ' + _documentList[position].USER_NAME,
                      style: TextStyle(color: GlobalVariables.mediumBlue)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  documentOwnCommonLayout() {
    return Visibility(
      visible: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 50,
          margin: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height / 60, 0, 0),
          decoration: BoxDecoration(
            color: GlobalVariables.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                        color: firstDocumentsContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0))),
                    child: ButtonTheme(
                      minWidth: 190,
                      height: 50,
                      child: FlatButton(
                        //color: GlobalVariables.grey,
                        child: Text(
                          AppLocalizations.of(context).translate('own'),
                          style: TextStyle(
                              fontSize: 15, color: firstDocumentsTextColor),
                        ),
                        onPressed: () {
                          GlobalFunctions.showToast("OWN Click");
                          if (!isOpenDocuments) {
                            isOpenDocuments = true;
                            isClosedDocuments = false;
                            firstDocumentsTextColor = GlobalVariables.white;
                            firstDocumentsContainerColor =
                                GlobalVariables.mediumBlue;
                            secondDocumentsTextColor = GlobalVariables.darkBlue;
                            secondDocumentsContainerColor =
                                GlobalVariables.white;
                          }
                          setState(() {});
                        },
                      ),
                    )),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                        color: secondDocumentsContainerColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))),
                    child: ButtonTheme(
                      minWidth: 190,
                      height: 50,
                      child: FlatButton(
                        child: Text(
                          AppLocalizations.of(context).translate('common'),
                          style: TextStyle(
                              fontSize: 15, color: secondDocumentsTextColor),
                        ),
                        onPressed: () {
                          GlobalFunctions.showToast("COMMON Click");
                          if (!isClosedDocuments) {
                            isOpenDocuments = false;
                            isClosedDocuments = true;
                            firstDocumentsContainerColor =
                                GlobalVariables.white;
                            firstDocumentsTextColor = GlobalVariables.darkBlue;
                            secondDocumentsTextColor = GlobalVariables.white;
                            secondDocumentsContainerColor =
                                GlobalVariables.mediumBlue;
                          }
                          setState(() {});
                        },
                        color: GlobalVariables.transparent,
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

 /* getDisplayName() async {


    name = await GlobalFunctions.getDisplayName();


    GlobalFunctions.getDisplayName().then((value) {
      name = value;
      print('Name : '+name);

    });
  }*/
/*
  getDisplayPhoto() {
    GlobalFunctions.getPhoto().then((value) {
      photo = value;
      print('Photo : '+photo);

    });
  }

  getMobile() {
    GlobalFunctions.getMobile().then((value) {
      phone = value;
      print('Phone : '+phone);

    });
  }

  getEmail() {
    GlobalFunctions.getUserId().then((value) {
      email = value;
      print('Email ID : '+email);

    });
  }

  getConsumerID() {
    GlobalFunctions.getConsumerID().then((value) {
      consumerId = value;
      print('Consumer ID : '+consumerId);
    });
  }*/

  Future<void> getSharedPreferenceData() async {
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();

    print('Name : '+name);
    print('Photo : '+photo);
    print('Phone : '+phone);
    print('EmailId : '+email);
    print('ConsumerId : '+consumerId);

  }

  getSharedPreferenceDuesData() {
    GlobalFunctions.getSharedPreferenceDuesData().then((map) {
      _duesMap = map;
      duesRs = _duesMap[GlobalVariables.keyDuesRs];
      duesDate = _duesMap[GlobalVariables.keyDuesDate];
      setState(() {});
    });
  }

 /* getTicketListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height / 12, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: isOpenTicket
                    ? _openComplaintList.length
                    : _closedComplaintList.length,
                itemBuilder: (context, position) {
                  return getTicketDescListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }
*/
  getDocumentListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(20, 80, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: _documentList.length,
                itemBuilder: (context, position) {
                  return getDocumentListItemLayout(position);
                }, //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }
  /*getTantentsListDataLayout() {
    return Container(
      //padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Builder(
          builder: (context) => ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: 3,
                itemBuilder: (context, position) {
                  return getDocumentListItemLayout(position);
                },
                //  scrollDirection: Axis.vertical,
                shrinkWrap: true,
              )),
    );
  }*/


  getDocumentTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case "others":
        return GlobalVariables.skyBlue;
        break;
      case "financial":
        return GlobalVariables.orangeYellow;
        break;
      case "agm-em":
        return GlobalVariables.darkBlue;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }
  static getTicketCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "new":
        return GlobalVariables.skyBlue;
        break;
      case "in progress":
        return GlobalVariables.orangeYellow;
        break;
      case "reopen":
        return GlobalVariables.red;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }


  Future<void> getUnitMemberData() async {
    //  _progressDialog.show();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    _progressDialog.show();
    restClient.getMembersData(societyId, block, flat).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

        _memberList = List<Member>.from(_list.map((i) => Member.fromJson(i)));
      }
      getUnitStaffData();
    }).catchError((Object obj) {
 //     if(_progressDialog.isShowing()){
  //      _progressDialog.hide();
  //    }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  Future<void> getUnitStaffData() async {
    //  _progressDialog.show();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    restClient.getStaffData(societyId, block, flat).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;

        _staffList = List<Staff>.from(_list.map((i) => Staff.fromJson(i)));
      }
      getUnitVehicleData();
    }).catchError((Object obj) {
     // if(_progressDialog.isShowing()){
     //   _progressDialog.hide();
    //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  Future<void> getUnitVehicleData() async {
    print('getUnitVehicleData');
    //  _progressDialog.show();
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    block = await GlobalFunctions.getBlock();
    flat = await GlobalFunctions.getFlat();
    restClient.getVehicleData(societyId, block, flat).then((value) {

      if (value.status) {
        List<dynamic> _list = value.data;

        _vehicleList =
            List<Vehicle>.from(_list.map((i) => Vehicle.fromJson(i)));
        print("Vehicle List : " + _list.toString());
      }
      _progressDialog.hide();
      setState(() {
        isHouseholdTabAPICall= true;
      });

      //  getDocumentData();
    }).catchError((Object obj) {
  //    if(_progressDialog.isShowing()){
   //     _progressDialog.hide();
   //   }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  getBillListItemLayout(int position, BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        // color: GlobalVariables.black,
        //width: MediaQuery.of(context).size.width / 1.2,
        margin:
            EdgeInsets.fromLTRB(10, 10, 10, 10), //padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: GlobalVariables.white),
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  GlobalVariables.whileBGPath,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: getBillTypeColor(_billList[position].TYPE),
                        ),
                        child: Text(
                          _billList[position].TYPE != null
                              ? _billList[position].TYPE=='Bill'? 'Maintenance Bill':_billList[position].TYPE
                              : '',
                          style: TextStyle(
                            color: GlobalVariables.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).translate('due_date'),
                        style: TextStyle(
                          color: GlobalVariables.mediumBlue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Rs. " + _billList[position].AMOUNT.toString(),
                          style: TextStyle(
                              color: GlobalVariables.darkBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _billList[position].DUE_DATE != null
                              ? GlobalFunctions.convertDateFormat(
                                  _billList[position].DUE_DATE, "dd-MM-yyyy")
                              : '',
                          style: TextStyle(
                              color: GlobalVariables.darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: GlobalVariables.mediumBlue,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Divider(
                      height: 1,
                      color: GlobalVariables.mediumBlue,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseViewBill(
                                        _billList[position].INVOICE_NO)));
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.visibility,
                                    color: GlobalVariables.mediumBlue,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('view'),
                                    style:
                                        TextStyle(color: GlobalVariables.darkBlue),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print(
                                'hasPayTMGateway' + hasPayTMGateway.toString());
                            print('hasRazorPayGateway' +
                                hasRazorPayGateway.toString());

                            if (hasPayTMGateway && hasRazorPayGateway) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                          child: getListOfPaymentGateway(
                                              context, setState, position),
                                        );
                                      }));
                            } else {
                              if (_payOptionList[0].Status) {
                                if (hasRazorPayGateway) {
                                  _selectedPaymentGateway = 'RazorPay';
                                  redirectToPaymentGateway(position);
                                } else if (hasPayTMGateway) {
                                  //Paytm Payment method execute

                                  _selectedPaymentGateway = 'PayTM';
                                  print('_selectedPaymentGateway' +
                                      _selectedPaymentGateway);

                                  redirectToPaymentGateway(position);
                                } else {
                                  GlobalFunctions.showToast(
                                      "Online Payment Option is not available.");
                                }
                              } else {
                                GlobalFunctions.showToast(
                                    "Online Payment Option is not available.");
                              }
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.payment,
                                    color: GlobalVariables.mediumBlue,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    style:
                                        TextStyle(color: GlobalVariables.darkBlue),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap : (){
                            emailBillDialog(context,position);
                           // getBillMail(_billList[position].INVOICE_NO,_billList[position].TYPE);
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.mail,
                                    color: GlobalVariables.mediumBlue,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('get_bill'),
                                    style:
                                        TextStyle(color: GlobalVariables.darkBlue),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseAlreadyPaid(
                                        _billList[position].INVOICE_NO,
                                        _billList[position].AMOUNT)));
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.payment,
                                    color: GlobalVariables.mediumBlue,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('already_paid'),
                                    style:
                                        TextStyle(color: GlobalVariables.darkBlue),
                                  ),
                                )
                              ],
                            ),
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
    );
  }

  getBillTypeColor(String billType) {
    switch (billType) {
      case "Maintainance Bills":
        {
          return GlobalVariables.skyBlue;
        }
        break;
      case "Electricity Bills":
        {
          return GlobalVariables.orangeYellow;
        }
        break;
      case "Miscellaneous Bills":
        {
          return GlobalVariables.darkBlue;
        }
        break;
      default:
        {
          return GlobalVariables.skyBlue;
        }
        break;
    }
  }

  getVehicleRecentTransactionListItemLayout(int position) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: getIconForVehicle(_vehicleList[position].WHEEL),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    _vehicleList[position].MODEL,
                    style:
                        TextStyle(color: GlobalVariables.darkBlue, fontSize: 16),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(
                  _vehicleList[position].VEHICLE_NO,
                  style: TextStyle(color: GlobalVariables.grey, fontSize: 16),
                ),
              )
            ],
          ),
          position != _vehicleTransactionList.length - 1
              ? Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Divider(
                    color: GlobalVariables.mediumBlue,
                    height: 2,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  getIconForVehicle(String vehicleType) {

    if(vehicleType=='4 Wheeler' || vehicleType=='4' || vehicleType=='four'){
      return Icon(
        Icons.directions_car,
        color: GlobalVariables.mediumBlue,
      );
    }else if(vehicleType=='2 Wheeler' || vehicleType=='2' || vehicleType=='two'){
      return Icon(
        Icons.motorcycle,
        color: GlobalVariables.mediumBlue,
      );
    }else{
      return Icon(
        Icons.motorcycle,
        color: GlobalVariables.mediumBlue,
      );
    }
  }

  void getDocumentData() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    restClient.getDocumentData(societyId).then((value) {
      //  _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;

        _documentList =
            List<Documents>.from(_list.map((i) => Documents.fromJson(i)));

        getAllBillData();
      }
    });
  }

  getAllBillData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    //  _progressDialog.show();
    restClientERP.getAllBillData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;

      _billList = List<Bills>.from(_list.map((i) => Bills.fromJson(i)));

      getLedgerData();
    }).catchError((Object obj) {
    //  if(_progressDialog.isShowing()){
     //   _progressDialog.hide();
    //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  getLedgerData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    //_progressDialog.show();
    restClientERP.getLedgerData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _listLedger = value.ledger;
      List<dynamic> _listOpeningBalance = value.openingBalance;

      //_ledgerResponseList = List<LedgerResponse>.from(_list.map((i)=>Documents.fromJson(i)));

      _ledgerList =
          List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
      _openingBalanceList = List<OpeningBalance>.from(
          _listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));
      _progressDialog.hide();
      setState(() {
        isDuesTabAPICall= true;
      });
    }).catchError((Object obj) {
     // if(_progressDialog.isShowing()){
     //   _progressDialog.hide();
    //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  getReceiptData() async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    //_progressDialog.show();
    restClientERP.getReceiptData(societyId, flat, block, "1").then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;

      //getAllBillData();
    }).catchError((Object obj) {
   //   if(_progressDialog.isShowing()){
    //    _progressDialog.hide();
    //  }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
            //getAllBillData();
          }
          break;
        default:
      }
    });
  }

  Future<void> addOnlinePaymentRequest(String paymentId) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    String paymentDate = DateTime.now().toLocal().year.toString() +
        "-" +
        DateTime.now().toLocal().month.toString() +
        "-" +
        DateTime.now().toLocal().day.toString();

    _progressDialog.show();
    restClientERP
            .addOnlinePaymentRequest(
                societyId,
                flat,
                block,
                invoiceNo,
                amount.toString(),
                paymentId,
                "online Transaction",
                "Razorpay",
                paymentDate)
            .then((value) {
      print("add OnlinepaymentRequest response : " + value.toString());
      _progressDialog.hide();
      if (value.status) {
       // Navigator.of(context).pop('back');
        isDuesTabAPICall=false;
        _callAPI(_tabController.index);
        paymentSuccessDialog(paymentId);
      }else {
        GlobalFunctions.showToast(value.message);
      }
    }) .catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    })
        ;
  }

  Future<void> getPayOption() async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    _progressDialog.show();
    restClient.getPayOptionData(societyId).then((value) {
      //  _progressDialog.hide();
      if (value.status) {
        List<dynamic> _list = value.data;

        _payOptionList =
            List<PayOption>.from(_list.map((i) => PayOption.fromJson(i)));
        print('before ' + _payOptionList.length.toString());
        //   PayOption payOption = PayOption();
        //   payOption.Status = value.status;
        //  payOption.Message = value.message;
        if (_payOptionList.length > 0) {
          _payOptionList[0].Message = value.message;
          _payOptionList[0].Status = value.status;

          // print('after ' + _payOptionList.length.toString());
          print(_payOptionList[0].KEY_ID.toString());

          // print('hasPayTMGateway' + hasPayTMGateway.toString());
          // print('_payOptionList[0].KEY_ID' + _payOptionList[0].KEY_ID.toString());
          // print('_payOptionList[0].SECRET_KEY' + _payOptionList[0].SECRET_KEY.toString());

          if (_payOptionList[0].KEY_ID != null &&
              _payOptionList[0].KEY_ID.length > 0 &&
              _payOptionList[0].SECRET_KEY != null &&
              _payOptionList[0].SECRET_KEY.length > 0) {
            hasRazorPayGateway = true;
          }
          //   print('hasPayTMGateway' + hasPayTMGateway.toString());
          //   print('_payOptionList[0].PAYTM_MERCHANT_KEY' + _payOptionList[0].PAYTM_MERCHANT_KEY.toString());
          //   print('_payOptionList[0].PAYTM_MERCHANT_MID' + _payOptionList[0].PAYTM_MERCHANT_MID.toString());

          if (_payOptionList[0].PAYTM_URL != null &&
              _payOptionList[0].PAYTM_URL.length > 0) {
            hasPayTMGateway = true;
          }

          print('hasPayTMGateway' + hasPayTMGateway.toString());
          print('hasRazorPayGateway' + hasRazorPayGateway.toString());
        }

        /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BaseAddStaffMember()));*/
      }
      getAllBillData();

    }).catchError((Object obj) {
    //  if(_progressDialog.isShowing()){
    //    _progressDialog.hide();
   //   }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }

  _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razor Success Response : ' + response.toString());
   // GlobalFunctions.showToast("Success : " + response.paymentId.toString());
    addOnlinePaymentRequest(response.paymentId);
  }

  _handlePaymentError(PaymentFailureResponse response) {
    print('Razor Error Response : ' + response.message);
    GlobalFunctions.showToast(" " + response.message.toString());
    paymentFailureDialog();
  }

  _handleExternalWallet(ExternalWalletResponse response) {
    print('Razor ExternalWallet Response : ' + response.toString());
    GlobalFunctions.showToast(
        "ExternalWallet : " + response.walletName.toString());
  }

  void openCheckOut(int position, String razorKey) {
    amount = _billList[position].AMOUNT;
    invoiceNo = _billList[position].INVOICE_NO;
    billType = _billList[position].TYPE=='Bill'? 'Maintenance Bill':_billList[position].TYPE;
    print('amount : '+amount.toString());
    print('RazorKey : '+razorKey.toString());
    print('invoiceNo : '+invoiceNo.toString());

    var option = {
      'key': razorKey,
      'amount': amount*100,
      'name': societyName,
      'description': block+' '+flat +'-'+invoiceNo+'/'+billType,
      'payment_capture': 1,
      'prefill': {'contact': phone, 'email': email}
    };

    try {
      _razorpay.open(option);
    } catch (e) {
      debugPrint(e);
    }
  }

  void redirectToPage(String item) {

    print('Call redirectToPage');

    if (item == AppLocalizations.of(context).translate('my_unit')) {
      //Redirect to my Unit
      _tabController.animateTo(0);
    } else if (item == AppLocalizations.of(context).translate('my_dues')) {
      //Redirect to  My Dues
      _tabController.animateTo(0);
      print('redirectToPage '+pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_household')) {
      //Redirect to  My Household
      _tabController.animateTo(1);
      print('redirectToPage '+pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_documents')) {
      //Redirect to  My Documents
      _tabController.animateTo(2);
    } else if (item == AppLocalizations.of(context).translate('my_tenants')) {
      //Redirect to  My Tenants
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

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
  }

  getListOfPaymentGateway(BuildContext context, StateSetter setState, int position) {
    // GlobalFunctions.showToast(_selectedPaymentGateway.toString());
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              AppLocalizations.of(context).translate('select_payment_option'),
              style: TextStyle(color: GlobalVariables.black, fontSize: 18),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: InkWell(
              //  splashColor: GlobalVariables.mediumGreen,
              onTap: () {
                _selectedPaymentGateway = "PayTM";

                //   getListOfPaymentGateway();
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: _selectedPaymentGateway == "PayTM"
                              ? GlobalVariables.darkBlue
                              : GlobalVariables.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _selectedPaymentGateway == "PayTM"
                                ? GlobalVariables.darkBlue
                                : GlobalVariables.mediumBlue,
                            width: 2.0,
                          )),
                      child: Icon(Icons.check, color: GlobalVariables.white),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        AppLocalizations.of(context).translate('pay_tm'),
                        style: TextStyle(
                            color: GlobalVariables.darkBlue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: InkWell(
              //  splashColor: GlobalVariables.mediumGreen,
              onTap: () {
                _selectedPaymentGateway = "RazorPay";
                setState(() {});
                // getListOfPaymentGateway();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: _selectedPaymentGateway != "PayTM"
                              ? GlobalVariables.darkBlue
                              : GlobalVariables.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _selectedPaymentGateway != "PayTM"
                                ? GlobalVariables.darkBlue
                                : GlobalVariables.mediumBlue,
                            width: 2.0,
                          )),
                      child: Icon(Icons.check, color: GlobalVariables.white),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        AppLocalizations.of(context).translate('razor_pay'),
                        style: TextStyle(
                            color: GlobalVariables.darkBlue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  redirectToPaymentGateway(position);
                },
                child: Text(
                  AppLocalizations.of(context).translate('proceed'),
                  style: TextStyle(
                      color: GlobalVariables.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    );
  }

  void redirectToPaymentGateway(int position) {
    if (_selectedPaymentGateway == 'PayTM') {

    //Navigator.of(context).pop();

      showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: displaySocietyRunDisclaimer(),
                );
              }));
    } else if (_selectedPaymentGateway == 'RazorPay') {
      if (_razorpay != null) {
        _razorpay.clear();
      }
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      openCheckOut(position,_payOptionList[0].KEY_ID);
    }
  }

  displaySocietyRunDisclaimer() {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Text(
              AppLocalizations.of(context).translate('disclaimer'),
              style: TextStyle(
                  fontSize: 18,
                  color: GlobalVariables.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 250,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  AppLocalizations.of(context).translate('disclaimer_info'),
                  style: TextStyle(fontSize: 16, color: GlobalVariables.black),
                ),
              ),
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    child: displayConsumerId(),
                                  );
                                }));
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('proceed'),
                        style: TextStyle(
                            color: GlobalVariables.darkBlue,
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
                        AppLocalizations.of(context).translate('cancel'),
                        style: TextStyle(
                            color: GlobalVariables.darkBlue,
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

  displayConsumerId() {
    return Container(
      width: MediaQuery.of(context).size.width/2,
      padding: EdgeInsets.fromLTRB(25,15,25,15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(consumerId,style: TextStyle(
              color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
            ),),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(icon: Icon(Icons.content_copy,color: GlobalVariables.darkBlue,), onPressed: (){
                  Navigator.of(context).pop();
                  ClipboardManager.copyToClipBoard(consumerId).then((value) {
                    GlobalFunctions.showToast("Copied to Clipboard");
                    launch(_payOptionList[0].PAYTM_URL);
                 });
                }),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Text(AppLocalizations.of(context).translate('copy'),style: TextStyle(
                    fontSize: 12
                      ,fontWeight: FontWeight.bold,color: GlobalVariables.darkBlue
                  ),),
                )
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
    }/*else{
      if(!_tabController.indexIsChanging){
        _callAPI(_tabController.index);
      }
    }
*/
  }

  void _callAPI(int index) {

    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch(index){
          case 0: {
            if(!isDuesTabAPICall) {
              if(GlobalVariables.isERPAccount) {
                getPayOption();
              }
            }
          }
          break;
          case 1: {
            if(!isHouseholdTabAPICall) {
              getUnitMemberData();
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

  Future<void> getBillMail(String invoice_no, String type, String emailId) async {
    final dio = Dio();
    final RestClientERP restClientERP = RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP.getBillMail(societyId, type, invoice_no,_emailTextController.text).then((value) {
      print('Response : ' + value.toString());

      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();

    }).catchError((Object obj) {
      if(_progressDialog.isShowing()){
        _progressDialog.hide();
      }
      switch (obj.runtimeType) {
        case DioError:
          {
            final res = (obj as DioError).response;
            print('res : ' + res.toString());
          }
          break;
        default:
      }
    });
  }


  void emailBillDialog(BuildContext context,int position){
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context,
                StateSetter _stateState) {
              isEditEmail ? _emailTextController.text='' :_emailTextController.text = email;

              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(25.0)),
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                //  width: MediaQuery.of(context).size.width/2,
                  //  height: MediaQuery.of(context).size.height/3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Text(AppLocalizations.of(context).translate('email_bill'),style: TextStyle(
                            color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
                        child: Divider(
                          height: 2,
                          color: GlobalVariables.lightGray,
                        ),
                      ),
                      Container(margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
                        child: Text(GlobalFunctions.convertDateFormat(_billList[position].START_DATE, 'dd-MM-yyyy')
                            + ' to '
                            + GlobalFunctions.convertDateFormat(_billList[position].END_DATE, 'dd-MM-yyyy'),style: TextStyle(
                            color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          height: 80,
                         // color: GlobalVariables.mediumGreen,
                         // margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                           /*   Container(
                                child: Text(AppLocalizations.of(context).translate('email_bill_to'),style: TextStyle(
                                    color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.bold
                                ),),
                              ),*/
                              Flexible(
                                flex:3,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: TextFormField(
                                    controller: _emailTextController,
                                    cursorColor: GlobalVariables.black,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      //border: InputBorder.,
                                     // disabledBorder: InputBorder.none,
                                     // enabledBorder: InputBorder.none,
                                     // errorBorder: InputBorder.none,
                                     // focusedBorder: InputBorder.none,
                                     // focusedErrorBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex:1,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: !isEditEmail ? IconButton(icon: Icon(Icons.edit,color: GlobalVariables.darkBlue,size: 24,), onPressed: (){
                                    _emailTextController.clear();
                                    isEditEmail= true;
                                    _stateState(() {});

                                  }) : IconButton(icon: Icon(Icons.cancel,color: GlobalVariables.grey,size: 24,), onPressed: (){
                                    _emailTextController.clear();
                                    _emailTextController.text= email;
                                    isEditEmail= false;
                                    _stateState(() {});
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        child: ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width / 3,
                          child: RaisedButton(
                            color: GlobalVariables.darkBlue,
                            onPressed: () {
                              GlobalFunctions
                                  .checkInternetConnection()
                                  .then((internet) {
                                if (internet) {
                                  if(_emailTextController.text.length>0) {
                                    Navigator.of(
                                        context
                                    ).pop(
                                    );
                                    getBillMail(
                                        _billList[position].INVOICE_NO,
                                        _billList[position].TYPE,
                                        _emailTextController.text
                                    );
                                  }else{
                                    GlobalFunctions.showToast('Please Enter Email ID');
                                  }
                                } else {
                                  GlobalFunctions.showToast(
                                      AppLocalizations.of(context)
                                          .translate(
                                          'pls_check_internet_connectivity'));
                                }
                              });
                            },
                            textColor: GlobalVariables.white,
                            //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: GlobalVariables.darkBlue)),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('email_now'),
                              style: TextStyle(
                                  fontSize: GlobalVariables.largeText),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              );
            }));
  }

  getNoERPAccountLayout() {
    return Container(
      padding: EdgeInsets.all(50),
      //margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      color: GlobalVariables.white,
      //width: MediaQuery.of(context).size.width,
     // height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(GlobalVariables.creditCardPath,width: 300,height: 300,fit: BoxFit.fill,),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Text(AppLocalizations.of(context).translate('erp_acc_not'),
              style: TextStyle(
                  color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
              ),),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width/2,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: ButtonTheme(
              //minWidth: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                color: GlobalVariables.darkBlue,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BaseAboutSocietyRunInfo()));
                },
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: GlobalVariables.darkBlue)),
                child: Text(
                  AppLocalizations.of(context)
                      .translate('i_am_interested'),
                  style: TextStyle(
                      fontSize: GlobalVariables.largeText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToProfilePage() async {

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) =>
            BaseDisplayProfileInfo(userId,societyId)));
  }

 /* void emailBillBottomSheet(BuildContext context,int position) {

    showModalBottomSheet(context: context, builder: (BuildContext _context){
      return StatefulBuilder(builder: (BuildContext context , StateSetter _stateState){
        return Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          //  height: MediaQuery.of(context).size.height/3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(AppLocalizations.of(context).translate('email_bill'),style: TextStyle(
                    color: GlobalVariables.black,fontSize: 16,fontWeight: FontWeight.bold
                ),),
              ),
              Container(
                child: Divider(
                  height: 2,
                  color: GlobalVariables.lightGray,
                ),
              ),
              Container(margin: EdgeInsets.fromLTRB(5, 20, 5, 5),
                child: Text(GlobalFunctions.convertDateFormat(_billList[position].START_DATE, 'dd-MM-yyyy')
                    + ' to '
                    + GlobalFunctions.convertDateFormat(_billList[position].END_DATE, 'dd-MM-yyyy'),style: TextStyle(
                    color: GlobalVariables.black,fontSize: 18,fontWeight: FontWeight.bold
                ),),
              ),
              Container(
                alignment: Alignment.center,
                height: 100,
                margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(AppLocalizations.of(context).translate('email_bill_to'),style: TextStyle(
                          color: GlobalVariables.grey,fontSize: 16,fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      width: 200,
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: TextFormField(
                        controller: _emailTextController,
                        cursorColor: GlobalVariables.black,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.all(5),
                        ),
                      ),
                    ),
                    !isEditEmail ? Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: IconButton(icon: Icon(Icons.edit,color: GlobalVariables.green,size: 24,), onPressed: (){
                        _emailTextController.clear();
                        isEditEmail= true;
                        _stateState(() {});

                      }),
                    ) : Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: IconButton(icon: Icon(Icons.cancel,color: GlobalVariables.grey,size: 24,), onPressed: (){
                        _emailTextController.clear();
                        _emailTextController.text= email;
                        isEditEmail= false;
                        _stateState(() {});
                      }),
                    ),
                  ],
                ),
              ),
              Container(
                height: 45,
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width / 3,
                  child: RaisedButton(
                    color: GlobalVariables.green,
                    onPressed: () {
                      GlobalFunctions
                          .checkInternetConnection()
                          .then((internet) {
                        if (internet) {
                          Navigator.of(context).pop();
                          getBillMail(_billList[position].INVOICE_NO,_billList[position].TYPE,_emailTextController.text);
                        } else {
                          GlobalFunctions.showToast(
                              AppLocalizations.of(context)
                                  .translate(
                                  'pls_check_internet_connectivity'));
                        }
                      });
                    },
                    textColor: GlobalVariables.white,
                    //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: GlobalVariables.green)),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('email_now'),
                      style: TextStyle(
                          fontSize: GlobalVariables.largeText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    });
  }*/

  Future<bool> onWillPop() {
    Navigator.pop(context,'back');
    return Future.value(true);
  }

  paymentSuccessDialog(String paymentId) {

    print('paymentId : '+paymentId.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder:
                (BuildContext context,
                StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(25.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                 // height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: SvgPicture.asset(
                            GlobalVariables.successIconPath,width: 50,height: 50,),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('successful_payment'))),

                      Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('transaction_id')+' : '+paymentId.toString())),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('thank_you_payment'))),
                    ],
                  ),
                ),
              );
            }));

  }

   paymentFailureDialog() {

     return showDialog(
         context: context,
         builder: (BuildContext context) =>
             StatefulBuilder(builder:
                 (BuildContext context,
                 StateSetter setState) {
               return Dialog(
                 shape: RoundedRectangleBorder(
                     borderRadius:

                     BorderRadius.circular(25.0)),
                 child: Container(
                   padding: EdgeInsets.all(20),
                   color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                   //height: MediaQuery.of(context).size.height/4,
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       Container(
                         child: SvgPicture.asset(
                             GlobalVariables.failureIconPath,width: 50,height: 50,),
                       ),
                       Container(
                           margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                           child: Text(AppLocalizations.of(context)
                               .translate('failure_to_pay'))),

                      /* Container(
                           margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                           child: Text(AppLocalizations.of(context)
                               .translate('order_amount'))),*/
                       Container(
                           margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                           child: Text(AppLocalizations.of(context)
                               .translate('payment_failed_try_again'))),
                     ],
                   ),
                   ),
                 );
             }));

   }
}

class RecentTransaction {
  String maintenanceMonth;
  String maintenanceRs;
  String maintenanceStatus;

  RecentTransaction(
      {this.maintenanceMonth, this.maintenanceRs, this.maintenanceStatus});
}

class TicketDescription {
  String category;
  String ticketNo;
  String ticketTitle;
  String ticketDesc;
  String ticketIssuedOn;
  int chatCount;

  TicketDescription(
      {this.category,
      this.ticketNo,
      this.ticketTitle,
      this.ticketDesc,
      this.ticketIssuedOn,
      this.chatCount});
}

class DocumentDescription {
  String documentTitle,
      documentType,
      documentDesc,
      documentName,
      documentPostBy;

  DocumentDescription(
      {this.documentTitle,
      this.documentType,
      this.documentDesc,
      this.documentName,
      this.documentPostBy});
}
/*

class Bills {
  String billType, billRs, billDueDate;
  Bills({this.billType, this.billRs, this.billDueDate});
}
*/

class VehicleRecentTransaction {
  String vehicleName, vehicleColor, vehicleNumber, vehicleType;

  VehicleRecentTransaction(
      {this.vehicleName,
      this.vehicleColor,
      this.vehicleNumber,
      this.vehicleType});
}
