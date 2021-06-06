import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

class UserManagementResponse extends ChangeNotifier {
  bool isLoading = true;
  String errMsg;
  String noOfUnits = '0',
      registerUser = '0',
      activeUser = '0',
      mobileUser = '0',
      rentalRequest = '0',
      pendingRequest = '0',
      moveOutRequest = '0',
      sms_data = '0';
  List<User> registerList = List<User>();
  List<User> unRegisterList = List<User>();
  List<User> activeUserList = List<User>();
  List<User> inactiveUserList = List<User>();
  List<User> mobileUserList = List<User>();
  List<User> notMobileUserList = List<User>();
  List<Block> blockList = List<Block>();
  List<Flat> flatList = List<Flat>();
  List<UnitDetails> unitDetailsList = List<UnitDetails>();
  List<UnitDetails> unitDetailsListForAdmin = List<UnitDetails>();
  List<Member> pendingRequestList = List<Member>();
  List<RentalRequest> rentalRequestList = List<RentalRequest>();
  List<RentalRequest> moveOutRequestList = List<RentalRequest>();

  List<Member> memberList = new List<Member>();
  List<Member> tenantList = new List<Member>();
  List<Staff> staffList = new List<Staff>();
  List<Vehicle> vehicleList = new List<Vehicle>();

  List<Member> memberListForAdmin = new List<Member>();
  List<Member> tenantListForAdmin = new List<Member>();
  List<Staff> staffListForAdmin = new List<Staff>();
  List<Vehicle> vehicleListForAdmin = new List<Vehicle>();

  List<Receipt> pendingList = new List<Receipt>();
  List<PayOption> payOptionList = new List<PayOption>();
  List<Bills> billList = new List<Bills>();
  List<Ledger> ledgerList = new List<Ledger>();
  List<OpeningBalance> openingBalanceList = new List<OpeningBalance>();
  static List<LedgerYear> listYear = List<LedgerYear>();
  double totalOutStanding = 0;
  String openingBalance = "0.0";
  String openingBalanceRemark = "";

  Future<dynamic> getPayOption() async {
    if (payOptionList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getPayOptionData(societyId).then((value) {
      if (value.status) {
        List<dynamic> _list = value.data;
        payOptionList =
            List<PayOption>.from(_list.map((i) => PayOption.fromJson(i)));
        print('before ' + payOptionList.length.toString());
        if (payOptionList.length > 0) {
          payOptionList[0].Message = value.message;
          payOptionList[0].Status = value.status;
        }
      }
    });

    getAllBillData();
    return payOptionList;
  }

  getAllBillData() async {
    if (billList.length == 0) {
      isLoading = true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERPView);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    //  _progressDialog.show();
    restClientERP.getAllBillData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;

      billList = List<Bills>.from(_list.map((i) => Bills.fromJson(i)));

      isLoading = false;
      notifyListeners();
      getLedgerData(null);
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
      if (value.status) {
        List<dynamic> _members = value.members;
        List<dynamic> staff = value.staff;
        List<dynamic> vehicles = value.vehicles;

        memberList = List<Member>.from(_members.map((i) => Member.fromJson(i)));
        staffList = List<Staff>.from(staff.map((i) => Staff.fromJson(i)));
        vehicleList =
            List<Vehicle>.from(vehicles.map((i) => Vehicle.fromJson(i)));
        tenantList = new List<Member>();
        for(int i=0;i<memberList.length;i++){
          if (memberList[i].TYPE == 'Tenant') {
            tenantList.add(memberList[i]);
            //memberList.removeAt(i);
          }
        }
        memberList.removeWhere((item) => item.TYPE == 'Tenant');
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<List<UnitDetails>> getUnitDetailsMemberForAdminData(
      String block, String flat,bool isDisplayLoading) async {

    if(isDisplayLoading) {
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
      if (value.status) {
        List<dynamic> _members = value.members;
        List<dynamic> staff = value.staff;
        List<dynamic> vehicles = value.vehicles;
        List<dynamic> unit = value.unit;

        memberListForAdmin = List<Member>.from(_members.map((i) => Member.fromJson(i)));
        print('before memberList length : ' + memberList.length.toString());
        staffListForAdmin = List<Staff>.from(staff.map((i) => Staff.fromJson(i)));
        vehicleListForAdmin =
            List<Vehicle>.from(vehicles.map((i) => Vehicle.fromJson(i)));
        unitDetailsListForAdmin =
            List<UnitDetails>.from(unit.map((i) => UnitDetails.fromJson(i)));
        tenantListForAdmin = new List<Member>();

        for(int i=0;i<memberListForAdmin.length;i++){
          if (memberListForAdmin[i].TYPE == 'Tenant') {
            tenantListForAdmin.add(memberListForAdmin[i]);
            //memberList.removeAt(i);
          }
        }

        memberListForAdmin.removeWhere((item) => item.TYPE == 'Tenant');
        print('before tenantList length : ' + tenantListForAdmin.length.toString());

        print('after memberList length : ' + memberListForAdmin.length.toString());
      }
    });

    isLoading = false;
    notifyListeners();
    return unitDetailsListForAdmin;
  }

  Future<dynamic> getLedgerData(var year) async {
    if (ledgerList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClientERP restClientERP =
        RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();

    await restClientERP
        .getLedgerData(societyId, flat, block, year)
        .then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _listLedger = value.ledger;
      List<dynamic> _listOpeningBalance = value.openingBalance;
      List<dynamic> _year = value.year;

      ledgerList =
          List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
      openingBalanceList = List<OpeningBalance>.from(
          _listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));
      listYear =
          List<LedgerYear>.from(_year.map((i) => LedgerYear.fromJson(i)));
      openingBalance = double.parse(openingBalanceList[0].AMOUNT.toString())
          .toStringAsFixed(2);
      openingBalanceRemark = openingBalanceList[0].Remark;
      double totalAmount = 0;

      for (int i = 0; i < ledgerList.length; i++) {
        print("_ledgerList[i].RECEIPT_NO : " +
            ledgerList[i].RECEIPT_NO.toString());
        print("_ledgerList[i].TYPE : " + ledgerList[i].TYPE.toString());
        if (ledgerList[i].TYPE.toLowerCase().toString() == 'bill') {
          totalAmount += double.parse(ledgerList[i].AMOUNT);
        } else {
          totalAmount -= double.parse(ledgerList[i].AMOUNT);
        }
        totalOutStanding = totalAmount + double.parse(openingBalance);
      }
    });
    isLoading = false;
    notifyListeners();
    return ledgerList;
  }

