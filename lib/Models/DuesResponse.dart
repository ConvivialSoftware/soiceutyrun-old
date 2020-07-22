import 'package:json_annotation/json_annotation.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
@JsonSerializable()
class DuesResponse {

  String DUES;
  String DUE_DATE;
  bool status;
  String message;

  DuesResponse({this.DUES, this.DUE_DATE, this.status, this.message});

  factory DuesResponse.fromJson(Map<String, dynamic> map){

    return DuesResponse(
        DUES: map["DUES"],
        DUE_DATE: map["DUE_DATE"],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );
  }

}