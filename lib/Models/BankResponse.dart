import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class BankResponse {
  List<dynamic>? BillDetails;
  List<dynamic>? bank;

  BankResponse({this.BillDetails,this.bank});


  factory BankResponse.fromJson(Map<String, dynamic> json){
    return BankResponse(
        BillDetails: json['BillDetails'],
        bank: json['bank']
    );
  }


}
