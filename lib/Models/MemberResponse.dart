import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class MemberResponse {
  List<dynamic>? members;
  List<dynamic>? staff;
  List<dynamic>? vehicles;
  List<dynamic>? unit;
  List<dynamic>? Tenant_Agreement;
  String? message;
  bool? status;

  MemberResponse({this.members,this.staff, this.vehicles,this.unit,this.message, this.status,this.Tenant_Agreement});


  factory MemberResponse.fromJson(Map<String, dynamic> map){

    return MemberResponse(
        members: map['members'],
        staff: map['staff'],
        vehicles: map['vehicles'],
        unit: map['unit'],
        Tenant_Agreement: map['Tenant_Agreement'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
