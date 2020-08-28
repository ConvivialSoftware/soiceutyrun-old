import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Comments {
  
  String COMMENT_ID,PARENT_TICKET,USER_ID,COMMENT,C_WHEN,ATTACHMENT,ATTACHMENT_NAME,NAME,PROFILE_PHOTO;

  Comments({this.COMMENT_ID, this.PARENT_TICKET, this.USER_ID, this.COMMENT, this.C_WHEN, this.ATTACHMENT, this.ATTACHMENT_NAME, this.NAME, this.PROFILE_PHOTO});

  factory Comments.fromJson(Map<String, dynamic> json) {

    return Comments(

      COMMENT_ID: json["COMMENT_ID"],
      PARENT_TICKET:json["PARENT_TICKET"],
      USER_ID:json["USER_ID"],
      COMMENT:json["COMMENT"],
      C_WHEN:json["C_WHEN"],
      ATTACHMENT:json["ATTACHMENT"],
      ATTACHMENT_NAME:json["ATTACHMENT_NAME"],
      NAME:json["NAME"],
      PROFILE_PHOTO:json["PROFILE_PHOTO"],
    );

  }

}