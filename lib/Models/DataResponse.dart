import 'package:societyrun/GlobalClasses/GlobalVariables.dart';


class DataResponse {
  List<dynamic> service;
  List<dynamic> refer;
  List<dynamic> data;
  List<dynamic> front;
  List<dynamic> bank;
  List<dynamic> category;
  List<dynamic> Year;
  List<dynamic> unit;
  List<dynamic> Role;
  String message;
  String android_version;
  String android_type;
  String ios_version;
  String ios_type;
  bool status;
  String dataString;
  int AMOUNT;
  int PENALTY;

  DataResponse({this.data, this.message, this.status,
    this.android_version,this.android_type,this.ios_version,
    this.ios_type,this.front,this.refer,this.service,this.bank,this.category,this.Year,
    this.unit,this.dataString,this.PENALTY,this.AMOUNT,this.Role});


  factory DataResponse.fromJson(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }

  factory DataResponse.fromJsonWithVersion(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE],
        android_version:map[GlobalVariables.android_version],
        android_type:map[GlobalVariables.android_type],
        ios_version:map[GlobalVariables.ios_version],
        ios_type:map[GlobalVariables.ios_type]
    );

  }

  factory DataResponse.fromJsonBanner(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        front: map[GlobalVariables.Front],
        refer: map[GlobalVariables.refer],
        service: map[GlobalVariables.service],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }

  factory DataResponse.fromJsonExpense(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        bank : map[GlobalVariables.bank],
        Year : map[GlobalVariables.Year],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }

  factory DataResponse.fromJsonDiscover(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        category : map[GlobalVariables.category],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }


  factory DataResponse.fromJsonUnitDetails(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        unit : map[GlobalVariables.unit],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }

  factory DataResponse.fromJsonDataAsString(Map<String, dynamic> map){

    return DataResponse(
        dataString: map[GlobalVariables.DATA],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }

  factory DataResponse.fromAmountCalculationJson(Map<String, dynamic> map) {
    return DataResponse(
        //dataString: map[GlobalVariables.DATA],
        PENALTY: map["PENALTY"],
        AMOUNT: map["AMOUNT"],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );
  }

  factory DataResponse.fromJsonStaffRole(Map<String, dynamic> map){

    return DataResponse(
        data: map[GlobalVariables.DATA],
        Role : map[GlobalVariables.Role],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
