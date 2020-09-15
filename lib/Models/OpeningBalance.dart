import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class OpeningBalance {

  String AMOUNT;
  String DATE;


  OpeningBalance({this.AMOUNT, this.DATE});

  factory OpeningBalance.fromJson(Map<String, dynamic> map){

    return OpeningBalance(
      AMOUNT: map["AMOUNT"],
      DATE: map["DATE"],
    );
  }

}