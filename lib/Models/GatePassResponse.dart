import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/ScheduleVisitor.dart';
import 'package:societyrun/Models/Staff.dart';
import 'package:societyrun/Models/StaffCount.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'package:societyrun/Models/Visitor.dart';
import 'package:societyrun/Retrofit/RestClient.dart';


class GatePass extends ChangeNotifier{

  List<Visitor> visitorList = List<Visitor>();
  List<ScheduleVisitor> scheduleVisitorList = List<ScheduleVisitor>();
  List<StaffCount> staffListCount = List<StaffCount>();
  List<Staff> staffList = List<Staff>();
  bool isLoading = true;
  String errMsg;



  Future<List<Visitor>> getGatePassData() async {
    try {
      print('getClassifiedData');
      final dio = Dio();
      final RestClient restClient = RestClient(dio);

      String societyId = await GlobalFunctions.getSocietyId();
      String block = await GlobalFunctions.getBlock();
      String flat = await GlobalFunctions.getFlat();

      await restClient.getGatePassData(societyId,block,flat).then((value) {
        visitorList = List<Visitor>.from(value.visitor.map((i) => Visitor.fromJson(i)));
        print('_visitor length : ' + visitorList.length.toString());
        scheduleVisitorList = List<ScheduleVisitor>.from(
            value.schedule_visitor.map((i) => ScheduleVisitor.fromJson(i)));
        isLoading = false;
        notifyListeners();

      });
    } catch (e) {
      errMsg = e.toString();
      print('errMsg : '+errMsg);
      isLoading = false;
      notifyListeners();
    }
    return visitorList;
  }


  Future<StatusMsgResponse> addScheduleVisitorGatePass(name,mobile,_selectedSchedule) async {
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String userId = await GlobalFunctions.getUserId();


    var result  = await restClient.addScheduleVisitorGatePass(
        societyId,
        block,
        flat,
        name,
        mobile,
        _selectedSchedule,
        userId);

    return result;
  }


  Future<dynamic> getStaffCountData(String staffType) async {


    if(staffListCount.length==0){
      isLoading=true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();

   await restClient.staffCount(societyId,staffType).then((value) {
      List<dynamic> _list = value.data;
      staffListCount = List<StaffCount>.from(_list.map((i)=>StaffCount.fromJson(i)));
      print('staffList : '+staffListCount.toString());
      isLoading=false;
      notifyListeners();
    });

    return staffListCount;

  }

  Future<dynamic> getStaffRoleDetailsData(String roleName) async {

    if(staffList.length==0){
      isLoading=true;
      notifyListeners();
    }
    final dio = Dio();
    final RestClient restClient = RestClient(dio);
    String societyId = await GlobalFunctions.getSocietyId();
   await  restClient.staffRoleDetails(societyId, roleName).then((value) {

      List<dynamic> _list = value.data;
      staffList = List<Staff>.from(_list.map((i) => Staff.fromJson(i)));
      isLoading=false;
      notifyListeners();
    });

  }


}

class GatePassResponse {
  List<dynamic> visitor;
  List<dynamic> schedule_visitor;
  String message;
  bool status;

  GatePassResponse({this.visitor,this.schedule_visitor, this.message, this.status});


  factory GatePassResponse.fromJson(Map<String, dynamic> map){

    return GatePassResponse(
        visitor: map['visitor'],
        schedule_visitor: map['schedule_visitor'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
