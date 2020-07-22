import 'package:json_annotation/json_annotation.dart';
@JsonSerializable()
class ComplaintArea {

  String ID;
  String COMPLAINT_AREA;


  ComplaintArea({this.ID, this.COMPLAINT_AREA});

  factory ComplaintArea.fromJson(Map<String, dynamic> map){

    return ComplaintArea(
      ID: map["ID"],
      COMPLAINT_AREA: map["COMPLAINT_AREA"],
    );
  }

}