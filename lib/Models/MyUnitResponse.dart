import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Bills.dart';
import 'package:societyrun/Models/Ledger.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/Member.dart';
import 'package:societyrun/Models/OpeningBalance.dart';
import 'package:societyrun/Models/PayOption.dart';
import 'package:societyrun/Models/Receipt.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/Vehicle.dart';
import 'package:societyrun/Retrofit/RestClient.dart';
import 'package:societyrun/Retrofit/RestClientERP.dart';

class MyUnitResponse extends ChangeNotifier{

  List<Member> memberList = new List<Member>();
  List<Staff> staffList = new List<Staff>();
  List<Vehicle> vehicleList = new List<Vehicle>();



  List<Receipt> pendingList = new List<Receipt>();
  List<PayOption> payOptionList = new List<PayOption>();
  List<Bills> billList = new List<Bills>();
  List<Ledger> ledgerList = new List<Ledger>();
  List<OpeningBalance> openingBalanceList = new List<OpeningBalance>();
  static List<LedgerYear> listYear = List<LedgerYear>();
  double totalOutStanding = 0;
  String openingBalance = "0.0";
  String openingBalanceRemark = "";


  bool isLoading = true;
  String errMsg;


  Future<dynamic> getPayOption() async {

    if(payOptionList.length==0){
      isLoading=true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

    await restClient.getPayOptionData(societyId).then((value) {

      if (value.status) {
        List<dynamic> _list = value.data;
        payOptionList = List<PayOption>.from(_list.map((i) => PayOption.fromJson(i)));
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

    if(billList.length==0){
      isLoading=true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();
    //  _progressDialog.show();
    restClientERP.getAllBillData(societyId, flat, block).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _list = value.data;

      billList = List<Bills>.from(_list.map((i) => Bills.fromJson(i)));

      isLoading=false;
      notifyListeners();
      getLedgerData(null);

    });
  }

  Future<dynamic> getUnitMemberData() async {

    if(memberList.length==0){
      isLoading=true;
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
        vehicleList = List<Vehicle>.from(vehicles.map((i) => Vehicle.fromJson(i)));
        for (int i = 0; i < memberList.length; i++) {
          if (memberList[i].ID == userId) {
            memberList.removeAt(i);
            break;
          }
        }
      }
      isLoading=false;
      notifyListeners();
    });
  }

  Future<dynamic> getLedgerData(var year) async {

    if(ledgerList.length==0){
      isLoading=true;
      notifyListeners();
    }

    final dio = Dio();
    final RestClientERP restClientERP =
    RestClientERP(dio, baseUrl: GlobalVariables.BaseURLERP);
    String societyId = await GlobalFunctions.getSocietyId();
    String flat = await GlobalFunctions.getFlat();
    String block = await GlobalFunctions.getBlock();

    await restClientERP.getLedgerData(societyId, flat, block, year).then((value) {
      print('Response : ' + value.toString());
      List<dynamic> _listLedger = value.ledger;
      List<dynamic> _listOpeningBalance = value.openingBalance;
      List<dynamic> _year = value.year;

      ledgerList = List<Ledger>.from(_listLedger.map((i) => Ledger.fromJson(i)));
      openingBalanceList = List<OpeningBalance>.from(_listOpeningBalance.map((i) => OpeningBalance.fromJson(i)));
      listYear = List<LedgerYear>.from(_year.map((i) => LedgerYear.fromJson(i)));
      openingBalance = double.parse(openingBalanceList[0].AMOUNT.toString()).toStringAsFixed(2);
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
    isLoading=false;
    notifyListeners();
    return ledgerList;
  }

}