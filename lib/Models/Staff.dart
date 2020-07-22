
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Staff{
  
  //String SID;
  String STAFF_NAME;
 // String GENDER;
 // String DOB;
  String CONTACT;
  //String QUALIFICATION;
 // String ADDRESS;
 // String VEHICLE_NO;
 // String NOTES;
 // String ASSIGN_FLATS;
 // String STATUS;
 // String IN_OUTSS;
  String IMAGE;
 // String C_DATE;
 // String Staff_QR_Image;
  //String QR_Text;
 // String Attachment;
 // String ROLE;

  Staff({this.STAFF_NAME,  this.CONTACT,this.IMAGE});
/*
 Staff({this.SID, this.STAFF_NAME, this.GENDER, this.DOB, this.CONTACT, this.QUALIFICATION, this.ADDRESS, this.VEHICLE_NO, this.NOTES,
    this.ASSIGN_FLATS, this.STATUS, this.IN_OUTSS, this.IMAGE, this.C_DATE, this.Staff_QR_Image, this.QR_Text, this.Attachment, this.ROLE});
*/


  factory Staff.fromJson(Map<String, dynamic> json){

    return Staff(
      STAFF_NAME: json['STAFF_NAME'],
      CONTACT:json['CONTACT'],
      IMAGE:json['IMAGE']
    );
  }






}