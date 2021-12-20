import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NeighboursDirectory {
  String? ID, BLOCK, FLAT, TYPE, NAME, PERMISSIONS, Email, Phone;

  NeighboursDirectory(
      {this.ID,
      this.BLOCK,
      this.FLAT,
      this.TYPE,
      this.NAME,
      this.PERMISSIONS,
      this.Email,
      this.Phone});

  factory NeighboursDirectory.fromJson(Map<String, dynamic> json) {
    return NeighboursDirectory(
        ID: json["ID"],
        BLOCK: json["BLOCK"],
        FLAT: json["FLAT"],
        TYPE: json["TYPE"],
        NAME: json["NAME"],
        PERMISSIONS: json["PERMISSIONS"],
        Email: json["Email"],
        Phone: json["Phone"]);
  }
}
