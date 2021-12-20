import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class OpeningBalance {

  String? AMOUNT;
  String? DATE;
  String? Remark;


  OpeningBalance({this.AMOUNT, this.DATE,this.Remark});

  factory OpeningBalance.fromJson(Map<String, dynamic> map){

    return OpeningBalance(
      AMOUNT: map["AMOUNT"],
      DATE: map["DATE"],
      Remark: map["Remark"]??'',
    );
  }

}