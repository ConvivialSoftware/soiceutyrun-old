import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class LedgerResponse {

  List<dynamic> ledger;
  List<dynamic> pending_request;
  List<dynamic> openingBalance;
  String billPrefix;
  String receiptPrefix;

  LedgerResponse({this.ledger, this.openingBalance, this.billPrefix, this.receiptPrefix,this.pending_request});

  factory LedgerResponse.fromJson(Map<String, dynamic> map){

    return LedgerResponse(
        ledger: map["LEDGER"],
        pending_request: map["pending_request"],
        openingBalance: map["OPENING_BALANCE"],
        billPrefix: map["BILL_PREFIX"],
        receiptPrefix: map["RECEIPT_PREFIX"]
    );
  }

}