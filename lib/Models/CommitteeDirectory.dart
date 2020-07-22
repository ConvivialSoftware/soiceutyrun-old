import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CommitteeDirectory {
  String ID,
      POST,
      STATUS,
      C_DATE,
      NAME,
      BLOCK,
      FLAT,
      INTERCOM,
      EMAIL,
      PHONE,
      SOCIETY_ID;

  CommitteeDirectory(
      {this.ID,
      this.POST,
      this.STATUS,
      this.C_DATE,
      this.NAME,
      this.BLOCK,
      this.FLAT,
      this.INTERCOM,
      this.EMAIL,
      this.PHONE,
      this.SOCIETY_ID});

  factory CommitteeDirectory.fromJson(Map<String, dynamic> json) {
    return CommitteeDirectory(
        ID: json["ID"],
        POST: json["POST"],
        C_DATE: json["C_DATE"],
        STATUS: json["STATUS"],
        NAME: json["NAME"],
        BLOCK: json["BLOCK"],
        FLAT: json["FLAT"],
        INTERCOM: json["INTERCOM"],
        EMAIL: json["EMAIL"],
        PHONE: json["PHONE"],
        SOCIETY_ID: json["SOCIETY_ID"]);
  }
}
