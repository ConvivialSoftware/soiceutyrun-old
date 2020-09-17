import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Complaints {
  String TICKET_NO;
  String SUBJECT;
  String CATEGORY;
  String COMPLAINT_AREA;
  String NATURE;
  String TYPE;
  String BLOCK;
  String FLAT;
  String DESCRIPTION;
  String ATTACHMENT;
  String DATE;
  String COMMENT_COUNT;
  String STATUS;
  String VENDOR;
  String EDIT_DATE;
  String PRIORITY;
  String ATTACHMENT_NAME;
  String NAME;
  String ESCALATION_LEVEL;

  Complaints(
      {this.TICKET_NO,
      this.SUBJECT,
      this.CATEGORY,
      this.COMPLAINT_AREA,
      this.NATURE,
      this.TYPE,
      this.BLOCK,
      this.FLAT,
      this.DESCRIPTION,
      this.ATTACHMENT,
      this.DATE,
      this.COMMENT_COUNT,
      this.STATUS,
      this.VENDOR,
      this.EDIT_DATE,
      this.PRIORITY,
      this.ATTACHMENT_NAME,
      this.NAME,
      this.ESCALATION_LEVEL});

  factory Complaints.fromJson(Map<String, dynamic> json) {
    //  print('complaint ststus : '+json['STATUS']);

    return Complaints(
        TICKET_NO: json['TICKET_NO'],
        SUBJECT: json['SUBJECT'],
        CATEGORY: json['CATEGORY'],
        COMPLAINT_AREA: json['COMPLAINT_AREA'],
        NATURE: json['NATURE'],
        TYPE: json['TYPE'],
        BLOCK: json['BLOCK'],
        FLAT: json['FLAT'],
        DESCRIPTION: json['DESCRIPTION'],
        ATTACHMENT: json['ATTACHMENT'],
        DATE: json['DATE'],
        COMMENT_COUNT: json['COMMENT_COUNT'],
        STATUS: json['STATUS'],
        VENDOR: json['VENDOR'],
        EDIT_DATE: json['EDIT_DATE'],
        PRIORITY: json['PRIORITY'],
        ATTACHMENT_NAME: json['ATTACHMENT_NAME'],
        NAME: json['NAME'],
        ESCALATION_LEVEL: json['ESCALATION_LEVEL']);
  }
}
