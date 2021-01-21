import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class Vehicle {
  String ID;
  String VEHICLE_NO;
  String MODEL;
  String WHEEL;
  String STICKER_NO;

  Vehicle({this.ID,this.VEHICLE_NO, this.MODEL, this.WHEEL, this.STICKER_NO});


  factory Vehicle.fromJson(Map<String, dynamic> json){

    return Vehicle(
        ID: json['ID'],
        VEHICLE_NO: json['VEHICLE_NO'],
        MODEL: json['MODEL'],
        WHEEL: json['WHEEL'],
        STICKER_NO: json['STICKER_NO']
    );
  }


}
