import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class BillViewResponse {
  List<dynamic> BillDetails;
  List<dynamic> HEADS;
  int ARREARS;
  int TOTAL;
  int PENALTY;
  String BILL_TITLE;
  String BILL_FOOTER;
  String INVOICE_TITLE;
  String INVOICE_FOOTER;
  String ISSUE_DATE;
  String CONSUMER_NO;
  String AREA;
  String BILL_PREFIX;

  BillViewResponse({this.BillDetails,this.HEADS,this.ARREARS, this.TOTAL, this.PENALTY, this.BILL_TITLE, this.BILL_FOOTER, this.INVOICE_TITLE,
    this.INVOICE_FOOTER, this.ISSUE_DATE, this.CONSUMER_NO, this.AREA, this.BILL_PREFIX});


  factory BillViewResponse.fromJson(Map<String, dynamic> json){
    return BillViewResponse(
        BillDetails: json['bill_details'],
        HEADS: json['HEADS'],
        ARREARS: json['ARREARS'],
        TOTAL: json['TOTAL'],
        PENALTY: json['PENALTY'],
        BILL_TITLE: json['BILL_TITLE'],
        BILL_FOOTER: json['BILL_FOOTER'],
        INVOICE_TITLE: json['INVOICE_TITLE'],
        INVOICE_FOOTER: json['INVOICE_FOOTER'],
        ISSUE_DATE: json['ISSUE_DATE'],
        CONSUMER_NO: json['CONSUMER_NO'],
        AREA: json['AREA'],
        BILL_PREFIX: json['BILL_PREFIX']
    );
  }


}
