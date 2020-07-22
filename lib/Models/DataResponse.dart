import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/Member.dart';

import 'Member.dart';

class DataResponse {
  List<dynamic> data;
  String message;
  bool status;

  DataResponse({this.data, this.message, this.status});


  factory DataResponse.fromJson(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
