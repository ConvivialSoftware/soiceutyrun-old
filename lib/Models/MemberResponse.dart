import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class MemberResponse {
  List<dynamic> data;
  String message;
  bool status;

  MemberResponse({this.data, this.message, this.status});


  factory MemberResponse.fromJson(Map<String, dynamic> map){

    return MemberResponse(
        data: map['members'],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}
