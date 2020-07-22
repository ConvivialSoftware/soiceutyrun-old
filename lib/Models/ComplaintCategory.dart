import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class ComplaintCategory {

  String ID;
  String COMPLAINT_CATEGORY;
  String STATUS;


  ComplaintCategory({this.ID, this.COMPLAINT_CATEGORY,this.STATUS});

  factory ComplaintCategory.fromJson(Map<String, dynamic> map){

    return ComplaintCategory(
      ID: map["ID"],
      COMPLAINT_CATEGORY: map["COMPLAINT_CATEGORY"],
      STATUS: map["STATUS"],
    );
  }

}