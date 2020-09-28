import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

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
