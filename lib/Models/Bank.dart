import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Bank {
  String ACCOUNT_NO;
  String BANK_NAME;
  String ID;
  String BANK_BRANCH;
  String IFSC_CODE;
  String ACCOUNT_TYPE;
  String REMARK;
  String OPENING_BALANCE;
  String RECEIVE_PAYMENT;
  String STATUS;

  Bank({this.ACCOUNT_NO, this.BANK_NAME, this.ID, this.BANK_BRANCH,
    this.IFSC_CODE, this.ACCOUNT_TYPE, this.REMARK,
    this.OPENING_BALANCE, this.RECEIVE_PAYMENT, this.STATUS,});


  factory Bank.fromJson(Map<String, dynamic> json){
    return Bank(
        ACCOUNT_NO: json['ACCOUNT_NO'],
        BANK_NAME: json['BANK_NAME'],
        ID: json['ID'],
        BANK_BRANCH: json['BANK_BRANCH'],
        IFSC_CODE: json['IFSC_CODE'],
        ACCOUNT_TYPE: json['ACCOUNT_TYPE'],
        REMARK: json['REMARK'],
        OPENING_BALANCE: json['OPENING_BALANCE'],
        RECEIVE_PAYMENT: json['RECEIVE_PAYMENT'],
        STATUS: json['STATUS']
    );
  }


}
