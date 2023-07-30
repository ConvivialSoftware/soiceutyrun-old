import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class VehicleDirectory {
  String? BLOCK, FLAT, VEHICLE_NO, MODEL, INTERCOM,WHEEL;

  VehicleDirectory(
      {this.BLOCK, this.FLAT, this.VEHICLE_NO, this.MODEL, this.INTERCOM,this.WHEEL});

  factory VehicleDirectory.fromJson(Map<String, dynamic> json) {
    return VehicleDirectory(
      BLOCK: json["BLOCK"],
      FLAT: json["FLAT"],
      WHEEL: json["WHEEL"],
      VEHICLE_NO: json["VEHICLE_NO"]??'',
      MODEL: json["MODEL"],
      INTERCOM: json["INTERCOM"] ?? '',
    );
  }
}
