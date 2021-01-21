import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class MemberResponse {
  List<dynamic> members;
  List<dynamic> staff;
  List<dynamic> vehicles;
  String message;
  bool status;

  MemberResponse({this.members,this.staff, this.vehicles,this.message, this.status});


  factory MemberResponse.fromJson(Map<String, dynamic> map){

    return MemberResponse(
        members: map['members'],
        staff: map['staff'],
        vehicles: map['vehicles'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
