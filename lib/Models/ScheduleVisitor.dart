import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ScheduleVisitor {
  String ADD_FLAT,
      NAME,
      MOBILE_NO,
      DATE,
      PASS_CODE,
      SR_NO;

  ScheduleVisitor(
      {this.ADD_FLAT,
      this.NAME,
      this.MOBILE_NO,
      this.DATE,
      this.PASS_CODE,
      this.SR_NO
      });

  factory ScheduleVisitor.fromJson(Map<String, dynamic> json) {
    return ScheduleVisitor(
        ADD_FLAT: json["ADD_FLAT"],
        NAME: json["NAME"],
        MOBILE_NO: json["MOBILE_NO"],
        DATE: json["DATE"],
        PASS_CODE: json["PASS_CODE"],
        SR_NO: json["SR_NO"]
    );
  }
}
