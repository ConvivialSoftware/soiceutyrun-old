import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class EmergencyDirectory {
  
  String ID,Name,Contact_No,Address,Sequence,STATUS;

  EmergencyDirectory({this.ID, this.Name, this.Contact_No, this.Address, this.Sequence, this.STATUS});

  factory EmergencyDirectory.fromJson(Map<String, dynamic> json) {

    return EmergencyDirectory(

      ID: json["ID"],
      Name:json["Name"],
      Contact_No:json["Contact_No"],
      Address:json["Address"],
      Sequence:json["Sequence"],
      STATUS:json["STATUS"]
    );

  }

}