import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Poll {
  String ID,
      USER_NAME,
      USER_PHOTO,
      DESCRIPTION,
      EXPIRY_DATE,
      POLL_Q,
      C_DATE,
      SECRET_POLL,
      BLOCK,
      FLAT,
      VOTE_PERMISSION,
      VOTED_TO,
      View_VOTED_TO;
      bool isGraphView;
  List<dynamic> OPTION;

  Poll(
      {this.ID,
      this.USER_NAME,
      this.USER_PHOTO,
      this.DESCRIPTION,
      this.EXPIRY_DATE,
      this.POLL_Q,
      this.C_DATE,
      this.OPTION,
      this.SECRET_POLL,
        this.BLOCK,
        this.FLAT,
        this.VOTE_PERMISSION,
        this.VOTED_TO,this.View_VOTED_TO,this.isGraphView=false});

  factory Poll.fromJson(Map<String, dynamic> json) {
    print('Poll Data : '+json.toString());
    print('json["OPTION"] Data : '+json["OPTION"].toString());
    return Poll(
        ID: json["ID"],
        USER_NAME: json["USER_NAME"],
        USER_PHOTO: json["USER_PHOTO"],
        DESCRIPTION: json["DESCRIPTION"],
        EXPIRY_DATE: json["EXPIRY_DATE"],
        POLL_Q: json["POLL_Q"],
        C_DATE: json["C_DATE"],
        OPTION: json["OPTION"],
        SECRET_POLL: json["SECRET_POLL"],
        BLOCK:json["BLOCK"],
        FLAT: json["FLAT"],
        VOTE_PERMISSION: json["VOTE_PERMISSION"],
        VOTED_TO: json["VOTED_TO"]?? "",
        View_VOTED_TO: json["View_VOTED_TO"]?? "",
        isGraphView:json["isGraphView"]?? false );
  }
}
