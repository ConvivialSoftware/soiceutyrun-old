import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/AlreadyPaid.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/VerifyStaffMember.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/Activities/ViewReceipt.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/Complaints.dart';
import 'package:societyrun/Models/Documents.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
  List<Documents> _documentList = new List<Documents>();

  // List<LedgerResponse> _ledgerResponseList = new List<LedgerResponse>();
  List<Ledger> _ledgerList = new List<Ledger>();
  List<Receipt> _pendingList = new List<Receipt>();
  List<PayOption> _payOptionList = new List<PayOption>();
  bool hasPayTMGateway = false;
  bool hasRazorPayGateway = false;

  List<OpeningBalance> _openingBalanceList = new List<OpeningBalance>();
  List<Bills> _billList = new List<Bills>();

  List<Member> _memberList = new List<Member>();
  List<Staff> _staffList = new List<Staff>();
  List<Vehicle> _vehicleList = new List<Vehicle>();

  var firstTicketContainerColor = GlobalVariables.mediumGreen;
  var secondTicketContainerColor = GlobalVariables.white;

  var firstTicketTextColor = GlobalVariables.white;
  var secondTicketTextColor = GlobalVariables.green;
  bool isOpenTicket = true;
  bool isClosedTicket = false;

  var firstDocumentsContainerColor = GlobalVariables.mediumGreen;
  var secondDocumentsContainerColor = GlobalVariables.white;
  var firstDocumentsTextColor = GlobalVariables.white;
  var secondDocumentsTextColor = GlobalVariables.green;
  bool isOpenDocuments = true;
  bool isClosedDocuments = false;

  var userId = "",
      name = "",
      photo = "",
      societyId,
      flat,
      block,
      duesRs = "",
      duesDate = "";
  var email = '', phone = '', consumerId = '', societyName = '';

  var amount, invoiceNo, referenceNo, billType, orderId;

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

  String _selectedPaymentGateway = "RazorPay";

  bool isDuesTabAPICall = false;
  bool isHouseholdTabAPICall = false;

  MyUnitState(this.pageName);

  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _amountTextController = TextEditingController();
  bool isEditEmail = false;
  bool isEditAmount = false;

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
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {
        if (status == DownloadTaskStatus.complete) {
          _progressDialog.hide();
          print("TASKID >>> $_taskId");
          _openDownloadedFile(_taskId).then((success) {
            if (!success) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open this file')));
            }
          });
        } else {
          _progressDialog.hide();
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Download failed!')));
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

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    send.send([id, status, progress]);
  }

  void downloadAttachment(var url, var _localPath) async {
    _progressDialog.show();
    String localPath = _localPath + Platform.pathSeparator + "Download";
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
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
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
          backgroundColor: GlobalVariables.green,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context, 'back');
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
        body: WillPopScope(
            child: TabBarView(controller: _tabController, children: <Widget>[
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
            ]),
            onWillPop: onWillPop),
      ),
    );
  }

  getListItemLayout(var position) {
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
                onTap: () {
                  if (_ledgerList[position].TYPE.toLowerCase().toString() ==
                      'bill') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseViewBill(
                                _ledgerList[position].RECEIPT_NO)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseViewReceipt(
                                _ledgerList[position].RECEIPT_NO)));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Rs. " + _ledgerList[position].AMOUNT,
                    style: TextStyle(
                        color: _ledgerList[position]
                                    .TYPE
                                    .toLowerCase()
                                    .toString() ==
                                'bill'
                            ? GlobalVariables.red
                            : GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: GlobalVariables.mediumGreen,
          height: 1,
        ),
      ],
    );
  }

  getPendingListItemLayout(var position) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      //padding: EdgeInsets.all(5),
                      child: Text(
                        _pendingList[position].NARRATION,
                        style: TextStyle(
                            color: GlobalVariables.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      // padding: EdgeInsets.all(5),
                      child: Text(
                        _pendingList[position].PAYMENT_DATE.length > 0
                            ? GlobalFunctions.convertDateFormat(
                                _pendingList[position].PAYMENT_DATE,
                                'dd-MM-yyyy')
                            : "",
                        style: TextStyle(
                            color: GlobalVariables.grey, fontSize: 16),
                      ),
                    ),
                  ],
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
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Rs. " + _pendingList[position].AMOUNT.toString(),
                    style: TextStyle(
                        color:
                            /*_ledgerList[position].TYPE.toLowerCase().toString() ==
                            'bill' ? GlobalVariables.red :*/
                            GlobalVariables.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: GlobalVariables.mediumGreen,
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
                              color: GlobalVariables.mediumGreen, fontSize: 14),
                        ),
                        Text(
                          AppLocalizations.of(context).translate('due_date'),
                          style: TextStyle(
                            color: GlobalVariables.mediumGreen,
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
                              color: GlobalVariables.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          duesDate,
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      color: GlobalVariables.mediumGreen,
                      margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                      child: Divider(
                        height: 1,
                        color: GlobalVariables.mediumGreen,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).translate('pay_now'),
                          style: TextStyle(
                            color: GlobalVariables.green,
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

  getMyDuesLayout() {
    print('getMyDuesLayout Tab call');
    return GlobalVariables.isERPAccount
        ? SingleChildScrollView(
            // scrollDirection: Axis.vertical,
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: GlobalVariables.veryLightGray,
              ),
              child: Stack(
                children: <Widget>[
                  GlobalFunctions.getAppHeaderWidgetWithoutAppIcon(
                      context, 150.0),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0, MediaQuery.of(context).size.height / 60, 0, 0),
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _billList.length,
                                    itemBuilder: (context, position) {
                                      return getBillListItemLayout(
                                          position, context);
                                    }, //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        ),
                        _pendingList.length > 0
                            ? Container(
                                alignment: Alignment.topLeft,
                                //color: GlobalVariables.white,
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('pending_transaction'),
                                  style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(),
                        _pendingList.length > 0
                            ? Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25))),
                                child: Builder(
                                    builder: (context) => ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: /*_pendingList.length >= 3
                                              ? 3
                                              : */_pendingList.length,
                                          itemBuilder: (context, position) {
                                            return getPendingListItemLayout(
                                                position);
                                          }, //  scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                        )),
                              )
                            : Container(),
                        _pendingList.length > 0
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                //color: GlobalVariables.white,
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(25),
                                        bottomRight: Radius.circular(25))),
                                /*child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BaseLedger()));
                              },
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('view_more'),
                                      style: TextStyle(
                                          color: GlobalVariables.darkRed,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.fast_forward,
                                      color: GlobalVariables.darkRed,
                                    ),
                                  )
                                ],
                              ),
                            )*/
                              )
                            : Container(),
                        _ledgerList.length > 0
                            ? Container(
                                alignment: Alignment.topLeft,
                                //color: GlobalVariables.white,
                                margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('recent_transaction'),
                                  style: TextStyle(
                                    color: GlobalVariables.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(),
                        _ledgerList.length > 0
                            ? Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25))),
                                child: Builder(
                                    builder: (context) => ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _ledgerList.length >= 3
                                              ? 3
                                              : _ledgerList.length,
                                          itemBuilder: (context, position) {
                                            return getListItemLayout(position);
                                          }, //  scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                        )),
                              )
                            : Container(),
                        _ledgerList.length > 0
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                //color: GlobalVariables.white,
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(25),
                                        bottomRight: Radius.circular(25))),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseLedger()));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('view_more'),
                                          style: TextStyle(
                                              color: GlobalVariables.green,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          Icons.fast_forward,
                                          color: GlobalVariables.green,
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : getNoERPAccountLayout();
  }

  getMyHouseholdLayout() {
    print('MyHouseHold Tab Call');
    return Container(
      width: MediaQuery.of(context)
          .size
          .width,
      //height: MediaQuery.of(context).size.height,
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
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_family'),
                        style: TextStyle(
                          color: GlobalVariables.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        child: RaisedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BaseAddNewMember("family")));
                        print('result back : ' + result.toString());
                        if (result != 'back') {
                          getUnitMemberData();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('plus_add'),
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
              ),
              _memberList.length > 0
                  ? Container(
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
                    )
                  : Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(20),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('add_family_details'),
                        style: TextStyle(
                          color: GlobalVariables.grey,
                        ),
                      ),
                    ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_staff'),
                        style: TextStyle(
                          color: GlobalVariables.green,
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
                                  builder: (context) =>
                                      BaseVerifyStaffMember()));
                        },
                        child: Text(
                          AppLocalizations.of(context).translate('plus_add'),
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
                  ],
                ),
              ),
              _staffList.length > 0
                  ? Container(
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
                    )
                  : Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('add_staff_details'),
                        style: TextStyle(
                          color: GlobalVariables.grey,
                        ),
                      ),
                    ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context).translate('my_vehicle'),
                        style: TextStyle(
                          color: GlobalVariables.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        child: RaisedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BaseAddVehicle()));
                        print('result back : ' + result.toString());
                        if (result != 'back') {
                          getUnitMemberData();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('plus_add'),
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
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _vehicleList.length > 0
                      ? Container(
                          //height: 500,
                          //padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                          decoration: BoxDecoration(
                              color: GlobalVariables.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    // scrollDirection: Axis.horizontal,
                                    itemCount: _vehicleList.length,
                                    itemBuilder: (context, position) {
                                      return getVehicleRecentTransactionListItemLayout(
                                          position);
                                    },
                                    //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        )
                      : Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('add_vehicle_details'),
                            style: TextStyle(
                              color: GlobalVariables.grey,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  profileLayout() {
    return InkWell(
      onTap: () {
        navigateToProfilePage();
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          // color: GlobalVariables.black,
          //width: MediaQuery.of(context).size.width / 1.2,
          margin: EdgeInsets.fromLTRB(
              0,
              MediaQuery.of(context).size.height / 30,
              0,
              0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0))),
            elevation: 15.0,
            shadowColor: GlobalVariables.green.withOpacity(0.3),
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
                              child: photo.length == 0
                                  ? Image.asset(
                                      GlobalVariables.componentUserProfilePath,
                                      width: 80,
                                      height: 80,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(photo),
                                              fit: BoxFit.cover),
                                          border: Border.all(
                                              color:
                                                  GlobalVariables.mediumGreen,
                                              width: 2.0)),
                                    )),
                          Text(
                            name,
                            style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: GlobalVariables.mediumGreen,
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Divider(
                          height: 1,
                          color: GlobalVariables.mediumGreen,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (phone.length > 0) {
                            GlobalFunctions.shareData(name,
                                'Name : ' + name + '\nContact : ' + phone);
                          } else if (email.length > 0) {
                            GlobalFunctions.shareData(name,
                                'Name : ' + name + '\nMail ID : ' + email);
                          } else {
                            GlobalFunctions.showToast(
                                AppLocalizations.of(context)
                                    .translate('mobile_email_not_found'));
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
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('share_address'),
                                    style: TextStyle(
                                      color: GlobalVariables.green,
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

  getContactListItemLayout(var _list, int position, bool family) {
    var call = '', email = '', userId;
    if (family) {
      call = _list[position].Phone.toString();
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
      onTap: () {
        print('userId : ' + userId);
        print('societyId : ' + societyId);
        if (family) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseDisplayProfileInfo(userId, societyId)));
        }
        /*else{
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
                            child: Image.asset(
                                GlobalVariables.componentUserProfilePath),
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(
                                    color: GlobalVariables.mediumGreen,
                                    width: 2.0),
                                color: GlobalVariables.lightGreen),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        _list[position].PROFILE_PHOTO),
                                    fit: BoxFit.cover),
                                border: Border.all(
                                    color: GlobalVariables.mediumGreen,
                                    width: 2.0)),
                          )
                    : _list[position].IMAGE.length == 0
                        ? Container(
                            child: Image.asset(
                                GlobalVariables.componentUserProfilePath),
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                border: Border.all(
                                    color: GlobalVariables.mediumGreen,
                                    width: 2.0),
                                color: GlobalVariables.lightGreen),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(_list[position].IMAGE),
                                    fit: BoxFit.cover),
                                border: Border.all(
                                    color: GlobalVariables.mediumGreen,
                                    width: 2.0)),
                          )),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  family ? _list[position].NAME : _list[position].STAFF_NAME,
                  maxLines: 1,
                  style: TextStyle(color: GlobalVariables.green, fontSize: 16),
                )),
            Container(
              margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Divider(
                color: GlobalVariables.mediumGreen,
                height: 1,
              ),
            ),
            call.length > 0
                ? Container(
                    margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            launch("tel://" + call);
                          },
                          child: Container(
                              child: Icon(
                            Icons.call,
                            color: GlobalVariables.lightGreen,
                          )),
                        ),
                        InkWell(
                          onTap: () {
                            String name = family
                                ? _list[position].NAME
                                : _list[position].STAFF_NAME;
                            String title = '';
                            String text =
                                'Name : ' + name + '\nContact : ' + call;
                            family
                                ? title = _list[position].NAME
                                : title = _list[position].STAFF_NAME;
                            print('titlee : ' + title);
                            GlobalFunctions.shareData(title, text);
                          },
                          child: Container(
                              child: Icon(
                            Icons.share,
                            color: GlobalVariables.lightGreen,
                          )),
                        )
                      ],
                    ),*/Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex:1,
                          child: Container(
                            width: double.infinity,
                              child: Icon(
                                Icons.call,
                                color: GlobalVariables.green,
                              ),
                          ),
                        ),
                        Container(
                            //TODO: Divider
                            height: 30,
                            width: 8,
                            child: VerticalDivider(
                              color: GlobalVariables.lightGray,
                            )
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            child: Icon(
                              Icons.share,
                              color: GlobalVariables.grey,
                            ),
                          ),
                        )
                      ],
                    )
                  )
                : family
                    ? InkWell(
                        onTap: () async {
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseEditProfileInfo(userId, societyId)));
                          if (result == 'profile') {
                            getUnitMemberData();
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                          alignment: Alignment.center,
                          child: Text(
                            '+ ' +
                                AppLocalizations.of(context)
                                    .translate('add_phone'),
                            style: TextStyle(
                                color: GlobalVariables.lightGray,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      )
                    : Container()
          ],
        ),
      ),
    );
  }

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
                      color: GlobalVariables.mediumGreen,
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
                                    color: GlobalVariables.green,
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
                Visibility(
                  visible: false,
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
                        child: Text("Document Name",
                            style:
                                TextStyle(color: GlobalVariables.mediumGreen)),
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
                                color: GlobalVariables.mediumGreen,
                              )),
                              Container(
                                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                  "Attachment",
                                  style: TextStyle(
                                    color: GlobalVariables.green,
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
                      style: TextStyle(color: GlobalVariables.mediumGreen)),
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
                                GlobalVariables.mediumGreen;
                            secondDocumentsTextColor = GlobalVariables.green;
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
                            firstDocumentsTextColor = GlobalVariables.green;
                            secondDocumentsTextColor = GlobalVariables.white;
                            secondDocumentsContainerColor =
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
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();

    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
  }

  getSharedPreferenceDuesData() {
    GlobalFunctions.getSharedPreferenceDuesData().then((map) {
      _duesMap = map;
      duesRs = _duesMap[GlobalVariables.keyDuesRs];
      duesDate = _duesMap[GlobalVariables.keyDuesDate];
      setState(() {});
    });
  }

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

  getDocumentTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case "others":
        return GlobalVariables.skyBlue;
        break;
      case "financial":
        return GlobalVariables.orangeYellow;
        break;
      case "agm-em":
        return GlobalVariables.green;
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
      case "on hold":
        return GlobalVariables.orangeYellow;
        break;
      default:
        return GlobalVariables.skyBlue;
        break;
    }
  }

  Future<void> getUnitMemberData() async {
    isHouseholdTabAPICall = true;
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

        for (int i = 0; i < _memberList.length; i++) {
          if (_memberList[i].ID == userId) {
            _memberList.removeAt(i);
            break;
          }
        }
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
      setState(() {});

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
                              ? _billList[position].TYPE == 'Bill'
                                  ? 'Maintenance Bill'
                                  : _billList[position].TYPE
                              : '',
                          style: TextStyle(
                            color: GlobalVariables.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      (_billList[position].AMOUNT -
                                  _billList[position].RECEIVED) <=
                              0
                          ? Text(
                              'Paid',
                              style: TextStyle(
                                  color: GlobalVariables.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(
                              getBillPaymentStatus(position),
                              style: TextStyle(
                                  color: getBillPaymentStatusColor(position),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Rs. " +
                              (_billList[position].AMOUNT -
                                      _billList[position].RECEIVED)
                                  .toString(),
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _billList[position].DUE_DATE != null
                              ? GlobalFunctions.convertDateFormat(
                                  _billList[position].DUE_DATE, "dd-MM-yyyy")
                              : '',
                          style: TextStyle(
                              color: GlobalVariables.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: GlobalVariables.mediumGreen,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Divider(
                      height: 1,
                      color: GlobalVariables.mediumGreen,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (_billList[position]
                                        .TYPE
                                        .toLowerCase()
                                        .toString() ==
                                    'bill' ||
                                _billList[position]
                                        .TYPE
                                        .toLowerCase()
                                        .toString() ==
                                    'invoice') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewBill(
                                          _billList[position].INVOICE_NO)));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewReceipt(
                                          _billList[position].INVOICE_NO)));
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.visibility,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('view'),
                                    style:
                                        TextStyle(color: GlobalVariables.green),
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
                            _amountTextController.text =
                                (_billList[position].AMOUNT -
                                        _billList[position].RECEIVED)
                                    .toString();
                            amount = _amountTextController.text;
                            if (_billList[position].AMOUNT -
                                    _billList[position].RECEIVED >
                                0) {
                              if (hasPayTMGateway && hasRazorPayGateway) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Dialog(
                                            /*shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0)),*/
                                            backgroundColor: Colors.transparent,
                                            elevation: 0.0,
                                            child: getListOfPaymentGateway(
                                                context, setState, position),
                                          );
                                        }));
                              } else {
                                if (_payOptionList[0].Status) {
                                  if (hasRazorPayGateway) {
                                    _selectedPaymentGateway = 'RazorPay';
                                    //redirectToPaymentGateway(position);
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
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position),
                                              );
                                            }));
                                  } else if (hasPayTMGateway) {
                                    //Paytm Payment method execute

                                    _selectedPaymentGateway = 'PayTM';
                                    print('_selectedPaymentGateway' +
                                        _selectedPaymentGateway);

                                    //redirectToPaymentGateway(position);
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
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position),
                                              );
                                            }));
                                  } else {
                                    GlobalFunctions.showToast(
                                        "Online Payment Option is not available.");
                                  }
                                } else {
                                  GlobalFunctions.showToast(
                                      "Online Payment Option is not available.");
                                }
                              }
                            } else {
                              GlobalFunctions.showToast(
                                  AppLocalizations.of(context)
                                      .translate('already_paid'));
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.payment,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    style:
                                        TextStyle(color: GlobalVariables.green),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            emailBillDialog(context, position);
                            // getBillMail(_billList[position].INVOICE_NO,_billList[position].TYPE);
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.mail,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('get_bill'),
                                    style:
                                        TextStyle(color: GlobalVariables.green),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseAlreadyPaid(
                                        _billList[position].INVOICE_NO,
                                        _billList[position].AMOUNT)));
                            if (result == 'back') {
                              getAllBillData();
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.payment,
                                    color: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('already_paid'),
                                    style:
                                        TextStyle(color: GlobalVariables.green),
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
          return GlobalVariables.green;
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
                        TextStyle(color: GlobalVariables.green, fontSize: 16),
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
          position != _vehicleList.length - 1
              ? Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Divider(
                    color: GlobalVariables.mediumGreen,
                    height: 2,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  getIconForVehicle(String vehicleType) {
    if (vehicleType == '4 Wheeler' ||
        vehicleType == '4' ||
        vehicleType == 'four') {
      return Icon(
        Icons.directions_car,
        color: GlobalVariables.mediumGreen,
      );
    } else if (vehicleType == '2 Wheeler' ||
        vehicleType == '2' ||
        vehicleType == 'two') {
      return Icon(
        Icons.motorcycle,
        color: GlobalVariables.mediumGreen,
      );
    } else {
      return Icon(
        Icons.motorcycle,
        color: GlobalVariables.mediumGreen,
      );
    }
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
      List<dynamic> _listLedgerPending = value.pending_request;
      List<dynamic> _listOpeningBalance = value.openingBalance;

      //_ledgerResponseList = List<LedgerResponse>.from(_list.map((i)=>Documents.fromJson(i)));

      _ledgerList = List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
      _pendingList = List<Receipt>.from(
          _listLedgerPending.map((i) => Receipt.fromJson(i)));
      _openingBalanceList = List<OpeningBalance>.from(
          _listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));
      _progressDialog.hide();
      setState(() {});
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

  Future<void> addOnlinePaymentRequest(
      String paymentId, String paymentStatus, String orderId) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    print("AMOUNT>>>>>>>> $amount");

    String paymentDate = DateTime.now().toLocal().year.toString() +
        "-" +
        DateTime.now().toLocal().month.toString().padLeft(2, '0') +
        "-" +
        DateTime.now().toLocal().day.toString().padLeft(2, '0');

    _progressDialog.show();
    restClientERP
        .addOnlinePaymentRequest(
            societyId,
            flat,
            block,
            invoiceNo,
            (amount / 100).toString(),
            paymentId,
            "online Transaction",
            "Razorpay",
            paymentDate,
            paymentStatus,
            orderId)
        .then((value) {
      print("add OnlinepaymentRequest response : " + value.toString());
      _progressDialog.hide();
      if (value.status) {
        // Navigator.of(context).pop('back');
        if (paymentStatus == 'success') {
          isDuesTabAPICall = false;
          _callAPI(_tabController.index);
          paymentSuccessDialog(paymentId);
        } else {
          paymentFailureDialog();
        }
      } else {
        GlobalFunctions.showToast(value.message);
      }
      amount = null;
      invoiceNo = null;
      billType = null;
      orderId = null;
    }).catchError((Object obj) {
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

  Future<void> getPayOption() async {
    isDuesTabAPICall = true;
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
    addOnlinePaymentRequest(response.paymentId, 'success', response.orderId);
  }

  _handlePaymentError(PaymentFailureResponse response) {
    print('Razor Error Response : ' + response.message);
    GlobalFunctions.showToast(" " + response.message.toString());
    addOnlinePaymentRequest('', 'failure', orderId);
  }

  _handleExternalWallet(ExternalWalletResponse response) {
    print('Razor ExternalWallet Response : ' + response.toString());
    GlobalFunctions.showToast(
        "ExternalWallet : " + response.walletName.toString());
  }

  void openCheckOut(
      int position, String razorKey, String orderId, String amount) {
    //amount = _billList[position].AMOUNT;
    invoiceNo = _billList[position].INVOICE_NO;
    billType = _billList[position].TYPE == 'Bill'
        ? 'Maintenance Bill'
        : _billList[position].TYPE;
    print('amount : ' + amount.toString());
    print('RazorKey : ' + razorKey.toString());

    var option = {
      'key': razorKey,
      'amount': amount,
      'name': societyName,
      'order_id': orderId,
      'description': block + ' ' + flat + '-' + invoiceNo + '/' + billType,
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
      print('redirectToPage ' + pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_household')) {
      //Redirect to  My Household
      _tabController.animateTo(1);
      print('redirectToPage ' + pageName.toString());
    } else if (item == AppLocalizations.of(context).translate('my_documents')) {
      //Redirect to  My Documents
      _tabController.animateTo(2);
    } else if (item == AppLocalizations.of(context).translate('my_tenants')) {
      //Redirect to  My Tenants
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

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("External Directory Path" + value.toString());
      _localPath = value;
    });
  }

  getListOfPaymentGateway(
      BuildContext context, StateSetter setState, int position) {
    // GlobalFunctions.showToast(_selectedPaymentGateway.toString());
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
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
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).translate('change_amount'),
                        style: TextStyle(
                            color: GlobalVariables.black, fontSize: 18),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(),
                            ),
                            Flexible(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Rs. ',
                                      style: TextStyle(
                                          color: GlobalVariables.green,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      child: TextFormField(
                                        controller: _amountTextController,
                                        readOnly: isEditAmount ? false : true,
                                        cursorColor: GlobalVariables.green,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: GlobalVariables.green,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          border: isEditAmount
                                              ? new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color: Colors.green))
                                              : InputBorder.none,
                                          // disabledBorder: InputBorder.none,
                                          // enabledBorder: InputBorder.none,
                                          // errorBorder: InputBorder.none,
                                          // focusedBorder: InputBorder.none,
                                          // focusedErrorBorder: InputBorder.none,
                                          // contentPadding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: !isEditAmount
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: GlobalVariables.green,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              _amountTextController.clear();
                                              isEditAmount = true;
                                              setState(() {});
                                            })
                                        : IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: GlobalVariables.grey,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              _amountTextController.clear();
                                              _amountTextController.text =
                                                  amount;
                                              isEditAmount = false;
                                              setState(() {});
                                            }),
                                  ),
                                ],
                              ),
                            ),

                            /* Flexible(
                            flex: 1,
                            child: Container(
                              child: AutoSizeTextField(
                                controller: _amountTextController,
                                readOnly: isEditAmount ? false : true,
                                cursorColor:  GlobalVariables.black,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: GlobalVariables.green,fontSize: 20 ,fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: isEditAmount ? new UnderlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.black
                                      )
                                  ): InputBorder.none,
                                  // disabledBorder: InputBorder.none,
                                  // enabledBorder: InputBorder.none,
                                  // errorBorder: InputBorder.none,
                                  // focusedBorder: InputBorder.none,
                                  // focusedErrorBorder: InputBorder.none,
                                  // contentPadding: EdgeInsets.all(5),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: !isEditAmount
                                  ? IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: GlobalVariables.green,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _amountTextController.clear();
                                    isEditAmount = true;
                                    setState(() {});
                                  })
                                  : IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: GlobalVariables.grey,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _amountTextController.clear();
                                    _amountTextController.text = amount;
                                    isEditAmount = false;
                                    setState(() {});
                                  }),
                            ),
                          )*/
                          ],
                        )),
                    /* Container(
                      //height: 60,
                      //alignment: Alignment.center,
                      // color: GlobalVariables.mediumGreen,
                       margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text('Rs. ',style: TextStyle(
                                color: GlobalVariables.green,fontSize: 20,fontWeight: FontWeight.bold
                            ),),
                          ),
                          Flexible(
                            //flex: 3,
                            child: Container(
                              child: TextFormField(
                                controller: _amountTextController,
                                readOnly: isEditAmount ? false : true,
                                cursorColor:  GlobalVariables.black,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: GlobalVariables.green,fontSize: 20 ,fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  border: isEditAmount ? new UnderlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.black
                                      )
                                  ): InputBorder.none,
                                  // disabledBorder: InputBorder.none,
                                  // enabledBorder: InputBorder.none,
                                  // errorBorder: InputBorder.none,
                                  // focusedBorder: InputBorder.none,
                                  // focusedErrorBorder: InputBorder.none,
                                  // contentPadding: EdgeInsets.all(5),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            //flex: 1,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: !isEditAmount
                                  ? IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: GlobalVariables.green,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _amountTextController.clear();
                                    isEditAmount = true;
                                    setState(() {});
                                  })
                                  : IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: GlobalVariables.grey,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _amountTextController.clear();
                                    _amountTextController.text = amount;
                                    isEditAmount = false;
                                    setState(() {});
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),*/
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('select_payment_option'),
                        style: TextStyle(
                            color: GlobalVariables.black, fontSize: 18),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
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
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway != "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Image.asset(
                                  GlobalVariables.razorPayIconPath,
                                  height: 40,
                                  width: 100,
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
                                        ? GlobalVariables.green
                                        : GlobalVariables.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _selectedPaymentGateway == "PayTM"
                                          ? GlobalVariables.green
                                          : GlobalVariables.mediumGreen,
                                      width: 2.0,
                                    )),
                                child: Icon(Icons.check,
                                    color: GlobalVariables.white),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Image.asset(
                                  GlobalVariables.payTMIconPath,
                                  height: 20,
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(10, 15, 0, 5),
                      child: Text(
                        AppLocalizations.of(context).translate('trans_charges'),
                        style: TextStyle(
                            color: GlobalVariables.grey, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: GlobalVariables.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0)),
                ),
                child: InkWell(
                  onTap: () {
                    if (int.parse(_amountTextController.text) >
                        (_billList[position].AMOUNT -
                            _billList[position].RECEIVED)) {
                      GlobalFunctions.showToast(
                          'Amount must be lesser equal to bill amount');
                    } else {
                      Navigator.of(context).pop();
                      redirectToPaymentGateway(
                          position, _amountTextController.text);
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        AppLocalizations.of(context).translate('proceed'),
                        style: TextStyle(
                            color: GlobalVariables.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
              transform: Matrix4.translationValues(
                  MediaQuery.of(context).size.width * 0.38,
                  -MediaQuery.of(context).size.width * 0.28,
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

  void redirectToPaymentGateway(int position, String textAmount) {
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
      getRazorPayOrderID(position, _payOptionList[0].KEY_ID,
          _payOptionList[0].SECRET_KEY, int.parse(textAmount));
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
                        AppLocalizations.of(context).translate('cancel'),
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

  displayConsumerId() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              consumerId,
              style: TextStyle(
                  color: GlobalVariables.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      color: GlobalVariables.green,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClipboardManager.copyToClipBoard(consumerId)
                          .then((value) {
                        GlobalFunctions.showToast("Copied to Clipboard");
                        launch(_payOptionList[0].PAYTM_URL);
                      });
                    }),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Text(
                    AppLocalizations.of(context).translate('copy'),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.green),
                  ),
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
    }
    /*else{
      if(!_tabController.indexIsChanging){
        _callAPI(_tabController.index);
      }
    }
*/
  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              if (!isDuesTabAPICall) {
                if (GlobalVariables.isERPAccount) {
                  getPayOption();
                }
              }
            }
            break;
          case 1:
            {
              if (!isHouseholdTabAPICall) {
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

  Future<void> getBillMail(
      String invoice_no, String type, String emailId) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getBillMail(societyId, type, invoice_no, _emailTextController.text)
        .then((value) {
      print('Response : ' + value.toString());

      GlobalFunctions.showToast(value.message);
      _progressDialog.hide();
    }).catchError((Object obj) {
      if (_progressDialog.isShowing()) {
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

  void emailBillDialog(BuildContext context, int position) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter _stateState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = email;

              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    //  width: MediaQuery.of(context).size.width/2,
                    //  height: MediaQuery.of(context).size.height/3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('email_bill'),
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Divider(
                            height: 2,
                            color: GlobalVariables.lightGray,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
                          child: Text(
                            GlobalFunctions.convertDateFormat(
                                    _billList[position].START_DATE,
                                    'dd-MM-yyyy') +
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    _billList[position].END_DATE, 'dd-MM-yyyy'),
                            style: TextStyle(
                                color: GlobalVariables.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
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
                                  flex: 3,
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
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: !isEditEmail
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: GlobalVariables.green,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              _emailTextController.clear();
                                              isEditEmail = true;
                                              _stateState(() {});
                                            })
                                        : IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: GlobalVariables.grey,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              _emailTextController.clear();
                                              _emailTextController.text = email;
                                              isEditEmail = false;
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
                              color: GlobalVariables.green,
                              onPressed: () {
                                GlobalFunctions.checkInternetConnection()
                                    .then((internet) {
                                  if (internet) {
                                    if (_emailTextController.text.length > 0) {
                                      Navigator.of(context).pop();
                                      getBillMail(
                                          _billList[position].INVOICE_NO,
                                          _billList[position].TYPE,
                                          _emailTextController.text);
                                    } else {
                                      GlobalFunctions.showToast(
                                          'Please Enter Email ID');
                                    }
                                  } else {
                                    GlobalFunctions.showToast(
                                        AppLocalizations.of(context).translate(
                                            'pls_check_internet_connectivity'));
                                  }
                                });
                              },
                              textColor: GlobalVariables.white,
                              //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      BorderSide(color: GlobalVariables.green)),
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
                  ));
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
            child: Image.asset(
              GlobalVariables.creditCardPath,
              width: 300,
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Text(
              AppLocalizations.of(context).translate('erp_acc_not'),
              style: TextStyle(
                  color: GlobalVariables.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width / 2,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: ButtonTheme(
              //minWidth: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                color: GlobalVariables.green,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseAboutSocietyRunInfo()));
                },
                textColor: GlobalVariables.white,
                //padding: EdgeInsets.fromLTRB(25, 10, 45, 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: GlobalVariables.green)),
                child: Text(
                  AppLocalizations.of(context).translate('i_am_interested'),
                  style: TextStyle(fontSize: GlobalVariables.largeText),
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
        context,
        MaterialPageRoute(
            builder: (context) => BaseDisplayProfileInfo(userId, societyId)));
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
    Navigator.pop(context, 'back');
    return Future.value(true);
  }

  paymentSuccessDialog(String paymentId) {
    print('paymentId : ' + paymentId.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
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
                          GlobalVariables.successIconPath,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(AppLocalizations.of(context)
                              .translate('successful_payment'))),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(AppLocalizations.of(context)
                                  .translate('transaction_id') +
                              ' : ' +
                              paymentId.toString())),
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
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
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
                          GlobalVariables.failureIconPath,
                          width: 50,
                          height: 50,
                        ),
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

  void getRazorPayOrderID(
      int position, String razorKey, String secret_key, int textAmount) {
    final dio = Dio();
    final RestClientRazorPay restClientRazorPay =
        RestClientRazorPay(dio, baseUrl: GlobalVariables.BaseRazorPayURL);
    amount = textAmount * 100;
    invoiceNo = _billList[position].INVOICE_NO;
    _progressDialog.show();
    RazorPayOrderRequest request = new RazorPayOrderRequest(
        amount: amount,
        currency: "INR",
        receipt: block + ' ' + flat + '-' + invoiceNo,
        paymentCapture: 1);
    restClientRazorPay
        .getRazorPayOrderID(request, razorKey, secret_key)
        .then((value) {
      print('getRazorPayOrderID Response : ' + value.toString());
      orderId = value['id'];
      print('id : ' + orderId);
      postRazorPayTransactionOrderID(
          value['id'], value['amount'].toString(), position);
    });
  }

  Future<void> postRazorPayTransactionOrderID(
      String orderId, String amount, int position) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    restClientERP
        .postRazorPayTransactionOrderID(societyId, block + ' ' + flat, orderId,
            (int.parse(amount) / 100).toString())
        .then((value) {
      print('Value : ' + value.toString());
      _progressDialog.hide();
      if (value.status) {
        if (_razorpay != null) {
          _razorpay.clear();
        }
        _razorpay = Razorpay();
        _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

        openCheckOut(position, _payOptionList[0].KEY_ID, orderId, amount);
      } else {
        GlobalFunctions.showToast(value.message);
      }
    });
  }

  String getBillPaymentStatus(int position) {
    String status = '';

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(_billList[position].DUE_DATE.toString());
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      status = "Overdue";
    } else if (days == 0) {
      status = "Due Today";
    } else if (days >= -2 && days < 0) {
      status = 'Due in ' + (days * (-1)).toString() + ' day';
    } else {
      status = 'Due Date';
    }
    return status;
  }

  getBillPaymentStatusColor(int position) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine = DateTime.parse(_billList[position].DUE_DATE.toString());
    final String toDate = formatter.format(toDateTine);

    int days = GlobalFunctions.getDaysFromDate(fromDate, toDate);

    if (days > 0) {
      return Color(0xFFc0392b);
    } else if (days == 0) {
      return Color(0xFFf39c12);
    } else if (days >= -2 && days < 0) {
      return Color(0xFFf39c12);
    } else {
      return GlobalVariables.mediumGreen;
    }
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
