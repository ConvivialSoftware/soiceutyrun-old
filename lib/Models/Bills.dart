import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Bills {
  String? BLOCK;
  String? NAME;
  String? Email;
  String? TYPE;
  String? REMARK;
  String? START_DATE;
  String? C_DATE;
  String? END_DATE;
  String? DUE_DATE;
  String? HEAD;
  String? INVOICE_NO;
  double? AMOUNT;
  int? RECEIVED;
  double? PENALTY_REM;
  String? DISCOUNT;
  String? FLAT;

  Bills(
      {this.BLOCK,
      this.NAME,
      this.Email,
      this.TYPE,
      this.REMARK,
      this.START_DATE,
      this.C_DATE,
      this.END_DATE,
      this.DUE_DATE,
      this.HEAD,
      this.INVOICE_NO,
      this.AMOUNT,
      this.RECEIVED,
      this.DISCOUNT,
      this.FLAT,
      this.PENALTY_REM});

  factory Bills.fromJson(Map<String, dynamic> json) {
    return Bills(
        BLOCK: json['BLOCK'],
        NAME: json['NAME'],
        Email: json['Email'],
        TYPE: json['TYPE'] ?? '',
        REMARK: json['REMARK'],
        START_DATE: json['START_DATE'],
        C_DATE: json['C_DATE'],
        END_DATE: json['END_DATE'],
        DUE_DATE: json['DUE_DATE'],
        HEAD: json['HEAD'],
        INVOICE_NO: json['INVOICE_NO'],
        AMOUNT: double.parse(json['AMOUNT'].toString()),
        RECEIVED: json['RECEIVED'],
        PENALTY_REM: json['PENALTY_REM'] is int
            ? json['PENALTY_REM'].toDouble()
            : json['PENALTY_REM'],
        DISCOUNT: json['DISCOUNT'],
        FLAT: json['FLAT']);
  }
}
