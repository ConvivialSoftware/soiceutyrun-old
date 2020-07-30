import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Member.dart';

import 'Member.dart';

class GatePassResponse {
  String message;
  String status;

  GatePassResponse({this.message, this.status});


  factory GatePassResponse.fromJson(Map<String, dynamic> map){

    return GatePassResponse(
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
