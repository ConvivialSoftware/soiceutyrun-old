import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class VehicleDirectory {
  String? BLOCK, FLAT, VEHICLE_NO, MODEL, INTERCOM;

  VehicleDirectory(
      {this.BLOCK, this.FLAT, this.VEHICLE_NO, this.MODEL, this.INTERCOM});

  factory VehicleDirectory.fromJson(Map<String, dynamic> json) {
    return VehicleDirectory(
      BLOCK: json["BLOCK"],
      FLAT: json["FLAT"],
      VEHICLE_NO: json["VEHICLE_NO"],
      MODEL: json["MODEL"],
      INTERCOM: json["INTERCOM"]??'',
    );
  }
}
