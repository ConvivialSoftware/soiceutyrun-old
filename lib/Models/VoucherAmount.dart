import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class VoucherAmount {
  String? head_name;
  String? amount;

  VoucherAmount({this.head_name, this.amount});


  factory VoucherAmount.fromJson(Map<String, dynamic> json){

    return VoucherAmount(
        head_name: json['head_name'],
        amount: json['amount']
    );
  }


}
