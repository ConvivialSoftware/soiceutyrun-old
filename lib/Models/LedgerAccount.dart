import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class LedgerAccount {
  String id;
  String name;

  LedgerAccount({this.id, this.name});


  factory LedgerAccount.fromJson(Map<String, dynamic> json){

    return LedgerAccount(
        id: json['id'],
        name: json['name']
    );
  }


}
