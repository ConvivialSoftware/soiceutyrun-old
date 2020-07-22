import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Member.dart';

import 'Member.dart';

class VehicleResponse {
  List<dynamic> data;
  String message;
  bool status;

  VehicleResponse({this.data, this.message, this.status});


  factory VehicleResponse.fromJson(Map<String, dynamic> map){

    return VehicleResponse(
        data: map['vehicles'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