  Future<String> getUserManagementDashboard() async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.getUserManagementDashboard(societyId);

    List<UserManagementDashBoard> _list = List<UserManagementDashBoard>.from(
        result.data.map((i) => UserManagementDashBoard.fromJson(i)));

    if (_list.length > 0) {
      noOfUnits = _list[0].units;
      registerUser = _list[0].register_user;
      activeUser = _list[0].active_user;
      mobileUser = _list[0].mobile_user;
      rentalRequest = _list[0].rental_request;
      pendingRequest = _list[0].pending_request;
      moveOutRequest = _list[0].moveout_request;
      sms_data = _list[0].sms_data;
    }

    isLoading = false;
    notifyListeners();

    return sms_data;
  }

  getUseTypeList(String type) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.getUseTypeList(societyId, type);

    if (type == 'Registered user')
      registerList = List<User>.from(result.data.map((i) => User.fromJson(i)));

    if (type == 'logged In')
      activeUserList =
          List<User>.from(result.data.map((i) => User.fromJson(i)));

    if (type == 'yet to login')
      inactiveUserList =
          List<User>.from(result.data.map((i) => User.fromJson(i)));

    if (type == 'Mobile user')
      mobileUserList =
          List<User>.from(result.data.map((i) => User.fromJson(i)));

    if (type == 'Not Mobile user')
      notMobileUserList =
          List<User>.from(result.data.map((i) => User.fromJson(i)));

    if (type == 'Not yet Registered')
      unRegisterList =
          List<User>.from(result.data.map((i) => User.fromJson(i)));

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

    unitDetailsList =
        List<UnitDetails>.from(result.data.map((i) => UnitDetails.fromJson(i)));
    blockList = List<Block>.from(result.unit.map((i) => Block.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return blockList;
  }

  Future<StatusMsgResponse> editUnitDetails(
      String block,
      String ID,
      String CONSUMER_NO,
      String PARKING_SLOT,
      String AREA,
      String GSTIN_NO,
      String BILLING_NAME,
      String INTERCOM) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.editUnitDetails(societyId, ID, CONSUMER_NO,
        PARKING_SLOT, AREA, GSTIN_NO, BILLING_NAME, INTERCOM);

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
      String attachment) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.addMemberByAdmin(
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

    blockList = List<Block>.from(result.data.map((i) => Block.fromJson(i)));

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

    flatList = List<Flat>.from(result.data.map((i) => Flat.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return flatList;
  }

  Future<List<Member>> getPendingRequest() async {
    if (pendingRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getPendingRequest(societyId);

    pendingRequestList =
        List<Member>.from(result.data.map((i) => Member.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return pendingRequestList;
  }

  Future<List<RentalRequest>> getMoveOutRequest() async {
    if (moveOutRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getMoveOutRequest(societyId);

    moveOutRequestList = List<RentalRequest>.from(
        result.data.map((i) => RentalRequest.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return moveOutRequestList;
  }

  Future<List<RentalRequest>> getRentalRequest() async {
    if (rentalRequestList.length == 0) {
      isLoading = true;
      notifyListeners();
    }

    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    var result = await restClient.getRentalRequest(societyId);

    rentalRequestList = List<RentalRequest>.from(
        result.data.map((i) => RentalRequest.fromJson(i)));

    isLoading = false;
    notifyListeners();

    return rentalRequestList;
  }

  Future<StatusMsgResponse> sendInviteAPI(List<String> user_id) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result =
        await restClient.getSendInvite(societyId, societyName, user_id);

    getUseTypeList('yet to login');
    return result;
  }

  Future<StatusMsgResponse> approvePendingRequest(String id) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result =
        await restClient.approvePendingRequest(societyId, societyName, id);

    getPendingRequest();
    return result;
  }

  Future<StatusMsgResponse> deleteFamilyMember(String id) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();

    var result = await restClient.deleteFamilyMember(id, societyId);

    getPendingRequest();
    return result;
  }

  Future<StatusMsgResponse> deactivateUser(String id,String Reason,String block,String flat) async {
    Dio dio = Dio();
    RestClient restClient = RestClient(dio);

    String societyId = await GlobalFunctions.getSocietyId();

    var result = await restClient.deactivateUser(societyId,Reason,id);

    getUnitDetailsMemberForAdminData(block,flat,false);
    return result;
  }
}

class UserManagementDashBoard {
  String units,
      sms_data,
      mobile_user,
      register_user,
      active_user,
      rental_request,
      moveout_request,
      pending_request;

  UserManagementDashBoard(
      {this.units,
      this.sms_data,
      this.mobile_user,
      this.register_user,
      this.active_user,
      this.moveout_request,
      this.pending_request,
      this.rental_request});

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
    );
  }
}

class User {
  String USER_ID,
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
  String ID,
      BLOCK,
      FLAT,
      CONSUMER_NO,
      PARKING_SLOT,
      AREA,
      GSTIN_NO,
      BILLING_NAME,
      INTERCOM;
  List<dynamic> unitMember;

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
  String BLOCK;

  Block({this.BLOCK});

  factory Block.fromJson(Map<String, dynamic> map) {
    return Block(
      BLOCK: map["BLOCK"],
    );
  }
}

class Flat {
  String FLAT;

  Flat({this.FLAT});

  factory Flat.fromJson(Map<String, dynamic> map) {
    return Flat(
      FLAT: map["FLAT"],
    );
  }
}

class UnitMember {
  String NAME, TYPE;

  UnitMember({this.NAME, this.TYPE});

  factory UnitMember.fromJson(Map<String, dynamic> map) {
    return UnitMember(
      NAME: map["NAME"],
      TYPE: map["TYPE"],
    );
  }
}

class RentalRequest {
  String ID,
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
  List<dynamic> tenant_name;

  RentalRequest(
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

  factory RentalRequest.fromJson(Map<String, dynamic> map) {
    return RentalRequest(
      ID: map["ID"],
      U_ID: map["U_ID"],
      RENTED_TO: map["RENTED_TO"],
      POLICE_VERIFICATION: map["POLICE_VERIFICATION"],
      AGREEMENT_FROM: map["AGREEMENT_FROM"],
      AGREEMENT_TO: map["AGREEMENT_TO"],
      AGREEMENT: map["AGREEMENT"]??'',
      AUTH_FORM: map["AUTH_FORM"]??'',
      NOC_FORM: map["NOC_FORM"]??'',
      TENANT_CONSENT: map["TENANT_CONSENT"]??'',
      OWNER_CONSENT: map["OWNER_CONSENT"]??'',
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
  String NAME,
      PROFILE_PHOTO,
      BLOCK,
      FLAT,
      ID,
      ADDRESS,
      POLICE_VERIFICATION,
      IDENTITY_PROOF,
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
      this.DOB});

  factory Tenant.fromJson(Map<String, dynamic> map) {
    return Tenant(
      NAME: map["NAME"],
      PROFILE_PHOTO: map["PROFILE_PHOTO"],
      BLOCK: map["BLOCK"],
      FLAT: map["FLAT"],
      ID: map["ID"],
      ADDRESS: map["ADDRESS"],
      POLICE_VERIFICATION: map["POLICE_VERIFICATION"]??'',
      IDENTITY_PROOF: map["IDENTITY_PROOF"],
      DOB: map["DOB"],
    );
  }
}
