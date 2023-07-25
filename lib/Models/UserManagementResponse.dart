import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/MonthExpensePendingRequestResponse.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/PaymentCharges.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';
import 'package:societyrun/main.dart';

class UserManagementResponse extends ChangeNotifier {
  bool isLoading = true;
  String? errMsg;
  String noOfUnits = '0',
      registerUser = '0',
      activeUser = '0',
      mobileUser = '0',
      rentalRequest = '0',
      pendingRequest = '0',
      moveOutRequest = '0',
      smsData = '0',
      closeComplaint = '0',
      openComplaint = '0',
      maintenanceStaff = '0',
      normalStaff = '0';
  List<User> registerList = <User>[];
  List<User> unRegisterList = <User>[];
  List<User> activeUserList = <User>[];
  List<User> inactiveUserList = <User>[];
  List<User> mobileUserList = <User>[];
  List<User> notMobileUserList = <User>[];
  List<Block> blockList = <Block>[];
  List<Flat> flatList = <Flat>[];
  List<UnitDetails> unitDetailsList = <UnitDetails>[];
  List<UnitDetails> unitDetailsListForAdmin = <UnitDetails>[];
  List<Member> pendingRequestList = <Member>[];
  List<TenantRentalRequest> rentalRequestList = <TenantRentalRequest>[];
  List<TenantRentalRequest> moveOutRequestList = <TenantRentalRequest>[];

  List<Member> memberList = <Member>[];
  List<TenantRentalRequest> tenantAgreementList = <TenantRentalRequest>[];
  List<Member> tenantList = <Member>[];
  List<Staff> staffList = <Staff>[];
  List<Vehicle> vehicleList = <Vehicle>[];

  List<Member> memberListForAdmin = <Member>[];
  List<TenantRentalRequest> tenantAgreementListForAdmin =
      <TenantRentalRequest>[];
  List<Member> tenantListForAdmin = <Member>[];
  List<Staff> staffListForAdmin = <Staff>[];
  List<Vehicle> vehicleListForAdmin = <Vehicle>[];

  List<Receipt> pendingList = <Receipt>[];
  List<PayOption> payOptionList = <PayOption>[];
  List<Bills> billList = <Bills>[];
  List<Ledger> ledgerList = <Ledger>[];
  List<OpeningBalance> openingBalanceList = <OpeningBalance>[];
  static List<LedgerYear> listYear = <LedgerYear>[];
  double totalOutStanding = 0;
  String openingBalance = "0.0";
  String openingBalanceRemark = "";

  bool hasRazorPayGateway = false;
  bool hasPayTMGateway = false;
  bool hasUPIGateway = false;
  bool hasCcAvenue = false;

  List<HeadWiseExpense> headWiseExpenseList = <HeadWiseExpense>[];
  List<MonthExpenses> monthExpenseList = <MonthExpenses>[];
  List<Receipt> adminPendingList = <Receipt>[];
  String receiptCount = '0';
  String receiptAmount = '0';
  String expenseCount = '0';
  String expenseAmount = '0';

  List<PaymentMethod> preferredMethod = <PaymentMethod>[];
  List<PaymentMethod> otherMethod = <PaymentMethod>[];
  List<PaymentMethod> preferredMethodUPI = <PaymentMethod>[];
  List<PaymentMethod> preferredMethodAvenue = <PaymentMethod>[];
  List<PaymentMethod> otherMethodUPI = <PaymentMethod>[];
  List<PaymentMethod> otherMethodAvenue = <PaymentMethod>[];

  List<Vehicle> pendingVehicleList = <Vehicle>[];

  bool isPayemntLoading = true;

  void setPaymentLoading(bool value) {
    isPayemntLoading = value;
    notifyListeners();
  }

