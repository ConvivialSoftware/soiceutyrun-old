import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StaffCount {
  String ROLE;
  String Role_count;

  StaffCount({this.ROLE, this.Role_count});


  factory StaffCount.fromJson(Map<String, dynamic> json){

    return StaffCount(
        ROLE: json['ROLE'],
        Role_count: json['Role_count']
    );
  }


}
