import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class MemberResponse {
  List<dynamic> members;
  List<dynamic> staff;
  List<dynamic> vehicles;
  List<dynamic> unit;
  String message;
  bool status;

  MemberResponse({this.members,this.staff, this.vehicles,this.unit,this.message, this.status});


  factory MemberResponse.fromJson(Map<String, dynamic> map){

    return MemberResponse(
        members: map['members'],
        staff: map['staff'],
        vehicles: map['vehicles'],
        unit: map['unit'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
