import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class Ledger {
  String RECEIPT_NO;
  String LEDGER;
  String NARRATION;
  String TYPE;
  String LEDGER_TYPE;
  String PURPOSE;
  String NAME;
  String AMOUNT;
  String C_DATE;
  String REMARK;

  Ledger({this.RECEIPT_NO, this.LEDGER, this.NARRATION, this.TYPE,
    this.LEDGER_TYPE, this.PURPOSE, this.NAME, this.AMOUNT,
    this.C_DATE, this.REMARK});


  factory Ledger.fromJson(Map<String, dynamic> json){

    return Ledger(
        RECEIPT_NO: json['RECEIPT_NO'],
        LEDGER: json['LEDGER'],
        NARRATION: json['NARRATION'],
        TYPE: json['TYPE'],
        LEDGER_TYPE: json['LEDGER_TYPE'],
        PURPOSE: json['PURPOSE'],
        NAME: json['NAME'],
        AMOUNT: json['AMOUNT'],
        C_DATE: json['C_DATE'],
        REMARK: json['REMARK']
    );
  }


}
