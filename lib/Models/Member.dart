import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class Member {
  String TYPE;
  String NAME;
  String ADDRESS;
  String LIVES_HERE;
  String ID;
  String STATUS;
  String BLOCK;
  String FLAT;
  String EMAIL;
  String MOBILE;
  String PROFILE_PHOTO;

  Member({this.TYPE, this.NAME, this.ADDRESS, this.LIVES_HERE, this.ID, this.STATUS, this.BLOCK, this.FLAT, this.EMAIL, this.MOBILE, this.PROFILE_PHOTO});


  factory Member.fromJson(Map<String, dynamic> json){

    return Member(
      TYPE: json['TYPE'],
      NAME: json['NAME'],
      ADDRESS: json['ADDRESS'],
      LIVES_HERE: json['LIVES_HERE'],
      ID: json['ID'],
      STATUS: json['STATUS'],
      BLOCK: json['BLOCK'],
      FLAT: json['FLAT'],
      EMAIL: json['EMAIL'],
      MOBILE: json['MOBILE'],
      PROFILE_PHOTO:json['PROFILE_PHOTO']
    );
  }


}
