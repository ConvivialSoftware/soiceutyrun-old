
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Staff{
  
  String SID;
  String STAFF_NAME;
  String GENDER;
  String DOB;
  String CONTACT;
  String QUALIFICATION;
  String ADDRESS;
  String VEHICLE_NO;
  String NOTES;
  String ASSIGN_FLATS;
  String STATUS;
  String IN_OUTSS;
  String IMAGE;
  String C_DATE;
  String Staff_QR_Image;
  String QR_Text;
  String Attachment;
  String ROLE;

 /* Staff({this.STAFF_NAME,  this.CONTACT,this.IMAGE});*/
 Staff({this.SID, this.STAFF_NAME, this.GENDER, this.DOB, this.CONTACT, this.QUALIFICATION, this.ADDRESS, this.VEHICLE_NO, this.NOTES,
    this.ASSIGN_FLATS, this.STATUS, this.IN_OUTSS, this.IMAGE, this.C_DATE, this.Staff_QR_Image, this.QR_Text, this.Attachment, this.ROLE});


  factory Staff.fromJson(Map<String, dynamic> json){

    return Staff(
      SID: json['SID'],
      STAFF_NAME: json['STAFF_NAME'],
      GENDER:json['GENDER'],
      DOB:json['DOB'],
      CONTACT:json['CONTACT'],
      QUALIFICATION:json['QUALIFICATION'],
      ADDRESS:json['ADDRESS'],
      VEHICLE_NO:json['VEHICLE_NO'],
      NOTES:json['NOTES']??'',
      ASSIGN_FLATS:json['ASSIGN_FLATS']??'',
      STATUS:json['STATUS'],
      IN_OUTSS:json['IN_OUTSS'],
      IMAGE:json['IMAGE']??'',
      C_DATE:json['C_DATE'],
      Staff_QR_Image:json['Staff_QR_Image'],
      QR_Text:json['QR_Text'],
      Attachment:json['Attachment'],
      ROLE:json['ROLE'],
    );
  }






}