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
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:societyrun/Activities/AboutSocietyRun.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddNewMemberByAdmin.dart';
import 'package:societyrun/Activities/AddVehicle.dart';
import 'package:societyrun/Activities/AlreadyPaid.dart';
import 'package:societyrun/Activities/DisplayProfileInfo.dart';
import 'package:societyrun/Activities/EditProfileInfo.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/StaffCategory.dart';
import 'package:societyrun/Activities/StaffDetails.dart';
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

//import 'package:societyrun/Models/MyUnitResponse.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/UserManagementResponse.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Models/razor_pay_order_request.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/Retrofit/RestClientRazorPay.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppContainer.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'AddAgreement.dart';
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

  bool hasPayTMGateway = false;
  bool hasRazorPayGateway = false;

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
  var email = '', phone = '', consumerId = '', societyName = '', userType = '';

  var amount, invoiceNo, referenceNo, billType, orderId;

  ReceivePort _port = ReceivePort();
  String _taskId;

  Map<String, String> _duesMap = Map<String, String>();
  ProgressDialog _progressDialog;
  String pageName;

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
                  SnackBar(content: text('Cannot open this file')));
            }
          });
        } else {
          _progressDialog.hide();
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: text('Download failed!')));
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
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
    return ChangeNotifierProvider<UserManagementResponse>.value(
      value: Provider.of(context),
      child: Consumer<UserManagementResponse>(
        builder: (context, value, child) {
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
                  child: AppIcon(
                    Icons.arrow_back,
                    iconColor: GlobalVariables.white,
                  ),
                ),
                title: text(
                  AppLocalizations.of(context).translate('my_unit'),
                  textColor: GlobalVariables.white,
                ),
                bottom: getTabLayout(),
                elevation: 0,
              ),
              body: WillPopScope(
                  child:
                      TabBarView(controller: _tabController, children: <Widget>[
                    Container(
                      color: GlobalVariables.veryLightGray,
                      child: value.isLoading
                          ? GlobalFunctions.loadingWidget(context)
                          : getMyDuesLayout(value),
                    ),
                    value.isLoading
                        ? GlobalFunctions.loadingWidget(context)
                        : SingleChildScrollView(
                            child: getMyHouseholdLayout(value),
                          ),
                  ]),
                  onWillPop: onWillPop),
            ),
          );
        },
      ),
    );
  }

  getListItemLayout(var position, UserManagementResponse value) {
    return Column(
      children: <Widget>[
        Container(
          //padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  //padding: EdgeInsets.all(5),
                  child: text(
                    value.ledgerList[position].LEDGER,
                    textColor: GlobalVariables.grey,
                    fontSize: GlobalVariables.textSizeMedium,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                //padding: EdgeInsets.all(5),
                child: text(
                  "",
                  textColor: GlobalVariables.lightGray,
                  fontSize: GlobalVariables.textSizeSMedium,
                ),
              ),
              InkWell(
                onTap: () {
                  if (value.ledgerList[position].TYPE
                          .toLowerCase()
                          .toString() ==
                      'bill') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseViewBill(
                                value.ledgerList[position].RECEIPT_NO, null)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BaseViewReceipt(
                                value.ledgerList[position].RECEIPT_NO, null)));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: text(
                    "Rs. " +
                        double.parse(value.ledgerList[position].AMOUNT)
                            .toStringAsFixed(2),
                    textColor: value.ledgerList[position].TYPE
                                .toLowerCase()
                                .toString() ==
                            'bill'
                        ? GlobalVariables.red
                        : GlobalVariables.green,
                    fontSize: GlobalVariables.textSizeMedium,
                    fontWeight: FontWeight.bold,
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

  getPendingListItemLayout(var position, UserManagementResponse value) {
    return Column(
      children: <Widget>[
        Container(
         // padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      //padding: EdgeInsets.all(5),
                      child: text(
                        value.pendingList[position].REFERENCE_NO,
                        textColor: GlobalVariables.green,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      // padding: EdgeInsets.all(5),
                      child: text(
                        value.pendingList[position].PAYMENT_DATE.length > 0
                            ? GlobalFunctions.convertDateFormat(
                                value.pendingList[position].PAYMENT_DATE,
                                'dd-MM-yyyy')
                            : "",
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        textStyleHeight: 1.0
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                //padding: EdgeInsets.all(5),
                child: text(
                  "",
                  textColor: GlobalVariables.lightGray,
                  fontSize: GlobalVariables.textSizeSMedium,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  //padding: EdgeInsets.all(5),
                  child: text(
                    "Rs. " +
                        double.parse(
                                value.pendingList[position].AMOUNT.toString())
                            .toStringAsFixed(2),
                    textColor:
                        /*value.ledgerList[position].TYPE.toLowerCase().toString() ==
                            'bill' ? GlobalVariables.red :*/
                        GlobalVariables.green,
                    fontSize: GlobalVariables.textSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(
          color: GlobalVariables.mediumGreen,
          height: 1,
        ),
        SizedBox(height: 10,),
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
              borderRadius: BorderRadius.circular(10.0))),
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
                        text(
                          AppLocalizations.of(context).translate('total_due'),
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeSMedium,
                        ),
                        text(
                          AppLocalizations.of(context).translate('due_date'),
                          textColor: GlobalVariables.mediumGreen,
                          fontSize: GlobalVariables.textSizeMedium,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          "Rs. " + duesRs,
                          textColor: GlobalVariables.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        text(
                          duesDate,
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Container(
                      color: GlobalVariables.mediumGreen,
                      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Divider(
                        height: 1,
                        color: GlobalVariables.mediumGreen,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: text(
                          AppLocalizations.of(context).translate('pay_now'),
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeMedium,
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

  getMyDuesLayout(UserManagementResponse value) {
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
                              10, MediaQuery.of(context).size.height / 15, 10, 0),
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: value.billList.length,
                                    itemBuilder: (context, position) {
                                      return getBillListItemLayout(
                                          position, context, value);
                                    }, //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        ),
                        value.pendingList.length > 0
                            ? Container(
                                alignment: Alignment.topLeft,
                                //color: GlobalVariables.white,
                                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: text(
                                  AppLocalizations.of(context)
                                      .translate('pending_transaction'),
                                  textColor: GlobalVariables.black,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(),
                        value.pendingList.length > 0
                            ? Container(
                                padding: EdgeInsets.all(16),
                                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: Builder(
                                    builder: (context) => ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              /*value.pendingList.length >= 3
                                              ? 3
                                              : */
                                              value.pendingList.length,
                                          itemBuilder: (context, position) {
                                            return getPendingListItemLayout(
                                                position, value);
                                          }, //  scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                        )),
                              )
                            : Container(),
                        /*value.pendingList.length > 0
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
                                *//*child: InkWell(
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
                                          fontSize: GlobalVariables.textSizeMedium,
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
                            )*//*
                              )
                            : Container(),*/
                        value.ledgerList.length > 0
                            ? Container(
                                alignment: Alignment.topLeft,
                                //color: GlobalVariables.white,
                                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: text(
                                  AppLocalizations.of(context)
                                      .translate('recent_transaction'),
                                  textColor: GlobalVariables.black,
                                  fontSize: GlobalVariables.textSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(),
                        value.ledgerList.length > 0
                            ? Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: Builder(
                                    builder: (context) => ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              value.ledgerList.length >= 3
                                                  ? 3
                                                  : value.ledgerList.length,
                                          itemBuilder: (context, position) {
                                            return getListItemLayout(
                                                position, value);
                                          }, //  scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                        )),
                              )
                            : Container(),
                        value.ledgerList.length > 0
                            ? Container(
                                width: double.infinity,
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                            builder: (context) =>
                                                BaseLedger()));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: text(
                                          AppLocalizations.of(context)
                                              .translate('view_more'),
                                          textColor: GlobalVariables.green,
                                          fontSize:
                                              GlobalVariables.textSizeMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        child: AppIcon(
                                          Icons.fast_forward,
                                          iconColor: GlobalVariables.green,
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

  getMyHouseholdLayout(UserManagementResponse value) {
    print('MyHouseHold Tab Call');
    return Container(
      width: MediaQuery.of(context).size.width,
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
              userType != 'Tenant'
                  ? Container(
                      alignment:
                          Alignment.topLeft, //color: GlobalVariables.white,
                      margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: text(
                              AppLocalizations.of(context)
                                  .translate('my_family'),
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppPermission.isUserAddMemberPermission
                              ? Container(
                                  child: RaisedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BaseAddNewMember("family")));
                                    print('result back : ' + result.toString());
                                    if (result != 'back') {
                                      Provider.of<UserManagementResponse>(
                                              context,
                                              listen: false)
                                          .getUnitMemberData();
                                    }
                                  },
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('plus_add'),
                                    textColor: GlobalVariables.white,
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: GlobalVariables.green)),
                                  textColor: GlobalVariables.white,
                                  color: GlobalVariables.green,
                                ))
                              : Container(),
                        ],
                      ),
                    )
                  : Container(),
              userType != 'Tenant'
                  ? value.memberList.length > 0
                      ? Container(
                          //padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(18, 10, 0, 0),
                          width: 600,
                          height: 190,
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: value.memberList.length,
                                    itemBuilder: (context, position) {
                                      return getContactListItemLayout(
                                          value.memberList, position, true);
                                    },
                                    //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        )
                      : Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(20),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('add_family_details'),
                              textColor: GlobalVariables.grey,
                              fontSize: GlobalVariables.textSizeSMedium),
                        )
                  : Container(),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_tenant'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                            child: RaisedButton(
                          onPressed: () {
                            /* final result = await*/ Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseAddAgreement(block, flat, false)));
                            /*    print('result back : ' + result.toString());
                                if (result != 'back') {
                                  Provider.of<UserManagementResponse>(
                                      context, listen: false).getUnitMemberData();
                                }*/
                          },
                          child: text(
                            AppLocalizations.of(context)
                                .translate('add_agreement'),
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: GlobalVariables.green)),
                          textColor: GlobalVariables.white,
                          color: GlobalVariables.green,
                        )),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                            child: RaisedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BaseAddNewMember("tenant")));
                            print('result back : ' + result.toString());
                            if (result != 'back') {
                              Provider.of<UserManagementResponse>(context,
                                      listen: false)
                                  .getUnitMemberData();
                            }
                          },
                          child: text(
                            AppLocalizations.of(context).translate('plus_add'),
                            textColor: GlobalVariables.white,
                            fontSize: GlobalVariables.textSizeSmall,
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
              ),
              value.tenantList.length > 0
                  ? Container(
                      //padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(18, 10, 0, 0),
                      width: 600,
                      height: 190,
                      child: Builder(
                          builder: (context) => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: value.tenantList.length,
                                itemBuilder: (context, position) {
                                  return getContactListItemLayout(
                                      value.tenantList, position, true);
                                },
                                //  scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                              )),
                    )
                  : Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(20),
                      child: text(
                          AppLocalizations.of(context)
                              .translate('add_tenant_details'),
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium),
                    ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_staff'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: Container(
                          child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseStaffCategory(false)));
                        },
                        child: text(
                          AppLocalizations.of(context).translate('plus_add'),
                          textColor: GlobalVariables.white,
                          fontSize: GlobalVariables.textSizeSmall,
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
              value.staffList.length > 0
                  ? Container(
                      //padding: EdgeInsets.all(10),
                      margin: EdgeInsets.fromLTRB(18, 10, 0, 0),
                      width: 600,
                      height: 190,
                      child: Builder(
                          builder: (context) => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: value.staffList.length,
                                itemBuilder: (context, position) {
                                  return getContactListItemLayout(
                                      value.staffList, position, false);
                                },
                                //  scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                              )),
                    )
                  : Container(
                      padding: EdgeInsets.all(20),
                      child: text(
                          AppLocalizations.of(context)
                              .translate('add_staff_details'),
                          textColor: GlobalVariables.grey,
                          fontSize: GlobalVariables.textSizeSMedium),
                    ),
              Container(
                alignment: Alignment.topLeft, //color: GlobalVariables.white,
                margin: EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: text(
                        AppLocalizations.of(context).translate('my_vehicle'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppPermission.isSocAddVehiclePermission
                        ? Container(
                            child: RaisedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseAddVehicle()));
                              print('result back : ' + result.toString());
                              if (result != 'back') {
                                Provider.of<UserManagementResponse>(context,
                                        listen: false)
                                    .getUnitMemberData();
                              }
                            },
                            child: text(
                              AppLocalizations.of(context)
                                  .translate('plus_add'),
                              textColor: GlobalVariables.white,
                              fontSize: GlobalVariables.textSizeSmall,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: GlobalVariables.green)),
                            textColor: GlobalVariables.white,
                            color: GlobalVariables.green,
                          ))
                        : Container(),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  value.vehicleList.length > 0
                      ? Container(
                          //height: 500,
                          //padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(18, 10, 18, 20),
                          decoration: BoxDecoration(
                              color: GlobalVariables.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Builder(
                              builder: (context) => ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    // scrollDirection: Axis.horizontal,
                                    itemCount: value.vehicleList.length,
                                    itemBuilder: (context, position) {
                                      return getVehicleRecentTransactionListItemLayout(
                                          position, value);
                                    },
                                    //  scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  )),
                        )
                      : Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(20),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('add_vehicle_details'),
                              textColor: GlobalVariables.grey,
                              fontSize: GlobalVariables.textSizeSMedium),
                        ),
                ],
              ),
            ],
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
              10,
              MediaQuery.of(context).size.height / 15,
              10,
              0), //margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            shape: (RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0))),
            elevation: 15.0,
            shadowColor: GlobalVariables.green.withOpacity(0.3),
            margin: EdgeInsets.all(8),
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
                                  ? AppAssetsImage(
                                      GlobalVariables.componentUserProfilePath,
                                      imageWidth: 80.0,
                                      imageHeight: 80.0,
                                      borderColor: GlobalVariables.grey,
                                      borderWidth: 2.0,
                                      fit: BoxFit.cover,
                                      radius: 40.0,
                                    )
                                  : AppNetworkImage(
                                      photo,
                                      imageWidth: 80.0,
                                      imageHeight: 80.0,
                                      borderColor: GlobalVariables.grey,
                                      borderWidth: 2.0,
                                      fit: BoxFit.cover,
                                      radius: 40.0,
                                    )),
                          text(
                            name,
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeNormal,
                            fontWeight: FontWeight.bold
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
                                  child: AppIcon(
                                    Icons.share,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('share_contact'),
                                    textColor: GlobalVariables.green,
                                    fontSize: GlobalVariables.textSizeMedium,
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
    var call = '', email = '', userId, userType;
    if (family) {
      call = _list[position].Phone.toString();
      userId = _list[position].ID.toString();
      userType = _list[position].TYPE.toString();
      //    email = _list[position].EMAIL.toString();
    } else {
      call = _list[position].CONTACT.toString();
      userId = _list[position].SID.toString();
    }
    if (call == 'null') {
      call = '';
    }

    return InkWell(
      onTap: () async {
        print('userId : ' + userId);
        print('societyId : ' + societyId);
        if (family) {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BaseDisplayProfileInfo(userId, userType)));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        } else {
          print('_list[position] : ' + _list[position].toString());
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BaseStaffDetails(_list[position])));
          if (result == 'back') {
            Provider.of<UserManagementResponse>(context, listen: false)
                .getUnitMemberData();
          }
        }
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: GlobalVariables.white),
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: family
                    ? _list[position].PROFILE_PHOTO.length == 0
                    ? AppAssetsImage(
                  GlobalVariables.componentUserProfilePath,
                  imageWidth: 70.0,
                  imageHeight: 70.0,
                  borderColor: GlobalVariables.grey,
                  borderWidth: 1.0,
                  fit: BoxFit.cover,
                  radius: 35.0,
                )
                    : AppNetworkImage(
                  _list[position].PROFILE_PHOTO,
                  imageWidth: 70.0,
                  imageHeight: 70.0,
                  borderColor: GlobalVariables.grey,
                  borderWidth: 1.0,
                  fit: BoxFit.cover,
                  radius: 35.0,
                )
                    : _list[position].IMAGE.length == 0
                    ? AppAssetsImage(
                  GlobalVariables.componentUserProfilePath,
                  imageWidth: 70.0,
                  imageHeight: 70.0,
                  borderColor: GlobalVariables.grey,
                  borderWidth: 1.0,
                  fit: BoxFit.cover,
                  radius: 35.0,
                )
                    : AppNetworkImage(
                  _list[position].IMAGE,
                  imageWidth: 70.0,
                  imageHeight: 70.0,
                  borderColor: GlobalVariables.grey,
                  borderWidth: 1.0,
                  fit: BoxFit.cover,
                  radius: 35.0,
                )),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: text(
                  family ? _list[position].NAME : _list[position].STAFF_NAME,
                  maxLine: 1,
                  textColor: GlobalVariables.green,
                  fontSize: GlobalVariables.textSizeMedium,
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
                child:
                /*Row(
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
                    ),*/
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          launch("tel://" + call);
                        },
                        child: Container(
                          width: double.infinity,
                          child: AppIcon(
                            Icons.call,
                            iconColor: GlobalVariables.green,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      //TODO: Divider
                        height: 30,
                        width: 8,
                        child: VerticalDivider(
                          color: GlobalVariables.lightGray,
                        )),
                    Flexible(
                      flex: 1,
                      child: InkWell(
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
                          width: double.infinity,
                          child: AppIcon(
                            Icons.share,
                            iconColor: GlobalVariables.grey,
                          ),
                        ),
                      ),
                    )
                  ],
                ))
                : family
                ? InkWell(
              onTap: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BaseEditProfileInfo(userId, societyId)));
                if (result == 'profile') {
                  Provider.of<UserManagementResponse>(context,
                      listen: false)
                      .getUnitMemberData();
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                alignment: Alignment.center,
                child: text(
                  '+ ' +
                      AppLocalizations.of(context)
                          .translate('add_phone'),
                  textColor: GlobalVariables.lightGray,
                  fontSize: GlobalVariables.textSizeLargeMedium,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<void> getSharedPreferenceData() async {
    societyId = await GlobalFunctions.getSocietyId();
    userId = await GlobalFunctions.getUserId();
    name = await GlobalFunctions.getDisplayName();
    photo = await GlobalFunctions.getPhoto();
    phone = await GlobalFunctions.getMobile();
    email = await GlobalFunctions.getUserName();
    consumerId = await GlobalFunctions.getConsumerID();
    societyName = await GlobalFunctions.getSocietyName();
    flat = await GlobalFunctions.getFlat();
    block = await GlobalFunctions.getBlock();
    userType = await GlobalFunctions.getUserType();

    print('societyId : ' + societyId);
    print('UserId : ' + userId);
    print('Name : ' + name);
    print('Photo : ' + photo);
    print('Phone : ' + phone);
    print('EmailId : ' + email);
    print('ConsumerId : ' + consumerId);
    print('userType : ' + userType);
  }

  getSharedPreferenceDuesData() {
    GlobalFunctions.getSharedPreferenceDuesData().then((map) {
      _duesMap = map;
      duesRs = _duesMap[GlobalVariables.keyDuesRs];
      duesDate = _duesMap[GlobalVariables.keyDuesDate];
      setState(() {});
    });
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

  getBillListItemLayout(
      int position, BuildContext context, UserManagementResponse value) {
    return Align(
      alignment: Alignment.center,
      child: AppContainer(
        child: Stack(
          children: <Widget>[
            Container(
              //margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  GlobalVariables.whileBGPath,
                ),
              ),
            ),
            Container(
              //margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              getBillTypeColor(value.billList[position].TYPE),
                        ),
                        child: text(
                          value.billList[position].TYPE != null
                              ? value.billList[position].TYPE == 'Bill'
                                  ? 'Maintenance Bill'
                                  : value.billList[position].TYPE
                              : '',
                          textColor: GlobalVariables.white,
                          fontSize: GlobalVariables.textSizeSmall,
                        ),
                      ),
                      (value.billList[position].AMOUNT -
                                  value.billList[position].RECEIVED) <=
                              0
                          ? text(
                              'Paid',
                              textColor: GlobalVariables.green,
                              fontSize: GlobalVariables.textSizeLargeMedium,
                              fontWeight: FontWeight.bold,
                            )
                          : text(
                              getBillPaymentStatus(position, value),
                              textColor:
                                  getBillPaymentStatusColor(position, value),
                              fontSize: GlobalVariables.textSizeLargeMedium,
                              fontWeight: FontWeight.bold,
                            ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          "Rs. " +
                              double.parse((value.billList[position].AMOUNT -
                                          value.billList[position].RECEIVED)
                                      .toString())
                                  .toStringAsFixed(2),
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        text(
                          value.billList[position].DUE_DATE != null
                              ? GlobalFunctions.convertDateFormat(
                                  value.billList[position].DUE_DATE,
                                  "dd-MM-yyyy")
                              : '',
                          textColor: GlobalVariables.green,
                          fontSize: GlobalVariables.textSizeMedium,
                          fontWeight: FontWeight.bold,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (value.billList[position].TYPE
                                        .toLowerCase()
                                        .toString() ==
                                    'bill' ||
                                value.billList[position].TYPE
                                        .toLowerCase()
                                        .toString() ==
                                    'invoice') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewBill(
                                          value.billList[position].INVOICE_NO,
                                          null)));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaseViewReceipt(
                                          value.billList[position].INVOICE_NO,
                                          null)));
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.visibility,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('view'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.green,
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
                            _amountTextController.text = double.parse(
                                    (value.billList[position].AMOUNT -
                                            value.billList[position].RECEIVED)
                                        .toString())
                                .toStringAsFixed(2);
                            amount = _amountTextController.text;
                            if (value.billList[position].AMOUNT -
                                    value.billList[position].RECEIVED >
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
                                                context,
                                                setState,
                                                position,
                                                value),
                                          );
                                        }));
                              } else {
                                if (value.payOptionList[0].Status) {
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
                                                /*shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),*/
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position,
                                                    value),
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
                                                /*shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0)),*/
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position,
                                                    value),
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
                              alreadyPaidDialog(position, value);
                              //paymentSuccessDialog('SASADSAFF');
                              //paymentFailureDialog();
                              /*GlobalFunctions.showToast(
                                  AppLocalizations.of(context)
                                      .translate('already_paid'));*/
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.payment,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('pay_now'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.green,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            emailBillDialog(context, position, value);
                            // getBillMail(value.billList[position].INVOICE_NO,value.billList[position].TYPE);
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.mail,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('get_bill'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.green,
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
                                        value.billList[position].INVOICE_NO,
                                        value.billList[position].AMOUNT)));
                            if (result == 'back') {
                              Provider.of<UserManagementResponse>(context,
                                      listen: false)
                                  .getAllBillData();
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AppIcon(
                                    Icons.payment,
                                    iconColor: GlobalVariables.mediumGreen,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: text(
                                    AppLocalizations.of(context)
                                        .translate('already_paid'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                    textColor: GlobalVariables.green,
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

  getVehicleRecentTransactionListItemLayout(
      int position, UserManagementResponse value) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: getIconForVehicle(value.vehicleList[position].WHEEL),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: text(
                    value.vehicleList[position].MODEL,
                    textColor: GlobalVariables.green,
                    fontSize: GlobalVariables.textSizeMedium,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: text(
                      value.vehicleList[position].VEHICLE_NO,
                      textColor: GlobalVariables.grey,
                      fontSize: GlobalVariables.textSizeMedium,
                    ),
                  ),
                  AppPermission.isSocAddVehiclePermission
                      ? InkWell(
                          onTap: () {
                            print('Delete Position :' + position.toString());
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: deleteVehicleLayout(
                                            position, value),
                                      );
                                    }));
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: AppIcon(
                                Icons.delete,
                                iconColor: GlobalVariables.mediumGreen,
                              )),
                        )
                      : Container(),
                ],
              )
            ],
          ),
          position != value.vehicleList.length - 1
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

  deleteVehicleLayout(int position, UserManagementResponse value) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('sure_delete'),
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
                        deleteVehicle(position, value);
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

  getIconForVehicle(String vehicleType) {
    if (vehicleType == '4 Wheeler' ||
        vehicleType == '4' ||
        vehicleType == 'four') {
      return AppIcon(
        Icons.directions_car,
        iconColor: GlobalVariables.mediumGreen,
      );
    } else if (vehicleType == '2 Wheeler' ||
        vehicleType == '2' ||
        vehicleType == 'two') {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.mediumGreen,
      );
    } else {
      return AppIcon(
        Icons.motorcycle,
        iconColor: GlobalVariables.mediumGreen,
      );
    }
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

  void openCheckOut(int position, String razorKey, String orderId,
      String amount, UserManagementResponse UserManagementResponse) {
    //amount = value.billList[position].AMOUNT;
    invoiceNo = UserManagementResponse.billList[position].INVOICE_NO;
    billType = UserManagementResponse.billList[position].TYPE == 'Bill'
        ? 'Maintenance Bill'
        : UserManagementResponse.billList[position].TYPE;
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

  getListOfPaymentGateway(BuildContext context, StateSetter setState,
      int position, UserManagementResponse value) {
    // GlobalFunctions.showToast(_selectedPaymentGateway.toString());

    print('NoLessPermission : ' +
        AppPermission.isSocPayAmountNoLessPermission.toString());

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
                    Container(
                      // margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: text(
                        AppLocalizations.of(context).translate('change_amount'),
                        textColor: GlobalVariables.black,
                        fontSize: GlobalVariables.textSizeLargeMedium,
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
                                    child: text(
                                      'Rs. ',
                                      textColor: GlobalVariables.green,
                                      fontSize: GlobalVariables.textSizeNormal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      child: TextFormField(
                                        controller: _amountTextController,
                                        readOnly: isEditAmount ? false : true,
                                        cursorColor: GlobalVariables.green,
                                        showCursor: isEditAmount ? true : false,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: GlobalVariables.green,
                                            fontSize:
                                                GlobalVariables.textSizeNormal,
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
                                  (AppPermission.isSocPayAmountEditPermission ||
                                          AppPermission
                                              .isSocPayAmountNoLessPermission)
                                      ? Container(
                                          alignment: Alignment.topLeft,
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: !isEditAmount
                                              ? IconButton(
                                                  icon: AppIcon(
                                                    Icons.edit,
                                                    iconColor:
                                                        GlobalVariables.green,
                                                    iconSize: GlobalVariables
                                                        .textSizeLarge,
                                                  ),
                                                  onPressed: () {
                                                    _amountTextController
                                                        .clear();
                                                    isEditAmount = true;
                                                    setState(() {});
                                                  })
                                              : IconButton(
                                                  icon: AppIcon(
                                                    Icons.cancel,
                                                    iconColor:
                                                        GlobalVariables.grey,
                                                    iconSize: 24,
                                                  ),
                                                  onPressed: () {
                                                    _amountTextController
                                                        .clear();
                                                    _amountTextController.text =
                                                        amount;
                                                    isEditAmount = false;
                                                    setState(() {});
                                                  }),
                                        )
                                      : SizedBox(),
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
                    (hasPayTMGateway || hasRazorPayGateway)
                        ? Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
                            alignment: Alignment.topLeft,
                            child: text(
                              AppLocalizations.of(context)
                                  .translate('select_payment_option'),
                              textColor: GlobalVariables.black,
                              fontSize: GlobalVariables.textSizeMedium,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : Container(),
                    hasRazorPayGateway
                        ? Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                          color:
                                              _selectedPaymentGateway != "PayTM"
                                                  ? GlobalVariables.green
                                                  : GlobalVariables.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _selectedPaymentGateway !=
                                                    "PayTM"
                                                ? GlobalVariables.green
                                                : GlobalVariables.mediumGreen,
                                            width: 2.0,
                                          )),
                                      child: AppIcon(Icons.check,
                                          iconColor: GlobalVariables.white),
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
                          )
                        : Container(),
                    hasPayTMGateway
                        ? Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                          color:
                                              _selectedPaymentGateway == "PayTM"
                                                  ? GlobalVariables.green
                                                  : GlobalVariables.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: _selectedPaymentGateway ==
                                                    "PayTM"
                                                ? GlobalVariables.green
                                                : GlobalVariables.mediumGreen,
                                            width: 2.0,
                                          )),
                                      child: AppIcon(Icons.check,
                                          iconColor: GlobalVariables.white),
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
                          )
                        : Container(),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(10, 15, 0, 5),
                      child: text(
                        AppLocalizations.of(context).translate('trans_charges'),
                        textColor: GlobalVariables.grey,
                        fontSize: GlobalVariables.textSizeSmall,
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
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                child: InkWell(
                  onTap: () {
                    print('amount : ' + amount);
                    print('_amountTextController : ' +
                        _amountTextController.text.toString());
                    if (double.parse(_amountTextController.text) <= 0) {
                      GlobalFunctions.showToast(
                          'Amount must be grater than zero');
                    } else if (AppPermission.isSocPayAmountNoLessPermission) {
                      if (double.parse(amount) <=
                          double.parse(_amountTextController.text)) {
                        Navigator.of(context).pop();
                        redirectToPaymentGateway(
                            position, _amountTextController.text, value);
                      } else {
                        GlobalFunctions.showToast(
                            'Amount must be Grater or equal to Actual Amount');
                      }
                    } else {
                      Navigator.of(context).pop();
                      redirectToPaymentGateway(
                          position, _amountTextController.text, value);
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: text(
                        AppLocalizations.of(context).translate('proceed'),
                        textColor: GlobalVariables.white,
                        fontSize: GlobalVariables.textSizeNormal,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
            ],
          ),
        ),
        /*  Align(
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

  void redirectToPaymentGateway(
      int position, String textAmount, UserManagementResponse value) {
    if (_selectedPaymentGateway == 'PayTM') {
      //Navigator.of(context).pop();

      showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: displaySocietyRunDisclaimer(value),
                );
              }));
    } else if (_selectedPaymentGateway == 'RazorPay') {
      getRazorPayOrderID(position, value.payOptionList[0].KEY_ID,
          value.payOptionList[0].SECRET_KEY, double.parse(textAmount), value);
    }
  }

  displaySocietyRunDisclaimer(UserManagementResponse value) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width / 1.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: text(
              AppLocalizations.of(context).translate('disclaimer'),
              fontSize: GlobalVariables.textSizeLargeMedium,
              textColor: GlobalVariables.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 250,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                child: text(
                  AppLocalizations.of(context).translate('disclaimer_info'),
                  fontSize: GlobalVariables.textSizeMedium,
                  textColor: GlobalVariables.black,
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
                                            BorderRadius.circular(10.0)),
                                    child: displayConsumerId(value),
                                  );
                                }));
                      },
                      child: text(
                        AppLocalizations.of(context).translate('proceed'),
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
                        AppLocalizations.of(context).translate('cancel'),
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

  displayConsumerId(UserManagementResponse UserManagementResponse) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: text(
              consumerId,
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                    icon: AppIcon(
                      Icons.content_copy,
                      iconColor: GlobalVariables.green,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClipboardManager.copyToClipBoard(consumerId)
                          .then((value) {
                        GlobalFunctions.showToast("Copied to Clipboard");
                        launch(
                            UserManagementResponse.payOptionList[0].PAYTM_URL);
                      });
                    }),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: text(
                    AppLocalizations.of(context).translate('copy'),
                    fontSize: GlobalVariables.textSizeSmall,
                    fontWeight: FontWeight.bold,
                    textColor: GlobalVariables.green,
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
  }

  void _callAPI(int index) {
    GlobalFunctions.checkInternetConnection().then((internet) {
      if (internet) {
        switch (index) {
          case 0:
            {
              if (!isDuesTabAPICall) {
                if (GlobalVariables.isERPAccount) {
                  Provider.of<UserManagementResponse>(context, listen: false)
                      .getPayOption()
                      .then((payOptionList) {
                    if (payOptionList.length > 0) {
                      print(payOptionList[0].KEY_ID.toString());

                      if (payOptionList[0].KEY_ID != null &&
                          payOptionList[0].KEY_ID.length > 0 &&
                          payOptionList[0].SECRET_KEY != null &&
                          payOptionList[0].SECRET_KEY.length > 0) {
                        hasRazorPayGateway = true;
                      }
                      if (payOptionList[0].PAYTM_URL != null &&
                          payOptionList[0].PAYTM_URL.length > 0) {
                        hasPayTMGateway = true;
                      }
                      print('hasPayTMGateway' + hasPayTMGateway.toString());
                      print(
                          'hasRazorPayGateway' + hasRazorPayGateway.toString());
                    }
                  });
                }
              }
            }
            break;
          case 1:
            {
              if (!isHouseholdTabAPICall) {
                Provider.of<UserManagementResponse>(context, listen: false)
                    .getUnitMemberData()
                    .then((value) {});
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
      String invoice_no, String type, String emailId, String year) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    societyId = await GlobalFunctions.getSocietyId();

    _progressDialog.show();
    restClientERP
        .getBillMail(
            societyId, type, invoice_no, _emailTextController.text, year)
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

  void emailBillDialog(
      BuildContext context, int position, UserManagementResponse value) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter _stateState) {
              isEditEmail
                  ? _emailTextController.text = ''
                  : _emailTextController.text = email;

              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    //  width: MediaQuery.of(context).size.width/2,
                    //  height: MediaQuery.of(context).size.height/3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        /*Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('email_bill'),
                            style: TextStyle(
                                color: GlobalVariables.green,
                                fontSize: GlobalVariables.textSizeLargeMedium,
                                fontWeight: FontWeight.bold),
                          ),
                        ),*/
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: text(
                            GlobalFunctions.convertDateFormat(
                                    value.billList[position].START_DATE,
                                    'dd-MM-yyyy') +
                                ' to ' +
                                GlobalFunctions.convertDateFormat(
                                    value.billList[position].END_DATE,
                                    'dd-MM-yyyy'),
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Divider(
                            thickness: 1.5,
                            color: GlobalVariables.grey,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            // color: GlobalVariables.mediumGreen,
                            // margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                /*   Container(
                                child: Text(AppLocalizations.of(context).translate('email_bill_to'),style: TextStyle(
                                    color: GlobalVariables.grey,fontSize: GlobalVariables.textSizeMedium,fontWeight: FontWeight.bold
                                ),),
                              ),*/
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: TextFormField(
                                      controller: _emailTextController,
                                      cursorColor: GlobalVariables.green,
                                      keyboardType: TextInputType.emailAddress,
                                      showCursor: isEditEmail ? true : false,
                                      decoration: InputDecoration(
                                        border: isEditEmail
                                            ? new UnderlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.green))
                                            : InputBorder.none,
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
                                            icon: AppIcon(
                                              Icons.edit,
                                              iconColor: GlobalVariables.green,
                                              iconSize: 24,
                                            ),
                                            onPressed: () {
                                              _emailTextController.clear();
                                              isEditEmail = true;
                                              _stateState(() {});
                                            })
                                        : IconButton(
                                            icon: AppIcon(
                                              Icons.cancel,
                                              iconColor: GlobalVariables.grey,
                                              iconSize: 24,
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
                            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                            alignment: Alignment.topRight,
                            //height: 45,
                            child: AppButton(
                                textContent: AppLocalizations.of(context)
                                    .translate('email_now'),
                                onPressed: () {
                                  GlobalFunctions.checkInternetConnection()
                                      .then((internet) {
                                    if (internet) {
                                      if (_emailTextController.text.length >
                                          0) {
                                        Navigator.of(context).pop();
                                        getBillMail(
                                            value.billList[position].INVOICE_NO,
                                            value.billList[position].TYPE,
                                            _emailTextController.text,
                                            null);
                                      } else {
                                        GlobalFunctions.showToast(
                                            'Please Enter Email ID');
                                      }
                                    } else {
                                      GlobalFunctions.showToast(AppLocalizations
                                              .of(context)
                                          .translate(
                                              'pls_check_internet_connectivity'));
                                    }
                                  });
                                })),
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
            child: text(
              AppLocalizations.of(context).translate('erp_acc_not'),
              textColor: GlobalVariables.black,
              fontSize: GlobalVariables.textSizeLargeMedium,
              fontWeight: FontWeight.bold,
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
                child: text(
                  AppLocalizations.of(context).translate('i_am_interested'),
                  fontSize: GlobalVariables.textSizeMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToProfilePage() async {
    String userType = await GlobalFunctions.getUserType();
    String userId = await GlobalFunctions.getUserId();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseDisplayProfileInfo(userId, userType)));
  }

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
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width / 1.2,
                  color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                  // height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                      Container(
                        //color: GlobalVariables.grey,
                        child: AppAssetsImage(
                          GlobalVariables.successIconPath,
                          imageWidth: 80.0,
                          imageHeight: 80.0,
                          //imageColor: GlobalVariables.green,
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('successful_payment'),
                              fontSize: GlobalVariables.textSizeSMedium,
                              fontWeight: FontWeight.bold,
                              textColor: GlobalVariables.black)),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: text(
                            AppLocalizations.of(context)
                                    .translate('transaction_id') +
                                ' : ' +
                                paymentId.toString(),
                            textColor: GlobalVariables.green,
                            fontSize: GlobalVariables.textSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: text(
                            AppLocalizations.of(context)
                                .translate('thank_you_payment'),
                            textColor: GlobalVariables.skyBlue,
                            fontWeight: FontWeight.bold),
                      ),
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
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                  //height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                      Container(
                        child: AppAssetsImage(
                          GlobalVariables.failureIconPath,
                          imageWidth: 80.0,
                          imageHeight: 80.0,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('failure_to_pay'),
                              textColor: GlobalVariables.black,
                              fontWeight: FontWeight.bold,
                              fontSize: GlobalVariables.textSizeMedium)),

                      /* Container(
                           margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                           child: Text(AppLocalizations.of(context)
                               .translate('order_amount'))),*/
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: text(
                              AppLocalizations.of(context)
                                  .translate('payment_failed_try_again'),
                              textColor: GlobalVariables.skyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: GlobalVariables.textSizeSMedium)),
                    ],
                  ),
                ),
              );
            }));
  }

  void getRazorPayOrderID(int position, String razorKey, String secret_key,
      double textAmount, UserManagementResponse UserManagementResponse) {
    final dio = Dio();
    final RestClientRazorPay restClientRazorPay =
        RestClientRazorPay(dio, baseUrl: GlobalVariables.BaseRazorPayURL);
    amount = textAmount * 100;
    invoiceNo = UserManagementResponse.billList[position].INVOICE_NO;
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
      postRazorPayTransactionOrderID(value['id'], value['amount'].toString(),
          position, UserManagementResponse);
    });
  }

  Future<void> postRazorPayTransactionOrderID(String orderId, String amount,
      int position, UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();

    restClientERP
        .postRazorPayTransactionOrderID(societyId, block + ' ' + flat, orderId,
            (double.parse(amount) / 100).toString())
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

        openCheckOut(position, UserManagementResponse.payOptionList[0].KEY_ID,
            orderId, amount, UserManagementResponse);
      } else {
        GlobalFunctions.showToast(value.message);
      }
    });
  }

  String getBillPaymentStatus(int position, UserManagementResponse value) {
    String status = '';

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine =
        DateTime.parse(value.billList[position].DUE_DATE.toString());
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

  getBillPaymentStatusColor(int position, UserManagementResponse value) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String fromDate = formatter.format(now);
    final toDateTine =
        DateTime.parse(value.billList[position].DUE_DATE.toString());
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

  Future<void> deleteVehicle(
      int position, UserManagementResponse UserManagementResponse) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    societyId = await GlobalFunctions.getSocietyId();
    String id = UserManagementResponse.vehicleList[position].ID;
    _progressDialog.show();
    restClient.deleteVehicle(id, societyId).then((value) {
      _progressDialog.hide();
      if (value.status) {
        UserManagementResponse.vehicleList.removeAt(position);
        setState(() {});
      }
      GlobalFunctions.showToast(value.message);
    });
  }

  void alreadyPaidDialog(int position, UserManagementResponse value) {
    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: GlobalVariables.transparent,
                  // width: MediaQuery.of(context).size.width/3,
                  // height: MediaQuery.of(context).size.height/4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          child: AppAssetsImage(
                        GlobalVariables.paidIconPath,
                        imageWidth: 70.0,
                        imageHeight: 70.0,
                      )),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: text(AppLocalizations.of(context)
                              .translate('already_paid_advance_payment'))),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  alignment: Alignment.topRight,
                                  child: text('Close',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
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
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: getListOfPaymentGateway(
                                                    context,
                                                    setState,
                                                    position,
                                                    value),
                                              );
                                            }));
                                  },
                                  child: text('Pay advance',
                                      fontSize: GlobalVariables.textSizeMedium,
                                      textColor: GlobalVariables.green,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