  getPaymentCharges() async {
    if (preferredMethod.isEmpty) {
      isLoading = true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    await restClient.getPaymentCharges().then((value) {
      if (value.status!) {
        List<PaymentPerGateway> razorPay = <PaymentPerGateway>[];
        List<PaymentPerGateway> upi = <PaymentPerGateway>[];
        List<PaymentPerGateway> avenue = <PaymentPerGateway>[];

        razorPay = List<PaymentPerGateway>.from(
            value.Razorpay!.map((i) => PaymentPerGateway.fromJson(i)));

        // upi = List<PaymentPerGateway>.from(
        //     value.UPI.map((i) => PaymentPerGateway.fromJson(i)));

        avenue = List<PaymentPerGateway>.from(
            value.Avenue!.map((i) => PaymentPerGateway.fromJson(i)));

        preferredMethod = List<PaymentMethod>.from(razorPay[0]
            .Preferred_Method!
            .map((i) => PaymentMethod.fromJson(i)));
        otherMethod = List<PaymentMethod>.from(
            razorPay[0].Other_Method!.map((i) => PaymentMethod.fromJson(i)));

        preferredMethodUPI = List<PaymentMethod>.from(
            upi[0].Preferred_Method!.map((i) => PaymentMethod.fromJson(i)));

        otherMethodAvenue = upi[0].Other_Method != null
            ? List<PaymentMethod>.from(
                upi[0].Other_Method!.map((i) => PaymentMethod.fromJson(i)))
            : [];

        preferredMethodAvenue = avenue[0].Preferred_Method != null
            ? List<PaymentMethod>.from(avenue[0]
                .Preferred_Method!
                .map((i) => PaymentMethod.fromJson(i)))
            : [];

        otherMethodAvenue = avenue[0].Other_Method != null
            ? List<PaymentMethod>.from(
                avenue[0].Other_Method!.map((i) => PaymentMethod.fromJson(i)))
            : [];
      }
    });
    isLoading = false;
    notifyListeners();
  }

  Future<dynamic> getPayOption(String? block, String? flat) async {
    isLoading = true;
    notifyListeners();

    hasRazorPayGateway = false;
    hasPayTMGateway = false;
    hasUPIGateway = false;
    hasCcAvenue = false;
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getPayOptionData(societyId).then((value) {
      if (value.status!) {
        isLoading = false;
        notifyListeners();
        List<dynamic> _list = value.data!;
        payOptionList =
            List<PayOption>.from(_list.map((i) => PayOption.fromJson(i)));
        print('before ' + payOptionList.length.toString());
        if (payOptionList.length > 0) {
          payOptionList[0].Message = value.message;
          payOptionList[0].Status = value.status;

          if (payOptionList.length > 0) {
            if ((payOptionList[0].KEY_ID?.isNotEmpty ?? false) &&
                (payOptionList[0].SECRET_KEY?.isNotEmpty ?? false)) {
              hasRazorPayGateway = true;
            }
            if (payOptionList[0].PAYTM_URL?.isNotEmpty ?? false) {
              hasPayTMGateway = true;
            }
            if (payOptionList[0].UPI_URL?.isNotEmpty ?? false) {
              hasUPIGateway = true;
            }
            if (payOptionList[0].CCAVENUE_ACCOUNT_ID?.isNotEmpty ?? false) {
              hasCcAvenue = true;
            }
          }
        }
      }
    }).onError((error, stackTrace) {
      isLoading = true;
      notifyListeners();
    });

    if (block == null && flat == null) {
      block = await GlobalFunctions.getBlock();
      flat = await GlobalFunctions.getFlat();
    }
    getAllBillData(block!, flat!);
    return payOptionList;
  }

  getAllBillData(String? block, String? flat) async {
    if (billList.length == 0) {
      isLoading = true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //String flat = await GlobalFunctions.getFlat();
    // String block = await GlobalFunctions.getBlock();
    //  _progressDialog.show();
    restClientERP
        .getAllBillData(societyId, flat ?? '', block ?? '')
        .then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data!;

      billList = List<Bills>.from(_list.map((i) => Bills.fromJson(i)));

      isLoading = false;
      notifyListeners();
      getLedgerData(null, block ?? '', flat ?? '');
    });
  }

