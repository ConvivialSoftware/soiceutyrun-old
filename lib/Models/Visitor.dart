import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Visitor {
  String ID,
      SID,
      VISITOR_NAME,
      CONTACT,
      IMAGE,
      VEHICLE_NO,
      IN_DATE,
      VISITOR_USER_STATUS,
      COMMENT_USER,
      IN_TIME,
      OUT_DATE,
      OUT_TIME,
      FROM_VISITOR,
      FLAT_NO,
      STATUS,
      VISITOR_STATUS,
      REASON,
      TYPE;

  Visitor(
      {this.ID,
      this.SID,
      this.VISITOR_NAME,
      this.CONTACT,
      this.IMAGE,
      this.VEHICLE_NO,
      this.IN_DATE,
      this.VISITOR_USER_STATUS,
      this.COMMENT_USER,
      this.IN_TIME,
      this.OUT_DATE,
      this.OUT_TIME,
      this.FROM_VISITOR,
      this.FLAT_NO,
      this.STATUS,
      this.VISITOR_STATUS,
      this.REASON,
      this.TYPE});

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
        ID: json["ID"],
        SID: json["SID"],
        VISITOR_NAME: json["VISITOR_NAME"],
        CONTACT: json["CONTACT"],
        IMAGE: json["IMAGE"],
        VEHICLE_NO: json["VEHICLE_NO"],
        IN_DATE: json["IN_DATE"],
        VISITOR_USER_STATUS: json["VISITOR_USER_STATUS"],
        COMMENT_USER: json["COMMENT_USER"],
        IN_TIME: json["IN_TIME"],
        OUT_DATE: json["OUT_DATE"],
        OUT_TIME: json["OUT_TIME"],
        FROM_VISITOR: json["FROM_VISITOR"],
        FLAT_NO: json["FLAT_NO"],
        STATUS: json["STATUS"],
        VISITOR_STATUS: json["VISITOR_STATUS"],
        REASON: json["REASON"],
        TYPE: json["TYPE"]);
  }
}
