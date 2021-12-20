import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Documents {
  String? ID,
      DOCUMENT,
      TITLE,
      DESCRIPTION,
      DOCUMENT_CATEGORY,
      ADDED_DATE,
      USER_NAME;

  Documents(
      {this.ID,
      this.DOCUMENT,
      this.TITLE,
      this.DESCRIPTION,
      this.DOCUMENT_CATEGORY,
      this.ADDED_DATE,
      this.USER_NAME});

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
        ID: json["ID"],
        DOCUMENT: json["DOCUMENT"],
        TITLE: json["TITLE"],
        DESCRIPTION: json["DESCRIPTION"],
        DOCUMENT_CATEGORY: json["DOCUMENT_CATEGORY"],
        ADDED_DATE: json["ADDED_DATE"],
        USER_NAME : json["Posted_By"]);
  }
}
