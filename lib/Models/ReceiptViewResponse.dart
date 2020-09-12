import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ReceiptViewResponse {
  List<dynamic> data;
  String BILL_PREFIX;
  String RECEIPT_PREFIX;

  ReceiptViewResponse({this.data,this.BILL_PREFIX,this.RECEIPT_PREFIX});


  factory ReceiptViewResponse.fromJson(Map<String, dynamic> json){
    return ReceiptViewResponse(
        data: json['data'],
        BILL_PREFIX: json['BILL_PREFIX'],
        RECEIPT_PREFIX: json['RECEIPT_PREFIX']
    );
  }


}