  Future<dynamic> getUnitMemberData() async {
    if (memberList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();

    restClient.getMembersData(societyId, block, flat).then((value) {
      if (value.status!) {
        memberList =
            List<Member>.from(value.members!.map((i) => Member.fromJson(i)));
        staffList =
            List<Staff>.from(value.staff!.map((i) => Staff.fromJson(i)));
        vehicleList =
            List<Vehicle>.from(value.vehicles!.map((i) => Vehicle.fromJson(i)));
        tenantAgreementList = <TenantRentalRequest>[];
        tenantList = <Member>[];
        tenantAgreementList = List<TenantRentalRequest>.from(value
            .Tenant_Agreement!
            .map((i) => TenantRentalRequest.fromJson(i)));

        /*for(int i=0;i<memberList.length;i++){
          if (memberList[i].TYPE == 'Tenant') {
            tenantList.add(memberList[i]);
            //memberList.removeAt(i);
          }
        }
        memberList.removeWhere((item) => item.TYPE == 'Tenant');*/
        for (int i = 0; i < memberList.length; i++) {
          if (memberList[i].ID == userId) {
            memberList.removeAt(i);
            break;
          }
        }

        for (int i = 0; i < tenantAgreementList.length; i++) {
          List<Member> tenant = List<Member>.from(tenantAgreementList[i]
              .tenant_name!
              .map((i) => Member.fromJson(i)));
          for (int j = 0; j < tenant.length; j++) {
            tenant[j].AGREEMENT_ID = tenantAgreementList[i].ID;
            tenantList.add(tenant[j]);
          }
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<List<UnitDetails>> getUnitDetailsMemberForAdminData(
      String block, String flat, bool isDisplayLoading) async {
    if (isDisplayLoading) {
      isLoading = true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    //String block = await GlobalFunctions.getBlock();
    //String flat = await GlobalFunctions.getFlat();
    // String userId = await GlobalFunctions.getUserId();

    await restClient.getMembersData(societyId, block, flat).then((value) {
      if (value.status!) {
        memberListForAdmin =
            List<Member>.from(value.members!.map((i) => Member.fromJson(i)));
        staffListForAdmin =
            List<Staff>.from(value.staff!.map((i) => Staff.fromJson(i)));
        vehicleListForAdmin =
            List<Vehicle>.from(value.vehicles!.map((i) => Vehicle.fromJson(i)));
        unitDetailsListForAdmin = List<UnitDetails>.from(
            value.unit!.map((i) => UnitDetails.fromJson(i)));

        tenantAgreementListForAdmin = <TenantRentalRequest>[];
        tenantListForAdmin = <Member>[];
        tenantAgreementListForAdmin = List<TenantRentalRequest>.from(value
            .Tenant_Agreement!
            .map((i) => TenantRentalRequest.fromJson(i)));

        for (int i = 0; i < tenantAgreementListForAdmin.length; i++) {
          List<Member> tenant = List<Member>.from(tenantAgreementListForAdmin[i]
              .tenant_name!
              .map((i) => Member.fromJson(i)));
          for (int j = 0; j < tenant.length; j++) {
            tenant[j].AGREEMENT_ID = tenantAgreementListForAdmin[i].ID;
            tenantListForAdmin.add(tenant[j]);
          }
        }

        /*
        for(int i=0;i<memberListForAdmin.length;i++){
          if (memberListForAdmin[i].TYPE == 'Tenant') {
            tenantListForAdmin.add(memberListForAdmin[i]);
            //memberList.removeAt(i);
          }
        }

        memberListForAdmin.removeWhere((item) => item.TYPE == 'Tenant');
        print('before tenantList length : ' + tenantListForAdmin.length.toString());

        print('after memberList length : ' + memberListForAdmin.length.toString());*/
      }
    });

    isLoading = false;
    notifyListeners();
    return unitDetailsListForAdmin;
  }

  Future<dynamic> getLedgerData(var year, String block, String flat) async {
    if (ledgerList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    //  String flat = await GlobalFunctions.getFlat();
    // String block = await GlobalFunctions.getBlock();

    try {
      await restClientERP
          .getLedgerData(societyId, flat, block, year ?? '')
          .then((value) {
        logger.wtf(value);
        List<dynamic> _listLedger = value.ledger!;
        List<dynamic> _listPending = value.pending_request!;
        List<dynamic> _listOpeningBalance = value.openingBalance!;
        List<dynamic> _year = value.year!;

        ledgerList =
            List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
        pendingList =
            List<Receipt>.from(_listPending.map((i) => Receipt.fromJson(i)));
        openingBalanceList = List<OpeningBalance>.from(
            _listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));
        listYear =
            List<LedgerYear>.from(_year.map((i) => LedgerYear.fromJson(i)));
        openingBalance = double.parse(openingBalanceList[0].AMOUNT.toString())
            .toStringAsFixed(2);
        openingBalanceRemark = openingBalanceList[0].Remark!;
        double totalAmount = 0;

        for (int i = 0; i < ledgerList.length; i++) {
          print("_ledgerList[i].RECEIPT_NO : " +
              ledgerList[i].RECEIPT_NO.toString());
          print("_ledgerList[i].TYPE : " + ledgerList[i].TYPE.toString());
          if (ledgerList[i].TYPE!.toLowerCase().toString() == 'bill') {
            totalAmount += double.parse(ledgerList[i].AMOUNT!);
          } else {
            totalAmount -= double.parse(ledgerList[i].AMOUNT!);
          }
          totalOutStanding = totalAmount + double.parse(openingBalance);
        }
      });
    } catch (e) {
      logger.e(e);
    }

    isLoading = false;
    notifyListeners();
    return ledgerList;
  }

  Future<dynamic> getStaffList({String? block, String? flat}) async {
    staffList.clear();
    isLoading = true;
    final dio = Dio();
    final assignFlat = flat ?? await GlobalFunctions.getFlat();
    final assignBlock = block ?? await GlobalFunctions.getBlock();

    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    await restClient
        .getAllSocietyStaffData(societyId, assignBlock, assignFlat)
        .then((value) {
      staffList.clear();
      List<dynamic> _list = value.data ?? [];
      final allStaff = List<Staff>.from(_list.map((i) => Staff.fromJson(i)));

      staffList = allStaff
          .where((e) =>
              e.TYPE == 'Helper' &&
              e.ASSIGN_FLATS!.split(',').contains('$assignBlock $assignFlat'))
          .toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<String> getUserManagementDashboard() async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();

    var result = await restClient.getUserManagementDashboard(societyId, userId);

    List<UserManagementDashBoard> _list = List<UserManagementDashBoard>.from(
        result.data!.map((i) => UserManagementDashBoard.fromJson(i)));

    if (_list.length > 0) {
      noOfUnits = _list[0].units!;
      registerUser = _list[0].register_user!;
      activeUser = _list[0].active_user!;
      mobileUser = _list[0].mobile_user!;
      rentalRequest = _list[0].rental_request!;
      pendingRequest = _list[0].pending_request!;
      moveOutRequest = _list[0].moveout_request!;
      smsData = _list[0].sms_data!;
      closeComplaint = _list[0].close_complaint!;
      openComplaint = _list[0].open_complaint!;
      maintenanceStaff = _list[0].maintenanceStaff!;
      normalStaff = _list[0].normalStaff!;
    }

    isLoading = false;
    notifyListeners();

    return smsData;
  }

  getUseTypeList(String type) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.getUseTypeList(societyId, type);

    if (type == 'Registered user')
      registerList = List<User>.from(result.data!.map((i) => User.fromJson(i)));

    if (type == 'logged In')
      activeUserList =
          List<User>.from(result.data!.map((i) => User.fromJson(i)));

    if (type == 'yet to login')
      inactiveUserList =
          List<User>.from(result.data!.map((i) => User.fromJson(i)));

    if (type == 'Mobile user')
      mobileUserList =
          List<User>.from(result.data!.map((i) => User.fromJson(i)));

    if (type == 'Not Mobile user')
      notMobileUserList =
          List<User>.from(result.data!.map((i) => User.fromJson(i)));

    if (type == 'Not yet Registered')
      unRegisterList =
          List<User>.from(result.data!.map((i) => User.fromJson(i)));

    isLoading = false;
    notifyListeners();
  }

  Future<List<Block>> getUnitDetails(String block) async {
    if (blockList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    //String block = await GlobalFunctions.getBlock();

    var result = await restClient.getUnitDetails(societyId, block);

    unitDetailsList = List<UnitDetails>.from(
        result.data!.map((i) => UnitDetails.fromJson(i)));
    blockList = List<Block>.from(result.unit!.map((i) => Block.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return blockList;
  }

  Future<StatusMsgResponse> editUnitDetails(
      String block,
      String ID,
      String consumerNo,
      String parkingSlot,
      String AREA,
      String gstinNo,
      String billingName,
      String INTERCOM) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.editUnitDetails(societyId, ID, consumerNo,
        parkingSlot, AREA, gstinNo, billingName, INTERCOM);

    getUnitDetails(block);
    return result;
  }

  Future<StatusMsgResponse> addMemberByAdmin(
      String block,
      String flat,
      String name,
      String mobile,
      String email,
      String memberType,
      String LivesHere,
      String address,
      String notModerator,
      String? attachment) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.addMemberByAdmin(
        userId,
        societyId,
        block,
        flat,
        name,
        mobile,
        email,
        LivesHere,
        memberType,
        address,
        attachment,
        notModerator,
        societyName);

    return result;
  }

  Future<List<Block>> getBlock() async {
    if (blockList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getBlock(societyId);

    blockList = List<Block>.from(result.data!.map((i) => Block.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return blockList;
  }

  Future<List<Flat>> getFlat(String block) async {
    isLoading = true;
    notifyListeners();

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getFlat(societyId, block);

    flatList = List<Flat>.from(result.data!.map((i) => Flat.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return flatList;
  }

  Future<List<Member>> getPendingMemberRequest() async {
    if (pendingRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getPendingMemberRequest(societyId);

    pendingRequestList =
        List<Member>.from(result.data!.map((i) => Member.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return pendingRequestList;
  }

  Future<List<TenantRentalRequest>> getMoveOutRequest() async {
    if (moveOutRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getMoveOutRequest(societyId);

    moveOutRequestList = List<TenantRentalRequest>.from(
        result.data!.map((i) => TenantRentalRequest.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return moveOutRequestList;
  }

  Future<List<TenantRentalRequest>> getRentalRequest() async {
    if (rentalRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getRentalRequest(societyId);

    rentalRequestList = List<TenantRentalRequest>.from(
        result.data!.map((i) => TenantRentalRequest.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return rentalRequestList;
  }

  Future<StatusMsgResponse> sendInviteAPI(List<String> userId) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.getSendInvite(societyId, societyName, userId);

    getUseTypeList('yet to login');
    return result;
  }

  Future<StatusMsgResponse> approvePendingRequest(String id) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.approvePendingRequest(
        societyId, userId, societyName, id);

    getPendingMemberRequest();
    getUserManagementDashboard();
    return result;
  }

  Future<StatusMsgResponse> deleteFamilyMember(String id) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    var result = await restClient.deleteFamilyMember(id, societyId, userId);

    getPendingMemberRequest();
    getUserManagementDashboard();
    return result;
  }

  Future<StatusMsgResponse> deactivateUser(
      String id, String Reason, String block, String flat) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();

    var result = await restClient.deactivateUser(societyId, userId, Reason, id);

    getUnitDetailsMemberForAdminData(block, flat, false);
    getUserManagementDashboard();
    return result;
  }

  Future<StatusMsgResponse> nocApprove(
    String ID,
    String block,
    String flat,
    String note,
  ) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.nocApprove(
        societyId, ID, block, flat, userId, note, societyName);

    getRentalRequest();
    getUserManagementDashboard();
    return result;
  }

  Future<StatusMsgResponse> addAgreement(
      societyId,
      block,
      flat,
      List<Map<String, String?>> userId,
      String agreementFrom,
      String agreementTo,
      String agreement,
      String rentedTo,
      String? nocIssue,
      String fileType,
      bool isAdmin) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    var result = await restClient.addAgreement(
        societyId,
        block,
        flat,
        userId,
        agreementFrom,
        agreementTo,
        agreement,
        rentedTo,
        nocIssue,
        fileType,
        isAdmin);

    return result;
  }

  Future<StatusMsgResponse> adminAddAgreement(
    List<String> userId,
    String agreementFrom,
    String agreementTo,
    String agreement,
    String rentedTo,
    String block,
    String flat,
    String nocIssue,
  ) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.adminAddAgreementAPI(
        societyId,
        userId,
        agreementFrom,
        agreementTo,
        agreement,
        rentedTo,
        block,
        flat,
        societyName,
        nocIssue);

    return result;
  }

  Future<StatusMsgResponse> renewAgreement(
      String id,
      String agreementFrom,
      String agreementTo,
      String agreement,
      String fileType,
      bool isAdmin) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.renewAgreement(societyId, id, agreementFrom,
        agreementTo, agreement, fileType, isAdmin);

    getUnitMemberData();
    return result;
  }

  Future<StatusMsgResponse> closeAgreement(
    String id,
  ) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getSocietyId();
    var result = await restClient.closeAgreement(societyId, id, userId);

    getUnitMemberData();
    return result;
  }

  Future<dynamic> getMonthExpensePendingRequestData() async {
    if (monthExpenseList.length < 0) {
      isLoading = true;
    }
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClientERP.getMonthExpensePendingRequest(societyId).then((value) {
      receiptCount = value.Receipt_count!;
      receiptAmount = value.Receipt_amount!;
      expenseCount = value.Expense_count!;
      expenseAmount = value.Expense_amount!;
      monthExpenseList = <MonthExpenses>[];
      monthExpenseList = List<MonthExpenses>.from(
          value.expense!.map((i) => MonthExpenses.fromJson(i)));
      adminPendingList = List<Receipt>.from(
          value.pending_request!.map((i) => Receipt.fromJson(i)));
    });
    isLoading = false;
    notifyListeners();
    return monthExpenseList;
  }

  Future<StatusMsgResponse> cancelReceiptRequest(
    String id,
  ) async {
    Dio dio = Dio();
    RestClientERP restClient =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.cancelReceiptRequest(
      societyId,
      id,
    );
    getMonthExpensePendingRequestData();
    return result;
  }

  /* Future<StatusMsgResponse> approveReceiptRequest(
      String id,) async {
    Dio dio = Dio();
    RestClientERP restClient = RestClientERP(dio,baseUrl: GlobalVariables.BaseURLERP);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.approveReceiptRequest(societyId,id,);

    return result;
  }*/

  Future<dynamic> getHeadWiseExpenseData(
      String startDate, String endDate) async {
    if (headWiseExpenseList.length < 0) {
      isLoading = true;
    }
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClientERP
        .getHeadWiseExpenseData(societyId, startDate, endDate)
        .then((value) {
      headWiseExpenseList = List<HeadWiseExpense>.from(
          value.data!.map((i) => HeadWiseExpense.fromJson(i)));
    });
    isLoading = false;
    notifyListeners();
    return headWiseExpenseList;
  }

  Future<StatusMsgResponse> tenantMoveOut(
      String id, String Reason, String block, String flat) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String userId = await GlobalFunctions.getUserId();
    String societyName = await GlobalFunctions.getSocietyName();
    String societyEmail = await GlobalFunctions.getSocietyEmail();

    var result = await restClient.tenantMoveOut(
        societyId, userId, Reason, id, societyName, societyEmail);

    getUnitDetailsMemberForAdminData(block, flat, false);
    getUserManagementDashboard();
    getMoveOutRequest();
    return result;
  }
}

class UserManagementDashBoard {
  String? units,
      sms_data,
      mobile_user,
      register_user,
      active_user,
      rental_request,
      moveout_request,
      pending_request,
      close_complaint,
      open_complaint,
      maintenanceStaff,
      normalStaff;

  UserManagementDashBoard(
      {this.units,
      this.sms_data,
      this.mobile_user,
      this.register_user,
      this.active_user,
      this.moveout_request,
      this.pending_request,
      this.rental_request,
      this.close_complaint,
      this.open_complaint,
      this.maintenanceStaff,
      this.normalStaff});

  factory UserManagementDashBoard.fromJson(Map<String, dynamic> map) {
    return UserManagementDashBoard(
      units: map["units"],
      sms_data: map["sms_data"],
      mobile_user: map["mobile_user"],
      register_user: map["register_user"],
      active_user: map["active_user"],
      moveout_request: map["moveout_request"],
      pending_request: map["pending_request"],
      rental_request: map["rental_request"],
      close_complaint: map["close_complaint"],
      open_complaint: map["open_complaint"],
      maintenanceStaff: map["maintenance_staff"],
      normalStaff: map["staff"],
    );
  }
}

class User {
  String? USER_ID,
      BLOCK,
      FLAT,
      USER_NAME,
      MOBILE,
      gcm_id,
      LAST_LOGIN,
      TYPE,
      NAME;

  User(
      {this.USER_ID,
      this.BLOCK,
      this.FLAT,
      this.USER_NAME,
      this.MOBILE,
      this.gcm_id,
      this.LAST_LOGIN,
      this.TYPE,
      this.NAME});

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      USER_ID: map["USER_ID"],
      BLOCK: map["BLOCK"],
      FLAT: map["FLAT"],
      USER_NAME: map["USER_NAME"],
      MOBILE: map["MOBILE"] ?? '',
      gcm_id: map["gcm_id"] ?? '',
      LAST_LOGIN: map["LAST_LOGIN"],
      TYPE: map["TYPE"],
      NAME: map["NAME"],
    );
  }
}

class UnitDetails {
  String? ID,
      BLOCK,
      FLAT,
      CONSUMER_NO,
      PARKING_SLOT,
      AREA,
      GSTIN_NO,
      BILLING_NAME,
      INTERCOM;
  List<dynamic>? unitMember;

  UnitDetails({
    this.ID,
    this.BLOCK,
    this.FLAT,
    this.CONSUMER_NO,
    this.PARKING_SLOT,
    this.AREA,
    this.GSTIN_NO,
    this.BILLING_NAME,
    this.INTERCOM,
    this.unitMember,
  });

  factory UnitDetails.fromJson(Map<String, dynamic> map) {
    return UnitDetails(
      ID: map["ID"],
      BLOCK: map["BLOCK"],
      FLAT: map["FLAT"],
      CONSUMER_NO: map["CONSUMER_NO"] ?? '',
      PARKING_SLOT: map["PARKING_SLOT"] ?? '',
      AREA: map["AREA"] ?? '',
      GSTIN_NO: map["GSTIN_NO"] ?? '',
      BILLING_NAME: map["BILLING_NAME"],
      INTERCOM: map["INTERCOM"],
      unitMember: map["member"],
    );
  }
}

class Block {
  String? BLOCK;

  Block({this.BLOCK});

  factory Block.fromJson(Map<String, dynamic> map) {
    return Block(
      BLOCK: map["BLOCK"],
    );
  }
}

class Flat {
  String? FLAT;

  Flat({this.FLAT});

  factory Flat.fromJson(Map<String, dynamic> map) {
    return Flat(
      FLAT: map["FLAT"],
    );
  }
}

class UnitMember {
  String? NAME, TYPE;

  UnitMember({this.NAME, this.TYPE});

  factory UnitMember.fromJson(Map<String, dynamic> map) {
    return UnitMember(
      NAME: map["NAME"],
      TYPE: map["TYPE"],
    );
  }
}

class TenantRentalRequest {
  String? ID,
      U_ID,
      RENTED_TO,
      POLICE_VERIFICATION,
      AGREEMENT_FROM,
      AGREEMENT_TO,
      AGREEMENT,
      AUTH_FORM,
      NOC_FORM,
      TENANT_CONSENT,
      OWNER_CONSENT,
      C_DATE,
      STATUS,
      NOTE,
      PROVISIONAL_NOC,
      FINAL_NOC,
      STATUS_UPDATE,
      TERMINATION_DATE,
      BELONGINGS_RETURNED,
      MOVEOUT_LETTER;
  List<dynamic>? tenant_name;

  TenantRentalRequest(
      {this.ID,
      this.U_ID,
      this.RENTED_TO,
      this.POLICE_VERIFICATION,
      this.AGREEMENT_FROM,
      this.AGREEMENT_TO,
      this.AGREEMENT,
      this.AUTH_FORM,
      this.NOC_FORM,
      this.TENANT_CONSENT,
      this.OWNER_CONSENT,
      this.C_DATE,
      this.STATUS,
      this.NOTE,
      this.PROVISIONAL_NOC,
      this.FINAL_NOC,
      this.STATUS_UPDATE,
      this.TERMINATION_DATE,
      this.BELONGINGS_RETURNED,
      this.MOVEOUT_LETTER,
      this.tenant_name});

  factory TenantRentalRequest.fromJson(Map<String, dynamic> map) {
    return TenantRentalRequest(
      ID: map["ID"],
      U_ID: map["U_ID"],
      RENTED_TO: map["RENTED_TO"],
      POLICE_VERIFICATION: map["POLICE_VERIFICATION"],
      AGREEMENT_FROM: map["AGREEMENT_FROM"],
      AGREEMENT_TO: map["AGREEMENT_TO"],
      AGREEMENT: map["AGREEMENT"] ?? '',
      AUTH_FORM: map["AUTH_FORM"] ?? '',
      NOC_FORM: map["NOC_FORM"] ?? '',
      TENANT_CONSENT: map["TENANT_CONSENT"] ?? '',
      OWNER_CONSENT: map["OWNER_CONSENT"] ?? '',
      C_DATE: map["C_DATE"],
      STATUS: map["STATUS"],
      NOTE: map["NOTE"],
      PROVISIONAL_NOC: map["PROVISIONAL_NOC"],
      FINAL_NOC: map["FINAL_NOC"],
      STATUS_UPDATE: map["STATUS_UPDATE"],
      TERMINATION_DATE: map["TERMINATION_DATE"],
      BELONGINGS_RETURNED: map["BELONGINGS_RETURNED"],
      MOVEOUT_LETTER: map["MOVEOUT_LETTER"],
      tenant_name: map["tenant_name"],
    );
  }
}

class Tenant {
  String? NAME,
      PROFILE_PHOTO,
      BLOCK,
      FLAT,
      ID,
      ADDRESS,
      POLICE_VERIFICATION,
      IDENTITY_PROOF,
      EMAIL,
      MOBILE,
      DOB;

  Tenant(
      {this.NAME,
      this.PROFILE_PHOTO,
      this.BLOCK,
      this.FLAT,
      this.ID,
      this.ADDRESS,
      this.POLICE_VERIFICATION,
      this.IDENTITY_PROOF,
      this.EMAIL,
      this.MOBILE,
      this.DOB});

  factory Tenant.fromJson(Map<String, dynamic> map) {
    return Tenant(
      NAME: map["NAME"],
      PROFILE_PHOTO: map["PROFILE_PHOTO"] ?? '',
      BLOCK: map["BLOCK"],
      FLAT: map["FLAT"],
      ID: map["ID"],
      ADDRESS: map["ADDRESS"],
      POLICE_VERIFICATION: map["POLICE_VERIFICATION"] ?? '',
      IDENTITY_PROOF: map["IDENTITY_PROOF"],
      EMAIL: map["EMAIL"] ?? '',
      MOBILE: map["MOBILE"] ?? '',
      DOB: map["DOB"],
    );
  }
}

class HeadWiseExpense {
  String? id, heads, amount;

  HeadWiseExpense({this.id, this.heads, this.amount});

  factory HeadWiseExpense.fromJson(Map<String, dynamic> json) {
    return HeadWiseExpense(
      id: json["id"],
      heads: json["heads"],
      amount: json["amount"],
    );
  }
}
