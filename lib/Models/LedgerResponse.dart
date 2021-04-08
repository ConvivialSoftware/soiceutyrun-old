import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class LedgerResponse {

  List<dynamic> year;
  List<dynamic> ledger;
  List<dynamic> pending_request;
  List<dynamic> openingBalance;
  String billPrefix;
  String receiptPrefix;

  LedgerResponse({this.ledger, this.openingBalance, this.billPrefix, this.receiptPrefix,this.pending_request,this.year});

  factory LedgerResponse.fromJson(Map<String, dynamic> map){

    return LedgerResponse(
        year: map["Year"],
        ledger: map["LEDGER"],
        pending_request: map["pending_request"],
        openingBalance: map["OPENING_BALANCE"],
        billPrefix: map["BILL_PREFIX"],
        receiptPrefix: map["RECEIPT_PREFIX"]
    );
  }

}

class LedgerYear {

  var years,Active_account;
  LedgerYear({this.years,this.Active_account});

  factory LedgerYear.fromJson(Map<String, dynamic> map){

    return LedgerYear(
      years: map["years"],
      Active_account: map["Active_account"],
    );
  }


}