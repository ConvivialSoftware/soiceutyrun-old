import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class AllMemberResponse {
  List<dynamic>? neighbour;
  List<dynamic>? committee;
  List<dynamic>? emergency;
  String? message;
  bool? status;

  AllMemberResponse({this.neighbour,this.committee,this.emergency, this.message, this.status});


  factory AllMemberResponse.fromJson(Map<String, dynamic> map){

    return AllMemberResponse(
        neighbour: map[GlobalVariables.society_member],
        committee: map[GlobalVariables.commitee_member],
        emergency: map[GlobalVariables.emergency],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
