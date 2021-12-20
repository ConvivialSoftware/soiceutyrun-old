import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Expense {
  String? ID;
  String? VOUCHER_NO;
  String? VOUCHER_REFENCE_NO;
  String? AMOUNT;
  String? TRANSACTION_TYPE;
  String? REFERENCE_NO;
  String? BANK;
  String? STATUS;
  String? ATTACHMENT;
  String? REMARK;
  String? PAYMENT_DATE;
  String? CHEQUE_CLEARANCE_DATE;
  String? C_DATE;
  String? ADDED_BY;
  String? name;
  String? BANK_NAME;
  List<dynamic>? head_details;
  Expense({this.ID, this.VOUCHER_NO, this.VOUCHER_REFENCE_NO, this.AMOUNT,
    this.TRANSACTION_TYPE, this.REFERENCE_NO, this.BANK, this.STATUS,
    this.ATTACHMENT, this.REMARK, this.PAYMENT_DATE, this.CHEQUE_CLEARANCE_DATE,
    this.C_DATE, this.ADDED_BY,this.name,this.BANK_NAME,this.head_details});


  factory Expense.fromJson(Map<String, dynamic> json){
    return Expense(
        ID: json['ID'],
        VOUCHER_NO: json['VOUCHER_NO'],
        VOUCHER_REFENCE_NO: json['VOUCHER_REFENCE_NO'],
        AMOUNT: json['AMOUNT'],
        TRANSACTION_TYPE: json['TRANSACTION_TYPE'],
        REFERENCE_NO: json['REFERENCE_NO'],
        BANK: json['BANK'],
        STATUS: json['STATUS'],
        ATTACHMENT: json['ATTACHMENT']??'',
        REMARK: json['REMARK'],
        PAYMENT_DATE: json['PAYMENT_DATE'],
        CHEQUE_CLEARANCE_DATE: json['CHEQUE_CLEARANCE_DATE'],
        C_DATE: json['C_DATE'],
        ADDED_BY: json['ADDED_BY'],
        name: json['name'],
        BANK_NAME: json['BANK_NAME'],
        head_details: json['head_details'],

    );
  }
}
