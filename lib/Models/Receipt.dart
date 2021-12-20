import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Receipt {
  String? ID;
  String? RECEIPT_NO;
  String? INVOICE_NO;
  String? FLAT_NO;
  String? NAME;
  String? PURPOSE;
  int? AMOUNT;
  String? PENALTY_AMOUNT;
  String? TRANSACTION_MODE;
  String? REFERENCE_NO;
  String? BANK_ACCOUNTNO;
  String? PAYMENT_DATE;
  String? CLEARANCE_DATE;
  String? ATTACHMENT;
  String? NARRATION;
  String? CHEQUE_BANKNAME;
  String? STATUS;
  String? RECONCILE;
  String? CANCEL_REASON;
  String? CANCEL_BY;
  String? ADDED_BY;
  String? C_DATE;

  Receipt(
      {this.ID,
      this.RECEIPT_NO,
      this.INVOICE_NO,
      this.FLAT_NO,
      this.NAME,
      this.PURPOSE,
      this.AMOUNT,
      this.PENALTY_AMOUNT,
      this.TRANSACTION_MODE,
      this.REFERENCE_NO,
      this.BANK_ACCOUNTNO,
      this.PAYMENT_DATE,
      this.CLEARANCE_DATE,
      this.ATTACHMENT,
      this.NARRATION,
      this.CHEQUE_BANKNAME,
      this.STATUS,
      this.RECONCILE,
      this.CANCEL_REASON,
      this.CANCEL_BY,
      this.ADDED_BY,
      this.C_DATE});

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
        ID: json['ID'],
        RECEIPT_NO: json['RECEIPT_NO'],
        INVOICE_NO: json['INVOICE_NO'],
        FLAT_NO: json['FLAT_NO'],
        NAME: json['NAME'],
        PURPOSE: json['PURPOSE'],
        AMOUNT: json['AMOUNT']??0,
        PENALTY_AMOUNT: json['PENALTY_AMOUNT']??"0",
        TRANSACTION_MODE: json['TRANSACTION_MODE'],
        REFERENCE_NO: json['REFERENCE_NO'],
        BANK_ACCOUNTNO: json['BANK_ACCOUNTNO'],
        PAYMENT_DATE: json['PAYMENT_DATE']??"",
        CLEARANCE_DATE: json['CLEARANCE_DATE'],
        ATTACHMENT: json['ATTACHMENT'],
        NARRATION: json['NARRATION'],
        CHEQUE_BANKNAME: json['CHEQUE_BANKNAME'],
        STATUS: json['STATUS'],
        RECONCILE: json['RECONCILE'],
        CANCEL_REASON: json['CANCEL_REASON'],
        CANCEL_BY: json['CANCEL_BY'],
        ADDED_BY: json['ADDED_BY'],
        C_DATE: json['C_DATE']);
  }
}
