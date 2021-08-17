import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
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
  String Phone;
  String PROFILE_PHOTO;
  String AGREEMENT_ID;

  Member(
      {this.TYPE,
      this.NAME,
      this.ADDRESS,
      this.LIVES_HERE,
      this.ID,
      this.STATUS,
      this.BLOCK,
      this.FLAT,
      this.EMAIL,
      this.Phone,
      this.AGREEMENT_ID,
      this.PROFILE_PHOTO});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        TYPE: json['TYPE'],
        NAME: json['NAME'],
        ADDRESS: json['ADDRESS'],
        LIVES_HERE: json['LIVES_HERE'],
        ID: json['ID'],
        STATUS: json['STATUS'],
        BLOCK: json['BLOCK'],
        FLAT: json['FLAT'],
        EMAIL: json['EMAIL']??'',
        Phone: json['Phone']?? '',
        PROFILE_PHOTO: json['PROFILE_PHOTO'],
        AGREEMENT_ID:json['AGREEMENT_ID'],
    );
  }
}
